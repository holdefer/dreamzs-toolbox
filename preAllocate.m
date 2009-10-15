function [sequences,evalResults] = preAllocate(dreamPar,sequences, evalResults) 
if dreamPar.reducedSampleCollection
    tmpSeq = repmat(NaN,[ceil((dreamPar.nModelEvalsMax-dreamPar.nSamples)/(dreamPar.nSeq*dreamPar.reducedSampleFrequency)),...
                  size(sequences,2),...
                  dreamPar.nSeq]);
    tmpEvalResults = nan(ceil(dreamPar.nModelEvalsMax-dreamPar.nSamples/(dreamPar.nSeq*dreamPar.reducedSampleFrequency)), size(evalResults,2));
else
    tmpSeq = repmat(NaN,[ceil((dreamPar.nModelEvalsMax-dreamPar.nSamples)/dreamPar.nSeq),...
                  size(sequences,2),...
                  dreamPar.nSeq]);
    tmpEvalResults = nan(dreamPar.nModelEvalsMax-dreamPar.nSamples, size(evalResults,2));
end

sequences = cat(1,sequences,tmpSeq);

evalResults = cat(1,evalResults,tmpEvalResults);

clear tmpSeq;
clear tmpEvalResults;
end