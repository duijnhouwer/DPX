function lkDpxGratingExp
    E=dpxCoreExperiment;
    E.expName='lkDpxGratingExp';
    E.scr.distMm=290;
    % 2014-4-24: Measured luminance BENQ screen Two-Photon room
    % Brightness 0; contrast 50; black eq 15; color temp [R G B] correction = [0
    % 100 100] blur reduction OFF; dynamic contrast 0 Resolution 1920x1080 60
    % Hz connected with a VGA cable.
    % With these settings. FullWhite=33.6 cd/m2; FullBlack=0.053; and with
    % gamma 0.69, medium gray (index 127) = 16.96 cd/m2
    %
    E.scr.gamma=0.69;
    E.scr.backRGBA=[.25 .25 .25 1];
    %E.scr.winRectPx=[0 0 1920 1080];
    E.scr.verbosity0min5max=1;
    E.scr.winRectPx=[0 0 1920 1080] ;
    E.txtStart='asd DAQ-pulse';  
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
    dirDegs=[0:45:315];
    contrastFracs=[1];
    cyclesPerDeg=[0.1 0.2];
    cyclesPerSecond=[0.5 1];
    E.nRepeats=10;
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
                    G.wDeg=45;
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
                    M.wDeg=45*sqrt(2)+1;
                    M.hDeg=45*sqrt(2)+1;
                    M.outerDiamDeg=45;
                    M.innerDiamDeg=43;
                    M.RGBAfrac=[.25 .25 .25 1];
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
