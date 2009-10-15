function [objStat,logObjStat] = objectivefun(scemPar,modelResult)

importmeasurements

Err = yMeas(:)-modelResult(:);

% calculate the sum of squared errors, and change its sign:
objStat = -sum(Err.^2);
logObjStat = objStat;

