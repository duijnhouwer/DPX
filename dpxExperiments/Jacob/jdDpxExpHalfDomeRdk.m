function jdDpxExpHalfDomeRdk
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.scr.skipSyncTests=1;
    E.scr.backRGBA=[.5 .5 .5 1];
    E.scr.distMm=600;
    E.scr.winRectPx=[0 0 1920 1080];
    E.scr.gamma=.33;
    E.nRepeats=10;
    
    motSec=1.5;
    for startSec=[.5 .75 1 1.25 1.5]
        for dps=[-180 -60 -20 0 20 60 180]
            
            C=dpxCoreCondition;
            C.durSec=1+startSec+motSec+0.5;
            %
            % mask
            M=dpxStimMaskTiff;
            M.name='mask';
            M.filename='mask20141030.tif';
            M.dstRectPx='fullscreen';
            M.blurPx=100;
            S.onSec=-1;
            %
            % dot stimulus
            S=dpxStimHalfDomeRdk;
            S.name='rdk';
            S.lutFileName='HalfDomeWarpLut20141030.mat';
            S.nClusters=1000;
            S.dotDiamPx=4;
            S.aziDps=dps;
            S.nSteps=Inf;
            S.motStartSec=startSec;
            S.motDurSec=motSec;
            S.onSec=-1;         
            %
            % gray background field
            F=dpxStimRect;
            F.wDeg=70;
            F.hDeg=60;
            F.RGBAfrac=[.5 .5 .5 1];
            %
            C.addStim(M);
            C.addStim(S);
            %C.addStim(F);
            %
            R1=dpxRespContiMouse;
            R1.name='mouse1';
            R1.mouseId=1;%9
            R1.defaultX=1920;
            R1.defaultY=1080/2;
            C.addResp(R1);
            %
            R2=dpxRespContiMouse;
            R2.name='mouse2';
            R2.mouseId=1;%11
            R2.defaultX=1920;
            R2.defaultY=1080/2;
            C.addResp(R2);
            %
            E.addCondition(C);
        end
    end
    blockDurSec=0;
    for i=1:numel(E.conditions)
        blockDurSec=blockDurSec+E.conditions{i}.durSec;
    end
    disp(['A block of all conditions will take ' dpxSeconds2readable(blockDurSec)]);
    disp([num2str(E.nRepeats) ' blocks will take ' dpxSeconds2readable(blockDurSec*E.nRepeats)]);
    E.run;
end