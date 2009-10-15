function [acceptedChild,acceptedSequencesDelayed] = evolveDelayedStep(dreamPar,lastPointsFromEverySeq, propChildDelayed, propChild, acceptedChild,rejectedSeqIdx,alpha,alphaDelayed)

objCol = dreamPar.objCol;    
logPCol = dreamPar.logPCol;
parCols = dreamPar.parCols;

cholDecomp = (2.38/sqrt(dreamPar.nOptPars)) * chol(cov(lastPointsFromEverySeq(1:end,parCols)) + 1e-5*eye(dreamPar.nOptPars));
invCholDecomp = inv(cholDecomp);

%operate only on the rejected points
lastPointsFromEverySeq = lastPointsFromEverySeq(rejectedSeqIdx,:);
propChild = propChild(rejectedSeqIdx,:);
alpha = alpha(rejectedSeqIdx,:);
nrDelayedChains = size(rejectedSeqIdx,1);

% Loop over the delayed rejection candidate chains
for chain = 1:nrDelayedChains,
  
    objScoreDelayed = propChildDelayed(chain,objCol);
    objScorePrevious = lastPointsFromEverySeq(chain,objCol); 
    logobjScoreDelayed = propChildDelayed(chain,logPCol);
      
    switch dreamPar.optMethod
        case 1
             l2 = (objScoreDelayed/objScorePrevious);
        case {2,4}
            l2 = exp(objScoreDelayed - objScorePrevious);
        case  3 % SSE probability evaluation
             l2 = (objScoreDelayed/objScorePrevious).^(-dreamPar.nMeasurements.*(1+dreamPar.kurt)./2);
        case 5 % Similar as 3 but  weighted with the measurement error sigma
           l2 = exp(-0.5 * (-objScoreDelayed + objScorePrevious)/dreamPar.sigma^2); % signs are different because we write -SSR
    end;
    
   
    q1 = exp(-0.5*(norm((propChildDelayed(chain,parCols)-propChild(chain,parCols))*invCholDecomp)^2 - norm((lastPointsFromEverySeq(chain,parCols)-propChild(chain,parCols))*invCholDecomp)^2));
    
    alphaCurrent = l2*q1*(1-alphaDelayed(chain,1))/(1-alpha(chain,1));
    
    
    % Now do MH evaluation    
    if alphaCurrent > rand
        % accept the new point
        acceptedSequencesDelayed(rejectedSeqIdx(chain)) = 1;
        % Accept the new point
        acceptedChild(rejectedSeqIdx(chain),[parCols, objCol, logPCol]) = [propChildDelayed(chain,parCols) objScoreDelayed logobjScoreDelayed];
    else
        acceptedSequencesDelayed(rejectedSeqIdx(chain)) = 0;
    end;    
end;