function jdDpxExpHalfDomeRdkRevPhi(debug)
    % Jacob, 2015-07-26
    if nargin==0
        debug=false;
    end
    E=dpxCoreExperiment;
    E.paradigm=mfilename;
    E.scr.verbosity0min5max=1;
    E.scr.backRGBA=[.25 0 0 1];
    E.scr.distMm=600;
    if IsLinux
        E.outputFolder='/data/vanwezeldata/dpxData';
        E.scr.winRectPx=[1920 0 1920+1920 1080];
        E.scr.skipSyncTests=0;
        E.scr.gamma=0.25;
    else
        if debug
            E.scr.winRectPx=[0 0 600 400];
        else
            E.scr.winRectPx=[0 0 1920 1080];
        end
        E.scr.skipSyncTests=1;
        E.scr.gamma=1;
    end
    E.nRepeats=3;
    
    motSec=2;
    lum=.15;
    degPerSec=18;
    for startSec=[1 2]
        for freezeFlip=[-7:7 -0.1 0.1];
            for invertSteps=[Inf 1] % phi, reverse phi
                
                C=dpxCoreCondition;
                C.durSec=startSec+motSec+2;
                C.overrideBackRGBA=[lum lum lum 1];
                %
                % mask
                M=dpxStimMaskTiff;
                M.name='mask';
                M.RGBAfrac=[lum lum lum 1];
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
                S.dotDiamPx=7;
                if freezeFlip<=-1
                    S.nSteps=1;
                    S.aziDps=-degPerSec;
                    S.freezeFlip=abs(freezeFlip);
                    S.invertSteps=invertSteps;
                elseif freezeFlip>=1
                    S.nSteps=1;
                    S.aziDps=degPerSec;
                    S.freezeFlip=abs(freezeFlip);
                    S.invertSteps=invertSteps;
                else % -0.1 0 0.1
                    S.nSteps=Inf;
                    S.aziDps=degPerSec*freezeFlip*10;
                    S.freezeFlip=1;
                    S.invertSteps=Inf;
                end
                S.motStartSec=startSec;
                S.motDurSec=motSec;
                S.RGBAfrac1=[0 0 0 1];
                S.RGBAfrac2=[[lum lum lum]*2 1];
                %
                C.addStim(M);
                C.addStim(S);
                %
                if IsLinux
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
                    R2.defaultX=1920/2;
                    R2.defaultY=1080/2;
                    R2.allowUntilSec=C.durSec;
                    C.addResp(R2);
                end
                %
                E.addCondition(C);
            end
        end
    end
    blockDurSec=0;
    for i=1:numel(E.conditions)
        blockDurSec=blockDurSec+E.conditions{i}.durSec+.1;
    end
    disp([num2str(E.nRepeats) ' blocks will take approx. ' dpxSeconds2readable(blockDurSec*E.nRepeats)]);
    E.run;
end