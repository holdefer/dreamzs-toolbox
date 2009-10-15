function [acceptedChild,alpha,acceptedSequences] = evolve(dreamPar,lastPointsFromEverySeq,propChild, alpha_s)

iterCol = dreamPar.iterCol;
objCol = dreamPar.objCol;


% First set acceptedChild to the old positions in X
acceptedChild = lastPointsFromEverySeq;

acceptedChild(:,iterCol) = propChild(:,iterCol);

% And initialize accept with zeros
acceptedSequences = zeros(dreamPar.nSeq,1);

lastObjectiveScores = lastPointsFromEverySeq(:,objCol);
newObjectiveScores = propChild(:,objCol);

alpha = ones(dreamPar.nSeq,1);
switch dreamPar.optMethod
    case 1
        if(all(lastObjectiveScore))
            alpha = newObjectiveScores./lastObjectiveScores;            
        end;
    case {2,4}
        alpha = exp(newObjectiveScores - lastObjectiveScores);
    case  3 % SSE probability evaluation
        alpha = (newObjectiveScores./lastObjectiveScores).^(-dreamPar.nMeasurements.*(1+dreamPar.kurt)./2);
    case 5 % Similar as 3 but  weighted with the measurement error sigma
        alpha = exp(-0.5*(-newObjectiveScores + lastObjectiveScores)./dreamPar.sigma^2); % signs are different because we write -SSR
end;

% modify the alpha
alpha = alpha.* alpha_s;

% Generate random numbers
randUniDraw = rand(size(alpha,1),1);

% Find which alpha's are greater than Z
idx = find(alpha > randUniDraw);

% And update these chains
acceptedChild(idx,:) = propChild(idx,:);

% And indicate that these chains have been accepted
acceptedSequences(idx,1) = 1;