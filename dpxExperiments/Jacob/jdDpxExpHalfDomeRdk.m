function jdDpxExpHalfDomeRdk(fullscreen)
    if nargin==0
        fullscreen=false;
    end
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.physScr.skipSyncTests=0;
    E.nRepeats=10;
    if fullscreen
        wid=1920;
        hei=1080;
        E.windowed([wid 0 wid*2 hei]);
    else
        E.windowed(true);
    end
    C=dpxCoreCondition;
    C.durSec=10;
    S=dpxStimHalfDomeRdk;
    S.nClusters=1000;
    S.durSec=10;
    C.addStim(S);
    E.addCondition(C);
    E.run;
end