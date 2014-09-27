function jdDpxExpHalfDomeRdk(fullscreen)
    if nargin==0
        fullscreen=false;
    end
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.scr.skipSyncTests=1;
    E.scr.backRGBA=[0 0 0 1];
    E.nRepeats=10;
    if fullscreen
        if IsLinux
            wid=1920;
            hei=1080;
            E.windowed([wid 0 wid*2 hei]);
        else
            E.windowed(false);
        end
    else
        E.windowed(true);
    end
    C=dpxCoreCondition;
    C.durSec=10;
    % mask
    M=dpxStimMask;
    M.typeStr='halfdome';
    M.pars=[600 50];
    M.grayFrac=0;
    M.wDeg=60;
    M.hDeg=60;
    M.yDeg=-5;
    C.addStim(M);
    E.addCondition(C);
    % dot stimulus
    S=dpxStimHalfDomeRdk;
    S.nClusters=1000;
    C.addStim(S);
    % gray field
    F=dpxStimRect;
    F.wDeg=50;
    F.hDeg=50;
    F.RGBAfrac=[.5 .5 .5 1];
    C.addStim(F);
    %
    E.run;
end