function plotDirectionTuningCurveSfTfContrast(TC,varargin)
    % TC is a tuningcurve DPXD made by calcDirectionTuningCurve of 1 cell
    
    % TC is the output of calcPlotDirectionTUningCurvesSfTfContrast
    % It has 1 element (if data is based on one recording) or 3 or more. If
    % the data is based on 2 or more recordings the first element will be the
    % analysis of all the merged data and the subsequent elements will be the
    % analysis based on the individual recordings. THis plot function currently
    % only plots the first, merged data, not the components. It does work for
    % the simpler case without SfTf and Contrast splitting
    %
    % Note: I regret making the analysis so that it splits the data per
    % component internally. The whole analysis has become very complicated and
    % bug prone. In hindsight, I rather had run the analysis on the merged
    % files and components by programming the neurotodo files to run on the
    % merged file and on the seperate component files. 
    TC=TC{1};
    
    fileName=TC.file{1};
    cellNumber=TC.cellNumber(1);
    TC=rmfield(TC,{'file','cellNumber'});
    
    
    C=dpxdSplit(TC,'contrast');
    for c=1:numel(C)
        panelNr=0;
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
        plot(X,Y,'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'Color',col);
        errorbar(X,Y,E,'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'Color',col);
        hold on
        curveName=TC.dpxBayesPhysV1{1};
        curveName(curveName=='_')=' ';
        %dpxText(curveName);
        plot(TC.dpxBayesPhysV1x{1},TC.dpxBayesPhysV1y{1},'-','Color',col);
    else
        plot(X,Y,'o-','MarkerFaceColor',col,'MarkerEdgeColor',col,'Color',col);
        errorbar(X,Y,E,'o-','MarkerFaceColor',col,'MarkerEdgeColor',col,'Color',col);
    end
    %k=axis;
    %axis([-20 380 k(3) k(4)]);
    xlim([-20 380])
    %'YLim(auto)';
    set(gca,'XTick',X);
end