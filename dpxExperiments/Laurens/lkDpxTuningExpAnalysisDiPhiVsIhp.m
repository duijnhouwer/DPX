function lkDpxTuningExpAnalysisDiPhiVsIhp(D)
    
    % D should be the output from lkDpxTuningExpAnalysis
    narginchk(1,1);
    [is,whynot] = dpxdIs(D);
    if ~is
        error(whynot)
    end
    

    

    
    % Split D into a struct per cell recorded in each separate file (this
    % means that if the same cell was recorded in multiple files, they
    % will show up as separate units regardless, if this is a very common
    % tghing, we have to think up a way to merge them!
    C = dpxdSplit(D,'fileCellId');
    
    % calculate all Direction-Indices for phi (DIphi) and reverse phi
    % (DIihp) for each cell in each file
    DI.phi = [];
    DI.ihp = [];
    for i = 1:numel(C)
        [PHI,IHP] = dpxdSubset(C{i},strcmpi(C{i}.motType,'phi'));
       % mxPhi = max(PHI.meanDFoF{1});
       % mnPhi = min(PHI.meanDFoF{1});
       % mxIhp = max(IHP.meanDFoF{1});
       % mnIhp = min(IHP.meanDFoF{1});
        DI.phi(end+1) = diff(PHI.meanDFoF{1});
        DI.ihp(end+1) = diff(IHP.meanDFoF{1});
    end
    
    % plot the correlatiopn between DI.phi and DI.ihp. We hypothesize this
    % should be negative (because tuning to PHI and IHP should have
    % different sign)
    dpxFindFig(mfilename);
    plot(DI.phi,DI.ihp,'b.');
    axis equal
    a = axis;
    dpxPlotHori(0,'k--');
    dpxPlotVert(0,'k--');
    h = refline;
    axis(a);
    set(h,'Color','r','LineWidth',2);
    [r,pVal]=corr(DI.phi(:),DI.ihp(:));
    h = dpxText({['Pearson r = ' num2str(r,'%.2f')],['N = ' num2str(numel(DI.phi))],['p = ' num2str(pVal,'%.3f')]});
    set(h,'FontSize',10)
    xlabel('phi[\theta] - phi[\theta+180] (\DeltaF/F)','FontSize',14);
    ylabel('revPhi[\theta] - revPhi[\theta+180] (\DeltaF/F)','FontSize',14);
    keyboard
    
        
end