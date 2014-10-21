function jdDpxExpHalfDomeRdk
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.scr.skipSyncTests=1;
    E.scr.backRGBA=[0 0 0 1];
    E.scr.distMm=600;
    E.nRepeats=10;
    C=dpxCoreCondition;
    C.durSec=1000;
    % half-circular mask
    M=dpxStimMask;
    M.typeStr='halfdome';
    M.pars=[900 2000 -290 30];
    M.grayFrac=0;
    M.wDeg=80;%30;
    M.hDeg=80;%60;
    M.yDeg=6;
    C.addStim(M);
    E.addCondition(C);
    % dot stimulus
    S=dpxStimHalfDomeRdk;
    S.nClusters=1000;
    C.addStim(S);
    % gray background field
    F=dpxStimRect;
    F.wDeg=70;
    F.hDeg=60;
    F.RGBAfrac=[1 .2 .2 1];
    C.addStim(F);
    %
    R1=dpxRespContiMouse;
    R1.name='mouse1';
    R1.mouseId=9;
    R1.defaultX=1920;
    R1.defaultY=1080/2;
    C.addResp(R1);
    %
    R2=dpxRespContiMouse;
    R2.name='mouse2';
    R2.mouseId=11;
    R2.defaultX=1920;
    R2.defaultY=1080/2;
    C.addResp(R2);
    %
    E.run;
end