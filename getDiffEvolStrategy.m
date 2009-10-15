function [diffEvolStrategy] = getDiffEvolStrategy(dreamPar)
% Associates to each sequence a differential evolution strategy, which is
% basically a number between 1 and nDiffEvolPairs,
% representing the number of pairs to be used in
% the differential evolution step.
diffEvolStrategy = nan(dreamPar.nSeq,1);
% Determine probability of selecting a given number of pairs;
pairProbability = (1/dreamPar.nDiffEvolPairs) * ones(1,dreamPar.nDiffEvolPairs); 
pairProbability = cumsum(pairProbability); 
pairProbability = [0 pairProbability];
% Generate a random number between 0 and 1
randNumber = rand(dreamPar.nSeq,1);
% Select number of pairs for each sequence
for seq = 1:dreamPar.nSeq,
    nPairs = find(randNumber(seq,1)>pairProbability);
    diffEvolStrategy(seq,1) = nPairs(end);
end;