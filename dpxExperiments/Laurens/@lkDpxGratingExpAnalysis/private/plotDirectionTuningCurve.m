function plotDirectionTuningCurve(TC,i,varargin)
    % TC is a tuningcurve DPXD made by calcDirectionTuningCurve of 1 or
    % more cells. i is the cell-number to be plot.
        
    % Parse 'options' input
    p=inputParser;
    p.addParamValue('bayesfit',true,@islogical);
    p.parse(varargin{:});
    
    if nargin==1
        i=1;
    end
    X=TC.dirDeg{i};
    Y=TC.meanDFoF{i};
    E=TC.sdDFoF{i}./sqrt(TC.nDFoF{i}); % standard error of the mean
    if p.Results.bayesfit
        errorbar(X,Y,E,'bo','MarkerFaceColor','b');
        hold on
        curveName=TC.dpxBayesPhysV1{1};
        curveName(curveName=='_')=' ';
        dpxText(curveName);
        plot(TC.dpxBayesPhysV1x{1},TC.dpxBayesPhysV1y{1},'b-');
    else
        errorbar(X,Y,E,'bo-','MarkerFaceColor','b');
    end
    xlabel('Direction (deg)');
    ylabel('mean dFoF');
    set(gca,'XTick',X);
    titStr=[TC.file{i} ' c' num2str(TC.cellNumber(i),'%.3d')];
    title(titStr,'Interpreter','none');
end