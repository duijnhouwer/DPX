function lkDpxTuningExpPopAnalysisTest

   
    DPXD=dpxdLoad('F:\Data\Processed\imagingdata\20151102\xyt01\lkDpxTuningExpAnalysis_output.mat');

    rayleighPmax=0.6;    
    
    % plot tuning curves aligned to phi motion tuning curve (PHI)
    dpxFindFig('phi vs reverse-phi');
    subplot(2,3,1);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'alignTo','PHI','rayleighPmax',rayleighPmax);
    title('Aligned to PHI');
    subplot(2,3,2);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'alignTo','IHP','rayleighPmax',rayleighPmax);
    title('Aligned to IHP');
    subplot(2,3,3);
    nrBootstraps=5;
    for i=1:nrBootstraps
        lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'shuffle',true,'rayleighPmax',rayleighPmax);
        title('DATA COMPLETELY SHUFFLED!!!!');
    end
    dpxText(['nrBootstraps=' num2str(nrBootstraps)]);
   
    subplot(2,3,[4 6]);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'plotRayleighP',true,'rayleighPmax',rayleighPmax);
    dpxSubplotLabels
end
