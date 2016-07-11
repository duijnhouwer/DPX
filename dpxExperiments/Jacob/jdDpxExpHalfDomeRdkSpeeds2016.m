function jdDpxExpHalfDomeRdkSpeeds2016
    E=dpxCoreExperiment;
    E.paradigm='jdDpxExpHalfDomeRdk';
    E.outputFolder='/data/vanwezeldata/dpxData';
    E.window.skipSyncTests=0;
    E.window.verbosity0min5max=1;
    E.window.backRGBA=[.5 .5 .5 1];
    E.window.distMm=600;
    if IsLinux
        E.window.rectPx=[1920 0 1920+1920 1080];
        E.window.gamma=0.25;
    else
        E.window.rectPx=[20 20 800 600];
        E.window.gamma=1;
    end
    E.nRepeats=10;
    
    motSec=2;
    for startSec=[1 2]
        for dps=[-72 -63 -54 -45 -36 -24 -18 -9 0 9 18 24 36 45 54 63 72]
            
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
            S.nClusters=560;
            S.clusterRadiusDeg=.9;
            S.dAdEdeg=[ sind(90:90:360)*.5 sind(30:30:360) ;  cosd(90:90:360)*.5 cosd(30:30:360)];
            S.dotDiamPx=6;
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
            C.addStimulus(M);
            C.addStimulus(S);
            %C.addStimulus(F);
            %
            if IsLinux
                R1=dpxRespContiMouse;
                R1.name='mouseBack';
                R1.doReset=false;
                R1.mouseId=9;
                R1.defaultX=1920;
                R1.defaultY=1080/2;
                R1.allowUntilSec=C.durSec;
                C.addResponse(R1);
                %
                R2=dpxRespContiMouse;
                R2.name='mouseSide';
                R2.doReset=true;
                R2.mouseId=12;
                R2.defaultX=1920;
                R2.defaultY=1080/2;
                R2.allowUntilSec=C.durSec;
                C.addResponse(R2);
            end
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