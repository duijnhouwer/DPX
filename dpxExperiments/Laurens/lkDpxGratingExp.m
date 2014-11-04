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
    E.scr.backRGBA=[.1 .1 .1 1];
    E.scr.verbosity0min5max=2;
    E.scr.winRectPx=[0 0 1920 1080] ;
    E.txtStart='DAQ-pulse'; 
    E.txtEnd='';
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
    dirDegs=[0:45:315];
    contrastFracs=[0.8];
    cyclesPerDeg=[0.1];
    cyclesPerSecond=[0.5 1 2];
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
                    G.name='grating';
                    G.wDeg=65;
                    G.dirDeg=direc;
                    G.cyclesPerSecond=tf;
                    G.cyclesPerDeg=sf;
                    G.contrastFrac=cont;
                    G.grayFrac=.25;
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
                    M.RGBAfrac=[.1 .1 .1 1];
                    %
                    V=dpxStimMccAnalogOut;
                    V.name='mcc';
                    V.onSec=0;
                    V.durSec=C.durSec;
                    V.channelOnSec=G.onSec;
                    V.channelDurSec=G.durSec;
                    V.Voff=0;
                    V.Von=4;
                    V.channelNr=0;
                    %
                    C.addStim(V);
                    C.addStim(M);
                    C.addStim(G);
                    %
                    MCC=dpxRespMccCounter;
                    MCC.name='mcc';
                    MCC.allowUntilSec=C.durSec;
                    C.addResp(MCC);
                    %
                    E.addCondition(C);
                end
            end
        end    
    end
    nrTrials=numel(E.conditions) * E.nRepeats;
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+10)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + 10 s)']);
    E.run;
end
