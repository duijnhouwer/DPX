function lkDpxGratingExp
    E=dpxCoreExperiment;
    E.expName='lkDpxGratingExp';
    E.scr.distMm=290;
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
    E.scr.gamma=1.0;
    E.scr.backRGBA=[.25 .25 .25 1];
    E.scr.verbosity0min5max=2;
    E.scr.winRectPx=[0 0 1920 1080] ;
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
    dirDegs=[0:22.5:360-22.5]; %[90]
    contrastFracs=[1.0];
    cyclesPerDeg=[0.05];
    cyclesPerSecond=[1];
    E.nRepeats=6;
    stimSec=4;
    isiSec=4;
    %
    for direc=dirDegs(:)'
        for cont=contrastFracs(:)'
            for sf=cyclesPerDeg(:)'
                for tf=cyclesPerSecond(:)'
                    C=dpxCoreCondition;
                    C.durSec=stimSec+isiSec;           
                    %
                    G=dpxStimGrating;
                    G.name='test';
                    G.wDeg=65;
                    G.hDeg=65;
                    G.dirDeg=direc;
                    G.cyclesPerSecond=tf;
                    G.cyclesPerDeg=sf;
                    G.contrastFrac=cont;
                    G.grayFrac=E.scr.backRGBA(1);
                    G.squareWave=true;
                    G.onSec=isiSec/2;
                    G.durSec=stimSec;
                    %
                    M=dpxStimMaskCircle;
                    M.name='mask';
                    M.wDeg=G.wDeg*sqrt(2)+1;
                    M.hDeg=G.wDeg*sqrt(2)+1;
                    M.outerDiamDeg=G.wDeg;
                    M.innerDiamDeg=G.wDeg-5;
                    M.RGBAfrac=E.scr.backRGBA;
                    %
                    V=dpxStimMccAnalogOut;
                    V.name='mcc';
                    V.onSec=0;
                    V.durSec=C.durSec;
                    V.initVolt=0;
                    V.stepSec=[G.onSec G.onSec+G.durSec];
                    V.stepVolt=[4 0];
                    V.pinNr=13;
                    %
                    MCC=dpxRespMccCounter;
                    MCC.name='mcc';
                    MCC.allowUntilSec=C.durSec;
                    %
                    C.addStim(M);
                    C.addStim(G);
                    if IsLinux % lab computer is linux, only use MCC there
                        C.addStim(V);
                        C.addResp(MCC);
                    end
                    %
                    E.addCondition(C);
                end
            end
        end    
    end
    nrTrials=numel(E.conditions) * E.nRepeats;
    voordezekerheid=120; % extra tijd ivm te vroeg stoppen Leica
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+voordezekerheid)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + ' num2str(voordezekerheid) ' s)']);
    E.run;
end
