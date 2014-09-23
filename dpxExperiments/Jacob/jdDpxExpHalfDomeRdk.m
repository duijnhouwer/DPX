function jdDpxExpHalfDomeRdk
    
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.physScr.skipSyncTests=0;
    E.windowed(false);
    
    C=dpxCoreCondition;
    C.durSec=10;
    S=dpxStimHalfDomeRdk;
    S.nDots=10000;
    S.durSec=10;
    C.addStim(S);
    E.addCondition(C);
    E.run;
end