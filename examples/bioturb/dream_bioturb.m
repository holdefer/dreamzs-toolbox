   
clear
close all
clc


% define which parameters should be included in the optimization
% and generate a map of where each entry of 'parVec' fits in the 
% model structure under consideration.
[dreamPar.parMap,dreamPar.parMapTex,dreamPar.rangeMin,dreamPar.rangeMax] = assignpars;

 xlsread Cfract_dat_G7.xls;
 xMeas = (ans(:,1)/100);
 yMeas = (ans(:,2)/100);

dreamPar.nSeq = 10;
dreamPar.nSamples = 10;
dreamPar.nModelEvalsMax = 50000;
%dreamPar.constNames = modelConstantsNames;
dreamPar.modelCallStr = 'modelResult = Bioturb_Velthuis_105_SCEM(parVec);';
dreamPar.objCallStr = '[objScore,logObjectiveScore] = objectivefun(dreamPar,modelResult);';
dreamPar.measNames = {'yMeas'};
dreamPar.useIniFile = 'dream-default-settings.ini';
dreamPar.visualizationCall = 'visualization2';
dreamPar.optMethod = 3;
dreamPar.nMeasurements = numel(yMeas);
dreamPar.drawInterval = 1;
dreamPar.nModelEvalsMax = 50010;
dreamPar.boundHandling = 'Reflect';


[evalResults,critGelRub,outliers,sequences,acceptanceRate, pCrossoverHistory, dreamPar] = dream(dreamPar);

%calculate bayesian intervals:
nBayes = dreamPar.nSamples;
M = [];
for k=size(evalResults,1)-[0:nBayes]
    
    parVec = evalResults(k,dreamPar.parCols);
    
    eval(dreamPar.modelCallStr)
    
    M = [M;modelResult];
    
end

B = bayesprobint(M,[5,95],'vec');


% calculate best model result:
M = [];
bestIx = find(evalResults(:,dreamPar.objCol)==max(evalResults(:,dreamPar.objCol)));
bestUniParSets = unique(evalResults(bestIx,dreamPar.parCols),'rows');

for k=1:size(bestUniParSets,1)
    
    parVec = bestUniParSets(k,:);
    
    eval(dreamPar.modelCallStr);
    
    figure
    plot(modelResult,-xMeas,'-.r*')
    hold on
    plot(yMeas,-xMeas,'-.b*')
    
    M = [M;modelResult];
    
end



% visualize the result:
figure('numbertitle','off','name','bayes')
h=plot(xMeas,yMeas,'mo',...
       xMeas,B(1,:),'k-',...
       xMeas,B(2,:),'k-',...
       xMeas,M,'-k');
set(h(1),'markersize',3,'markerfacecolor','m')
set(h([2,3]),'color',[0.6,0.6,0.6])
set(h,'linewidth',2)
legend(h([1,2,4,5]),'measured','5-95% bayesian interval',...
    'without error','best simulation')

figure
matrixofimagesc(dreamPar,evalResults)



