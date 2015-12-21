function lkDpxTuningExpPopAnalysisTest
    
    DPXD=dpxdLoad('C:\Users\jacob\Dropbox\2photonlab\1) EXPERIMENT FILES\Reverse phi output files\lkDpxTuningExpAnalysis_output 20151012xyt02.mat');
   
    % plot tuning curves aligned to phi motion tuning curve (PHI)
    dpxFindFig('phi vs reverse-phi');
    subplot(2,3,1);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'alignTo','PHI');
    title('Aligned to PHI');
    subplot(2,3,2);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'alignTo','IHP');
    title('Aligned to IHP');
    subplot(2,3,3);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'randomize',true);
    title('DATA COMPLETELY SHUFFLED!!!!');
   
    subplot(2,3,[4 6]);
    lkDpxTuningExpPopAnalysis(DPXD,'figName',[],'plotRayleighP',true);
    dpxSubplotLabels
end
