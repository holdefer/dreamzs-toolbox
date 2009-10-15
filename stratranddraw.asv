function sDraw = stratranddraw(dreamPar)
%
% <a href="matlab:web(fullfile(scemroot,'html','stratrand.html'),'-helpbrowser')">View HTML documentation for this function in the help browser</a>    
%

nOptPars = dreamPar.nOptPars;
nSamples = dreamPar.nSamples;

% specific to DREAM_ZS
nSamples = nSamples + dreamPar.nInitialSamples;

nSamplesPerAxis = floor(nSamples^(1/nOptPars));
nStratRandSamples=nSamplesPerAxis^nOptPars;
nUniRandSamples = nSamples-nStratRandSamples;

pStr='';


res(1,:) = (dreamPar.rangeMax-dreamPar.rangeMin)/(nSamplesPerAxis);

for k=1:numel(dreamPar.rangeMax)
    eval(['p',num2str(k),' = linspace(dreamPar.rangeMin(k),',...
                'dreamPar.rangeMax(k)-res(k),',...
                'nSamplesPerAxis);'])

    if k<=1
        pStr = [pStr,'p',num2str(k)];
    else
        pStr = [pStr,',p',num2str(k)];
    end
        
end

eval(['parCombs = allcomb(',pStr,')+',...
    'repmat(res,[nStratRandSamples,1]).*',...
    'rand(nStratRandSamples,nOptPars);'])

% eval(['parCombs = allcomb(',pStr,')'])%.*',...
% %     'repmat(res,[nStratRandSamples,1]).*',...
% %     'rand(nStratRandSamples,nOptPars)'])


TMP=dreamPar;
TMP.nSamples=nUniRandSamples;

uDraw = unifranddraw(TMP);

sDraw=[parCombs;uDraw];

