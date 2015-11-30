function lkDpxRdkExp
    E=dpxCoreExperiment;
    E.paradigm='lkDpxRdkExp';
    E.window.distMm=290;
    % 2014-10-28: Measured luminance BENQ screen Two-Photon room Brightness
    % 0; contrast 50; black eq 15; color temp [R G B] correction = [0 100
    % 100] blur reduction OFF; dynamic contrast 0 Resolution 1920x1080 60
    % Hz; Reset Color no; AMA high, Instant OFF, Sharpness 1; Dynamic
    % Contrast 0; Display mode Full; Color format RGB; Smartfocus OFF;
    % connected with a VGA cable (so that we can split to Beetronixs
    % Screen) With these settings.
    % FullWhite=42 cd/m2; FullBlack=0.12;
    % and with gamma 1, medium gray (RGB .5 .5 .5) = 21 cd/m2
    %
    E.paradigm='lkDpxGratingExp';
    E.window.distMm=lkSettings('VIEWDISTMM');
    E.window.widHeiMm=lkSettings('SCRWIDHEIMM');
    E.window.gamma=lkSettings('GAMMA');
    E.window.backRGBA=lkSettings('BACKRGBA');
    E.window.verbosity0min5max=lkSettings('VERBOSITY');
    E.window.rectPx=lkSettings('WINPIX');
    E.window.skipSyncTests=lkSettings('SKIPSYNCTEST');
    if IsLinux
        E.txtStart='DAQ-pulse';
    else
        E.txtStart='asd DAQ-pulse';
    end
    E.txtEnd='';
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
    stepDeg=360/lkSettings('NRDIRECS');
    dirDegs=[0:stepDeg:360-stepDeg];
    contrastFracs=[.1 .2 .5 1];
    grayFrac=E.window.backRGBA(1); % mid level gray of the grating. background has same graylevel. (assume R=G=B!)
    speeds=20; % based on a cyc/sec & cyc/deg settings in lkDpxGratingExp (1/0.05)
    E.nRepeats=6;
    stimSec=lkSettings('stimSec');
    isiSec=lkSettings('isiSec');
    
    for d=1:numel(dirDegs)
        direc=dirDegs(d);
        for c=1:numel(contrastFracs)
            contrast=contrastFracs(c);
            for s=1:numel(speeds)
                speed=speeds(s);
                %
                C=dpxCoreCondition;
                C.durSec=stimSec+isiSec;    
                %
                S=dpxStimRdk;
                S.name='test';
                S.wDeg=lkSettings('STIMDIAM');
                S.hDeg=S.wDeg;
                S.dirDeg=direc;
                S.speedDps=speed;
                S.dotsPerSqrDeg=.01;
                S.dotDiamDeg=2;
                S.nSteps=Inf; % unlimited lifetime
                % calculate the luminance based on the grayFrac and the contrast values
                bright=grayFrac+grayFrac*contrast;
                dark=grayFrac-grayFrac*contrast;
                S.dotRBGAfrac1=[bright bright bright 1]; % witte stippen
                S.dotRBGAfrac2=[dark dark dark 1]; % zwarte stippen
                S.onSec=isiSec/2;
                S.durSec=stimSec;
                %
                M=dpxStimMaskCircle;
                M.name='mask';
                M.wDeg=S.wDeg*sqrt(2)+1;
                M.hDeg=S.hDeg*sqrt(2)+1;
                M.outerDiamDeg=S.wDeg;
                M.innerDiamDeg=S.wDeg-15;
                M.RGBAfrac=E.window.backRGBA;
                %
                V=dpxStimMccAnalogOut;
                V.name='mcc';
                V.onSec=0;
                V.durSec=C.durSec;
                V.initVolt=0;
                V.stepSec=[S.onSec S.onSec+S.durSec];
                V.stepVolt=[4 0];
                V.pinNr=lkSettings('MCCPIN');
                %
                MCC=dpxRespMccCounter;
                MCC.name='mcc';
                MCC.allowUntilSec=C.durSec;
                %
                C.addStim(M);
                C.addStim(S);
                if IsLinux % lab computer is linux, only use MCC there
                    C.addStim(V);
                    C.addResp(MCC);
                end
                %
                E.addCondition(C);
            end
        end
    end
    nrTrials=numel(E.conditions) * E.nRepeats;
    xtr=lkSettings('2PHOTONEXTRASECS');
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+xtr)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + ' num2str(xtr) ' s)']);
    E.run;
end
