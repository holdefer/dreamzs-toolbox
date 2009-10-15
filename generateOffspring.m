function [propChild, crtCrossoverValues, alphaSnooker] = generateOffspring(dreamPar,lastPointsFromEverySeq, crtPastPoints, jumpRateTable, crtCrossoverValues)
%
% <a href="matlab:web(fullfile(scemroot,'html','generateOffspring.html'),'-helpbrowser')">View HTML documentation for this function in the help browser</a>    
%
%

% global DEBUG_VAR_jumpBase

parCols = dreamPar.parCols;
nOptPars = dreamPar.nOptPars;

crtPastPointsCount = size(crtPastPoints,1);

if (crtPastPointsCount < 2 * dreamPar.nDiffEvolPairs * dreamPar.nSeq)
    % The number of elements of crtPastPoints is not sufficient
    error('size of crtPastPoints not sufficient to generate offspring with selected dreamPar.nInitialSamples, dreamPar.nSeq, and dreamPar.nDiffEvolPairs');
else
    % Without replacement draw rows from crtPastPoints for the proposal creation
    crtPastPointsIdx = randsample(crtPastPointsCount, 2 * dreamPar.nDiffEvolPairs * dreamPar.nSeq); 
    diffEvolPoints = crtPastPoints(crtPastPointsIdx,:);
end;

% Determine for each sequence, the number of pairs to evolve with
diffEvolStrategy = getDiffEvolStrategy(dreamPar);

% Generate uniform random numbers for each chain to determine which dimension to update
D = rand(dreamPar.nSeq,nOptPars);

% Ergodicity for each individual chain
noise = dreamPar.randomErgodicityError * (2 * rand(dreamPar.nSeq,nOptPars) - 1);

% Initialize the delta update to zero
deltaToOffspring = zeros(dreamPar.nSeq,nOptPars);

u = rand;
% Determine to do parallel direction or snooker update     
if (u <= dreamPar.parallelUpdateFraction),
    %Parallel direction update
    % Define, for each sequence, which points of diffEvolPoints to use to generate jumps
    last = 0;
    idx = nan(dreamPar.nSeq, 4);
    for currentSeq = 1:dreamPar.nSeq,
        % Define idx to be used for population evolution
        idx(currentSeq,1) = last + 1; 
        idx(currentSeq,2) = idx(currentSeq,1) + diffEvolStrategy(currentSeq,1) - 1; 
        idx(currentSeq,3) = idx(currentSeq,2) + 1; 
        idx(currentSeq,4) = idx(currentSeq,3) + diffEvolStrategy(currentSeq,1) - 1; 
        last = idx(currentSeq,4);
    end;

    % Each chain evolves using information from other chains to create offspring
    for currentSeq = 1:dreamPar.nSeq

        % Determine a  subset of dimensions to update
        dimToUpdateIdx = find(D(currentSeq,:) > (1-crtCrossoverValues(currentSeq,1)));

        % Pick up a random dimension to update
        if isempty(dimToUpdateIdx)
            dimToUpdateIdx = randperm(nOptPars);
            dimToUpdateIdx = dimToUpdateIdx(1); 
        end;

        % Determine the number of dimensions that are going to be updated
        dimCount = size(dimToUpdateIdx,2);
        
        pairCount = diffEvolStrategy(currentSeq,1);

       % Determine the associated jumpRate and compute the delta
        if (rand < 4/5),
            % Lookup Table
            jumpRate = jumpRateTable(dimCount,pairCount);
            
            delta =  sum(diffEvolPoints(idx(currentSeq,1):idx(currentSeq,2),:) - diffEvolPoints(idx(currentSeq,3):idx(currentSeq,4),:),1);

            % Then fill update the dimension
            deltaToOffspring(currentSeq,dimToUpdateIdx) = jumpRate * (1 + noise(currentSeq,dimToUpdateIdx)) .* delta(1,dimToUpdateIdx);
        else

            % Set the JumpRate to 1 and overwrite crtCrossoverValues and diffEvolStrategy
            jumpRate = 1; 
            crtCrossoverValues(currentSeq,1) = 1; 

            % Compute delta from one pair
            delta = diffEvolPoints(currentSeq,:) - diffEvolPoints(currentSeq,:);

            % Now apply the jump rate to facilitate jumping from one mode to the other in all dimensions
            deltaToOffspring(currentSeq,:) = jumpRate * delta;
        end;

    end;
else
   % Snooker update
   % Determine the number of rows of diffEvolPoints
    diffEvolPointsCount = size(diffEvolPoints,1);
    % Define idx
    idx = 1:1:diffEvolPointsCount; 
    idx = reshape(idx,2,size(idx,2)/2)';
    % Define JumpRate -- uniform rand number between 1.2 and 2.2
    jumpRate = 1.2 + rand;
    z = nan(dreamPar.nSeq, dreamPar.nOptPars);
    % Loop over the individual chains
    for currentSeq = 1:dreamPar.nSeq
        % Define two points from diffEvolPoints 
        zR1 = diffEvolPoints(idx(currentSeq,1),:); 
        zR2 = diffEvolPoints(idx(currentSeq,2),:);
        
        % compute the indices of the other points in diffEvolPoints
        othersIdx = 1:diffEvolPointsCount;
        othersIdx(idx(currentSeq,1)) = 0; 
        othersIdx(idx(currentSeq,2)) = 0; 
        othersIdx = othersIdx(othersIdx>0); 
        % Define z as a random point from diffEvolPoints - {zR1,zR2}
        z(currentSeq,:) = diffEvolPoints(othersIdx(randsample(diffEvolPointsCount-2,1)),:);
        % Define projection vector
        diff = lastPointsFromEverySeq(currentSeq,parCols) - z(currentSeq,:); 
        d = max(diff * diff',1e-300);
        % Orthogonally project of zR1 and zR2 onto F; calculate zP1 - zP2
        zP = diff * (sum((zR1-zR2).* diff) / d);
        % And define the jump
        deltaToOffspring(currentSeq,:) = jumpRate * zP;
        % Update CR because we only consider full dimensional updates
        crtCrossoverValues(currentSeq,1) = 1;
    end;
end


% Update lastPointFromSeq with deltaToOffspring and eps;
propChild = lastPointsFromEverySeq(:,parCols) + deltaToOffspring;

% Define alphaSnooker
if (u > dreamPar.parallelUpdateFraction)
    % Determine Euclidean distance
    alphaSnooker = (sum((propChild - z).^2,2)./sum((lastPointsFromEverySeq(:,parCols) - z).^2,2)).^((dreamPar.nOptPars-1)/2);
else
    alphaSnooker = ones(dreamPar.nSeq,1);
end;

% Do boundary handling -- what to do when points fall outside the bound
if strcmp(dreamPar.boundHandling,'Reflect');
    propChild = reflectBounds(propChild,dreamPar);
end;
if strcmp(dreamPar.boundHandling,'Bound');
    propChild = setToBounds(propChild,dreamPar);
end;
if strcmp(dreamPar.boundHandling,'Fold');
    propChild = foldBounds(propChild,dreamPar);
end;

propChild = [nan(size(propChild,1),1), propChild, nan(size(propChild,1),2), repmat(false,size(propChild,1),1)];





