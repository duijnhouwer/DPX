function plotDirectionTuningCurveSfTfContrast(TC,i,varargin)
    % TC is a tuningcurve DPXD made by calcDirectionTuningCurve of 1 or
    % more cells. i is the cell-number to be plot.
 
    if nargin==1 || isempty(i)
        i=1;
    end
    
    fileName=TC.file{1};
    cellNumber=TC.cellNumber(1);
    TC=rmfield(TC,{'file','cellNumber'});
    
    panelNr=0;
    C=dpxdSplit(TC,'contrast');
    for c=1:numel(C)
        gray=sqrt(1-c/numel(C));
        options={varargin{:} , 'color', [gray gray gray]}; %#ok<CCAT>
        S=dpxdSplit(C{c},'SF');
        for s=1:numel(S)
            T=dpxdSplit(S{s},'TF');
            for t=1:numel(T)
                panelNr=panelNr+1;
                subplot(numel(S),numel(T),panelNr)
                plotOneCurve(T{t},options{:});
                title(['SF=' num2str(T{t}.SF(1)) ',TF=' num2str(T{t}.TF(1))]); 
            end
        end
    end
    xlabel('Direction (deg)');
    ylabel('mean dFoF');
    %
   % titStr=[fileName ' c' num2str(cellNumber,'%.3d')];
   % titStr(titStr=='\')='/'; % otherwise dpxSuptitle interprets ....
   % titStr(titStr=='_')='-'; % ... these as markup-codes (e.g. subscript)
   % dpxSuptitle(titStr);
end

function plotOneCurve(TC,varargin)
    % Parse 'options' input
    p=inputParser;
    p.addParamValue('bayesfit',true,@islogical);
    p.addParamValue('color',[0 0 0],@(x)isnumeric(x)&&numel(x)==3);
    p.parse(varargin{:});
    
    col=p.Results.color;
    X=TC.dirDeg{1};
    Y=TC.meanDFoF{1};
    E=TC.sdDFoF{1}./sqrt(TC.nDFoF{1}); % standard error of the mean
    if p.Results.bayesfit
        errorbar(X,Y,E,'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'Color',col);
        hold on
        %curveName=TC.dpxBayesPhysV1{1};
        %curveName(curveName=='_')=' ';
        %dpxText(curveName);
        plot(TC.dpxBayesPhysV1x{1},TC.dpxBayesPhysV1y{1},'-','Color',col);
    else
        errorbar(X,Y,E,'o-','MarkerFaceColor',col,'MarkerEdgeColor',col,'Color',col);
    end
   	k=axis;
    axis([-5 360 k(3) k(4)]);
    set(gca,'XTick',X);
end