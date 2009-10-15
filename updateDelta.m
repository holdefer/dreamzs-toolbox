function [deltaTot] = updateDelta(dreamPar,deltaTot,acceptedChild,lastPointsFromEverySeq, currentCrossoverValues)
% For each crossover value it associates the total normalized Euclidean distance between the old points and
% the new points (in the chains updated by that specific crossover value)

% Calculate the standard deviation of each dimension of
% acceptedChild
r = repmat(std(acceptedChild(:,dreamPar.parCols)),dreamPar.nSeq,1);

% Compute the Euclidean distance between acceptedChild
% and lastPointsFromEverySeq
deltaCurrentLast = sum(((lastPointsFromEverySeq(:,dreamPar.parCols) - acceptedChild(:,dreamPar.parCols))./r).^2,2);

for val = 1:dreamPar.nCrossoverValues;
    % Find which chains are updated with val/dreamPar.nCrossoverValues
    % probability
    idx = currentCrossoverValues == val/dreamPar.nCrossoverValues; 
    
    % Add the normalized squared distance to the current deltaTot;
    deltaTot(1,val) = deltaTot(1,val) + sum(deltaCurrentLast(idx,1));
    
end;