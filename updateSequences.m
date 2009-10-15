function [sequences,evalResults, updateIndex] = updateSequences(dreamPar, sequences, evalResults, acceptedChild, iOffspring, iteration)

wasLastPointStored = true;
updateIndex = iteration + 1;
if ~dreamPar.reducedSampleCollection
    evalResults((updateIndex-1)*dreamPar.nSeq+1:updateIndex*dreamPar.nSeq, :) = acceptedChild;
    for seq = 1:dreamPar.nSeq 
        sequences(updateIndex,:,seq) = acceptedChild(seq, :);
    end
else
    updateIndex = floor(iteration/dreamPar.reducedSampleFrequency) + 1;
    if mod(iteration, dreamPar.reducedSampleFrequency) == 0
        evalResults((updateIndex-1)*dreamPar.nSeq+1:updateIndex*dreamPar.nSeq, :) = acceptedChild;
        for seq = 1:dreamPar.nSeq 
            sequences(updateIndex,:,seq) = acceptedChild(seq, :);
        end
    else 
        wasLastPointStored = false;
    end
end

                      
             