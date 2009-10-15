function pCrossover = updatePCrossover(dreamPar,deltaTot,crossoverCount)
% Updates the probabilities of the various crossover values

% Adapt pCrossover using information from averaged normalized jumping distance
pCrossover = dreamPar.nSeq * (deltaTot./crossoverCount) / sum(deltaTot);

% Normalize pCrossover
pCrossover = pCrossover./sum(pCrossover);