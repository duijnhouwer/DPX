function plotDirectionTuningCurve(TC,i)
    % TC is a tuningcurve DPXD made by calcDirectionTuningCurve of 1 or
    % more cells. i is the cell-number to be plot.
    if nargin==1
        i=1;
    end
    X=TC.dirDeg{i};
    Y=TC.meanDFoF{i};
    E=TC.sdDFoF{i}./sqrt(TC.nDFoF{i});
	errorbar(X,Y,E,'bo-','MarkerFaceColor','b');
    xlabel('Direction (deg)');
    ylabel('mean dFoF');
    set(gca,'XTick',X);
    titStr=[TC.file{i} ' c' num2str(TC.cellNumber(i),'%.3d')];
    title(titStr,'Interpreter','none');
end