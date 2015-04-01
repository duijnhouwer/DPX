function lkDpxGratingAdaptExp
    E=dpxCoreExperiment;
    E.expName='lkDpxGratingAdaptExp';
    % Screen settings:
    set(E.scr,'winRectPx',[0 0 192 108],'widHeiMm',[531 298] ...
        ,'distMm',290,'interEyeMm',10,'gamma',.69,'backRGBA',[0.1 0.1 0.1 1] ...
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
    E.txtEnd='';
    E.txtPauseNrTrials=0;
    %
    % Adap
    adapDirDeg=45;
    adapContrastFracs=.8;
    adapCyclesPerDeg=.05;
    adapCyclesPerSecond=1;
    % Test
    testDirDegs=[0:22.5:360-22.5];
    testContrastFracs=.8;%[.25 .5 1];
    testCyclesPerDeg=.05;%[.05 .1 .2];
    testCyclesPerSecond=1;%[.5 1 2];
    % Shared
    diamDeg=45;
    contrastFadeAtEdgeRampLengthDeg=1;
    grayLevelFractionOfMaxRange=0.25;
    % Timing
    initialAdapSec=40;
    itiaSec=2;
    topupSec=6;
    blankSec=2;
    testSec=4;
    itibSec=0;
    %
    E.nRepeats=6;
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
    A=dpxStimGrating;
    A.name='adap';
    A.wDeg=diamDeg;
    A.dirDeg=adapDirDeg;
    A.cyclesPerSecond=adapCyclesPerSecond;
    A.cyclesPerDeg=adapCyclesPerDeg;
    A.contrastFrac=adapContrastFracs;
    A.grayFrac=grayLevelFractionOfMaxRange;
    A.squareWave=true;
    %S.maskStr='circle';
    %S.maskPars=contrastFadeAtEdgeRampLengthDeg;
    A.onSec=itiaSec;
    A.durSec=initialAdapSec;
    gratingDefaults=get(A);% copy all properties of adap stim
    %
    M=dpxStimMaskCircle;
    M.name='mask';
    M.wDeg=A.wDeg*sqrt(2)+1;
    M.hDeg=A.wDeg*sqrt(2)+1;
    M.outerDiamDeg=A.wDeg;
    M.innerDiamDeg=A.wDeg-5;
    M.RGBAfrac=[.1 .1 .1 1];
    maskDefaults=get(M);
    %
    V=dpxStimMccAnalogOut;
    V.name='mcc';
    V.onSec=0;
    V.durSec=C.durSec;
    V.initVolt=0;
    V.stepSec=[A.onSec A.onSec+A.durSec];
    V.stepVolt=[3 0];
    V.pinNr=13;
    %
    C.addStim(V);
    C.addStim(M);                
    C.addStim(A);
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
                    A=dpxStimGrating;
                    set(A,gratingDefaults);
                    A.name='adap';
                    A.durSec=topupSec;
                    %
                    % Add the test stimulus
                    T=dpxStimGrating;
                    set(T,gratingDefaults);
                    T.name='test';
                    T.dirDeg=direc;
                    T.cyclesPerSecond=tf;
                    T.cyclesPerDeg=sf;
                    T.contrastFrac=cont;
                    T.onSec=itiaSec+topupSec+blankSec;
                    T.durSec=testSec;
                    % 
                    % Add the mask
                    M=dpxStimMaskCircle;
                    set(M,maskDefaults);
                    M.name='maskadapt';
                    M.wDeg=A.wDeg*sqrt(2)+1;
                    M.hDeg=A.wDeg*sqrt(2)+1;
                    M.outerDiamDeg=A.wDeg;
                    M.innerDiamDeg=A.wDeg-5;
                    M.RGBAfrac=[.1 .1 .1 1];
                    %
                    % Add the MCC stim
                    V=dpxStimMccAnalogOut;
                    V.name='mcc';
                    V.onSec=0;
                    V.durSec=C.durSec;
                    V.initVolt=0;
                    V.stepSec=[A.onSec A.onSec+A.durSec  T.onSec T.onSec+T.durSec];
                    V.stepVolt=[3 0 4 0];
                    V.pinNr=13;
                    %
                    C.addStim(V)
                    C.addStim(M);
                    C.addStim(A);
                    C.addStim(T);
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
