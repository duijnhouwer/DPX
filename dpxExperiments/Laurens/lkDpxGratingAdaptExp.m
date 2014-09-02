function lkDpxGratingAdaptExp
    E=dpxCoreExperiment;
    E.expName='lkDpxGratingAdaptExp';
    E.physScr.distMm=290;
    % 2014-4-24: Measured luminance BENQ screen Two-Photon room
    % Brightness 0; contrast 50; black eq 15; color temp [R G B] correction = [0
    % 100 100] blur reduction OFF; dynamic contrast 0 Resolution 1920x1080 60
    % Hz VGA connected
    % With these settings. FullWhite=33.6 cd/m2; FullBlack=0.053; and with
    % gamma 0.69, medium gray (index 127) = 16.96 cd/m2
    %
    E.physScr.gamma=0.69;
    E.physScr.backRGBA=[.25 .25 .25 1];
    E.windowed(true) ; % [0 0 810 610]+100); % true, false
    E.txtStart='asd DAQ-pulse';
    E.txtEnd='asd DAQ-pulse';
    E.txtPauseNrTrials=0;
    %
    % Settings
    % Adap
    adapDirDeg=45;
    adapContrastFracs=.5;
    adapCyclesPerDeg=.1;
    adapCyclesPerSecond=1;
    % Test
    testDirDegs=[0:22.5:360-22.5];
    testContrastFracs=.5;%[.25 .5 1];
    testCyclesPerDeg=.1;%[.05 .1 .2];
    testCyclesPerSecond=1;%[.5 1 2];
    % Timing
    E.nRepeats=2;
    itiaSec=2;
    adapSec=5;
    blankSec=2;
    testSec=2;
    itibSec=2;
    totalSec=itiaSec+adapSec+blankSec+testSec+itibSec;
    %
    nrTrials=numel(testDirDegs) * numel(testContrastFracs) * numel(testCyclesPerDeg) * numel(testCyclesPerSecond) * E.nRepeats;
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(totalSec)+10)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(totalSec) ' s + 10 s)']);
    %
    for direc=testDirDegs(:)'
        for cont=testContrastFracs(:)'
            for sf=testCyclesPerDeg(:)'
                for tf=testCyclesPerSecond(:)'
                    C=dpxCoreCondition;
                    C.durSec=totalSec;
                    %
                    % Add the adaptation stimulus
                    S=dpxStimGrating;
                    S.name='adap';
                    %
                    S.wDeg=45;
                    S.dirDeg=adapDirDeg;
                    S.cyclesPerSecond=adapCyclesPerSecond;
                    S.cyclesPerDeg=adapCyclesPerDeg;
                    S.contrastFrac=adapContrastFracs;
                    S.grayFrac=.25;
                    S.squareWave=true;
                    S.maskStr='circle';
                    S.maskPars=2;
                    S.onSec=itiaSec;
                    S.durSec=adapSec;
                    C.addStim(S);
                    %
                    % Add the test stimulus
                    S=dpxStimGrating;
                    S.name='test';
                    %
                    S.wDeg=45;
                    S.dirDeg=direc;
                    S.cyclesPerSecond=tf;
                    S.cyclesPerDeg=sf;
                    S.contrastFrac=cont;
                    S.grayFrac=.25;
                    S.squareWave=true;
                    S.maskStr='circle';
                    S.maskPars=2;
                    S.onSec=itiaSec+adapSec+blankSec;
                    S.durSec=testSec;
                    C.addStim(S);
                    %
                    E.addCondition(C);
                    
                end
            end
        end    
    end
    E.run;
end
