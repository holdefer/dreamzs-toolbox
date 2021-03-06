function varargout = plotconv(dreamPar,evalResults,varargin)

        
nPars = numel(dreamPar.parMap);

H = repmat(NaN,[nPars,1]);

if nargin>2 && ~isempty(varargin{1})
    plotMode = varargin{1};
else
    plotMode = 'subplots';
end

for k=dreamPar.parCols
    
    switch plotMode
        case 'figures'
            figure            
            set(gcf,'name',mfilename,'numbertitle','off')
        case 'subaxes'
            set(gcf,'name',mfilename,'numbertitle','off')
            subaxes(nPars,1,k-1,'borderBottom',0.02,...
                                'spacingRight',0.01,...
                                'spacingLeft',0.075)
        case 'subplots'
            set(gcf,'name',mfilename,'numbertitle','off')
            subplot(nPars,1,k-1)
    end

    H(k-1) = plot(evalResults(:,1),evalResults(:,k),'s',...
                                           'markersize',2,...
                                      'markeredgecolor','k',...
                                      'markerfacecolor','k');
           
    if isfield(dreamPar,'parMapTex')&&...
            numel(dreamPar.parMapTex)>=(k-1)&&...
            ~isempty(dreamPar.parMapTex{k-1})
        ylabel(dreamPar.parMapTex{k-1},'interpreter','tex',...
            'rotation',0,'horizontalalignment','right')
    else
        ylabel(dreamPar.parMap{k-1},'interpreter','none',...
            'rotation',0,'horizontalalignment','right')
    end
                                  
    if k-1~=nPars(end)
        set(gca,'xticklabel',[])
    end
                                  
end
xlabel('iteration')
    

if nargout==1
    varargout=H;
end