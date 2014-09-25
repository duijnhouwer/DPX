function jdDpxExpHalfDomeRdk(fullscreen)
    if nargin==0
        fullscreen=false;
    end
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.physScr.skipSyncTests=1;
    E.windowed(~fullscreen); 
    C=dpxCoreCondition;
    C.durSec=10;
    S=dpxStimHalfDomeRdk;
    S.nClusters=1000;
    S.durSec=10;
    C.addStim(S);
    E.addCondition(C);
    E.run;
end