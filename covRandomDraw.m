function randomDraw = covRandomDraw(dreamPar)
nSamples = dreamPar.nSamples;

% specific to DREAM_ZS
nSamples = nSamples + dreamPar.nInitialSamples;

randomDraw = repmat(dreamPar.initialMean,nSamples,1) + randn(nSamples,dreamPar.nOptPars) * chol(dreamPar.covariance);

if strcmp(dreamPar.boundHandling,'Reflect');
    randomDraw = reflectBounds(randomDraw,dreamPar);
end;
if strcmp(dreamPar.boundHandling,'Bound');
    randomDraw = setToBounds(randomDraw,dreamPar);
end;
if strcmp(dreamPar.boundHandling,'Fold');
    randomDraw = foldBounds(randomDraw,dreamPar);
end;

