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
    E.windowed(true) ; % [0 0 810 610]+100); % true, false
    E.txtStart='<cut this>DAQ-pulse';
    E.txtEnd='<cut this>DAQ-pulse';
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
    dirDegs=0:45:315;
    contrastFracs=.5;%[.25 .5 1];
    cyclesPerDeg=.1;%[.05 .1 .2];
    cyclesPerSecond=1;%[.5 1 2];
    E.nRepeats=2;
    stimSec=4;
    isiSec=4;
    %
  %
    for direc=dirDegs(:)'
        for cont=contrastFracs(:)'
            for sf=cyclesPerDeg(:)'
                for tf=cyclesPerSecond(:)'
                    C=dpxCoreCondition;
                    C.durSec=stimSec+isiSec;
                    %
                    S=dpxStimGrating;
                    S.name='grating';
                    S.wDeg=45;
                    S.dirDeg=direc;
                    S.cyclesPerSecond=tf;
                    S.cyclesPerDeg=sf;
                    S.contrastFrac=cont;
                    S.grayFrac=.25;
                    S.squareWave=true;
                    S.onSec=isiSec/2;
                    S.durSec=stimSec;
                    %
                    M=dpxStimMask;
                    M.wDeg=45;
                    M.hDeg=45;
                    M.name='mask';
                    M.pars=2;
                    M.grayFrac=.25;
                    %
                    C.addStim(M);
                    C.addStim(S);
                    %
                    E.addCondition(C);
                end
            end
        end    
    end
    nrTrials=numel(E.conditions)*E.nRepeats;
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+10)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + 10 s)']);
    E.run;
end
