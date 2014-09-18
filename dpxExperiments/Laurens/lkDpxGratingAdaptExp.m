function lkDpxGratingAdaptExp
    E=dpxCoreExperiment;
    E.expName='lkDpxGratingAdaptExp';
    % Screen settings:
    set(E.physScr,'winRectPx',[0 0 1920 1080],'widHeiMm',[531 298] ...
        ,'distMm',290,'interEyeMm',10,'gamma',.69,'backRGBA',[0.25 0.25 0.25 1] ...
        ,'stereoMode','mono','skipSyncTests',1,'verbosity0min5max',1);
    % 2014-4-24: Measured luminance BENQ XL2420Z screen Two-Photon room
    % Brightness 0; contrast 50; black eq 15; color temp [R G B] correction = [0
    % 100 100] blur reduction OFF; dynamic contrast 0 Resolution 1920x1080 60
    % Hz VGA connected.  With these settings. FullWhite=33.6 cd/m2; FullBlack=0.053; and with
    % gamma 0.69, medium gray (index 127) = 16.96 cd/m2
    %
    % Set these strings to 'DAQ-pulse' to start the experiment when a the
    % Leica microscope gives a pulse.
    E.txtStart='asd DAQ-pulse';
    E.txtEnd='asd DAQ-pulse';
    E.txtPauseNrTrials=0;
    %
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
    % Shared
    diamDeg=45;
    contrastFadeAtEdgeRampLengthDeg=1;
    grayLevelFractionOfMaxRange=0.25;
    % Timing
    initialAdapSec=2;
    itiaSec=2;
    topupSec=5;
    blankSec=2;
    testSec=2;
    itibSec=2;
    %
    E.nRepeats=2;
    %
    firstTrialSec=itiaSec + initialAdapSec + itibSec;
    topupTrialSec=itiaSec + topupSec + blankSec + testSec + itibSec;
    nrTestConditions=numel(testDirDegs) * numel(testContrastFracs) * numel(testCyclesPerDeg) * numel(testCyclesPerSecond);
    nrTrials=nrTestConditions * E.nRepeats + 1; % + 1 to account for the long adaptation trial
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(topupTrialSec)+initialAdapSec+itibSec+10)) ' s recording pattern in LasAF.']);
    %
    % Create the one initial adaptation condition
    %
    C=dpxCoreCondition;
    C.durSec=firstTrialSec;
    % Add the adaptation stimulus
    S=dpxStimGrating;
    S.name='adap';
    S.wDeg=diamDeg;
    S.dirDeg=adapDirDeg;
    S.cyclesPerSecond=adapCyclesPerSecond;
    S.cyclesPerDeg=adapCyclesPerDeg;
    S.contrastFrac=adapContrastFracs;
    S.grayFrac=grayLevelFractionOfMaxRange;
    S.squareWave=true;
    S.maskStr='circle';
    S.maskPars=contrastFadeAtEdgeRampLengthDeg;
    S.onSec=itiaSec;
    S.durSec=initialAdapSec;
    gratingdefaults=get(S);% copy all properties of adap stim
    C.addStim(S);
    %
    E.addCondition(C);
    %
    % Create all topup-conditions
    %
    for direc=testDirDegs(:)'
        for cont=testContrastFracs(:)'
            for sf=testCyclesPerDeg(:)'
                for tf=testCyclesPerSecond(:)'
                    C=dpxCoreCondition;
                    C.durSec=topupTrialSec;
                    %
                    % Add the adaptation stimulus
                    S=dpxStimGrating;
                    set(S,gratingdefaults);
                    S.name='adap';
                    S.durSec=topupSec;
                    C.addStim(S);
                    %
                    % Add the test stimulus
                    S=dpxStimGrating;
                    set(S,gratingdefaults);
                    S.name='test';
                    S.dirDeg=direc;
                    S.cyclesPerSecond=tf;
                    S.cyclesPerDeg=sf;
                    S.contrastFrac=cont;
                    S.onSec=itiaSec+topupSec+blankSec;
                    S.durSec=testSec;
                    C.addStim(S);
                    %
                    E.addCondition(C);                
                end
            end
        end    
    end
    % Create the condition sequence
    % Default behavior is to let DPX make a new random order of conditions
    % list per block (repetition) and no sequence needs to be provided.
    % In this experiment, we want to start with a long adaptation trial,
    % which needs to be the very first trial of the experiment, and should
    % not be repeated in subsequent block
    seq=1; % the initial long adaptation condition
    for i=1:E.nRepeats
        seq=[seq randperm(nrTestConditions-1)+1 ];
    end
    E.conditionSequence=seq;
    E.run;
end
