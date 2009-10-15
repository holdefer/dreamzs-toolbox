
clear
close all
clc


% define which parameters should be included in the optimization
% and generate a map of where each entry of 'parVec' fits in the 
% model structure under consideration.
[dreamPar.parMap,dreamPar.parMapTex,...
    dreamPar.rangeMin,dreamPar.rangeMax] = assignpars; 

% define which model parameters are not included in the optimization:
assignconstants
dreamPar.constNames = modelConstantsNames;

% % % % % % % % % % % % % 

dreamPar.nSeq = 3;
dreamPar.modelCallStr = 'modelResult = gaussianmodel(parVec);';
dreamPar.objCallStr = '[objScore,logObjScore] = objectivefun(modelResult);';
dreamPar.parallelUpdateFraction = 1;
dreamPar.updateStatesFrequency = 10;
% dreamPar.optMethod = 'direct probability';
dreamPar.drawInterval = 4;
dreamPar.nDiffEvolPairs = 3;
dreamPar.samplingMethod = 'uniform';
dreamPar.nCrossoverValues = 3;  
dreamPar.crossoverValuesTuning = true;
dreamPar.kurt = 0;
dreamPar.boundHandling = 'None';    
dreamPar.reducedSampleCollection = true;
dreamPar.reducedSampleFrequency = 1e4;
dreamPar.randomErgodicityError = 5e-2; 
dreamPar.optMethod = 4;
dreamPar.nOffspringPerSeq = 500;
dreamPar.nModelEvalsMax = 3e4+3;
dreamPar.plotYN=false;
dreamPar.nInitialSamples = 1000;


[evalResults,critGelRub,sequences,acceptanceRate, pCrossoverHistory, dreamPar] = dreamzs(dreamPar);

