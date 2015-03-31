function jdDpxExpHalfDomeRdk
    E=dpxCoreExperiment;
    E.expName='jdDpxExpHalfDomeRdk';
    E.outputFolder='/data/vanwezeldata/dpxData';
    E.scr.skipSyncTests=0;
    E.scr.verbosity0min5max=1;
    E.scr.backRGBA=[.5 .5 .5 1];
    E.scr.distMm=600;
    E.scr.winRectPx=[1920 0 1920+1920 1080];
    E.scr.gamma=0.25;
    E.nRepeats=15;
    
    motSec=2;
    for startSec=[1 2]
        for dps=[-120 -40 -10 0 10 40 120]
            
            C=dpxCoreCondition;
            C.durSec=startSec+motSec+1;
            %
            % mask
            M=dpxStimMaskTiff;
            M.name='mask';
            M.filename='mask20141030.tif';
            M.dstRectPx='fullscreen';
            M.blurPx=100;
            M.onSec=-1;
            %
            % dot stimulus
            S=dpxStimHalfDomeRdk;
            S.name='rdk';
            S.lutFileName='HalfDomeWarpLut20141030.mat';
            S.nClusters=1000;
            S.clusterRadiusDeg=1;
            S.dotDiamPx=4;
            S.aziDps=dps;
            S.nSteps=Inf;
            S.motStartSec=startSec;
            S.motDurSec=motSec;
            S.onSec=0;         
            %
            % gray background field
           %5 F=dpxStimRect;
           % F.wDeg=70;
           % F.hDeg=60;
           % F.RGBAfrac=[.5 .5 .5 1];
            %
            C.addStim(M);
            C.addStim(S);
            %C.addStim(F);
            %
            R1=dpxRespContiMouse;
            R1.name='mouseBack';
            R1.doReset=false;
            R1.mouseId=9;
            R1.defaultX=1920;
            R1.defaultY=1080/2;
            R1.allowUntilSec=C.durSec;
            C.addResp(R1);
            %
            R2=dpxRespContiMouse;
            R2.name='mouseSide';
            R2.doReset=true;
            R2.mouseId=12;
            R2.defaultX=1920;
            R2.defaultY=1080/2;
            R2.allowUntilSec=C.durSec;
            C.addResp(R2);
            %
            E.addCondition(C);
        end
    end
    blockDurSec=0;
    for i=1:numel(E.conditions)
        blockDurSec=blockDurSec+E.conditions{i}.durSec+.1;
    end
    disp([num2str(E.nRepeats) ' blocks will take approx. ' dpxSeconds2readable(blockDurSec*E.nRepeats)]);
    E.run;
end