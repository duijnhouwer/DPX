function lkDpxGratingAdaptExp
    E=dpxCoreExperiment;
    E.expName='lkDpxGratingAdaptExp';
    % Screen settings:
    
    E.expName='lkDpxGratingExp';
    E.scr.distMm=lkSettings('VIEWDISTMM');
    E.scr.widHeiMm=lkSettings('SCRWIDHEIMM');
    E.scr.gamma=lkSettings('GAMMA');
    E.scr.backRGBA=lkSettings('BACKRGBA');
    E.scr.verbosity0min5max=lkSettings('VERBOSITY');
    E.scr.winRectPx=lkSettings('WINPIX');
    E.scr.skipSyncTests=lkSettings('SKIPSYNCTEST');
    %
    E.txtStart='DAQ-pulse';
    E.txtEnd='';
    E.txtPauseNrTrials=0;
    %
    % Adap
    adapDirDeg=45;
    adapContrastFracs=1.0;
    adapCyclesPerDeg=.05;
    adapCyclesPerSecond=1;
    % Test
    testDirDegs=lkSettings('TESTDIRS');
    testContrastFracs=1.0;%[.25 .5 1];
    testCyclesPerDeg=.05;%[.05 .1 .2];
    testCyclesPerSecond=1;%[.5 1 2];
    % Shared
    diamDeg=65;
    contrastFadeAtEdgeRampLengthDeg=1;
    % Timing
    testSec=lkSettings('stimSec');
    initialAdapSec=testSec*10;
    itiaSec=testSec/2;
    topupSec=testSec*1.5;
    blankSec=testSec/2;
    itibSec=0;
    %
    E.nRepeats=1;
    %
    firstTrialSec=itiaSec + initialAdapSec + itibSec;
    topupTrialSec=itiaSec + topupSec + blankSec + testSec + itibSec;
    %
    % Create the one initial adaptation condition
    %
    C=dpxCoreCondition;
    C.durSec=firstTrialSec;
    % Add the adaptation stimulus
    A=dpxStimGrating;
    A.name='adap';
    A.wDeg=65;
    A.hDeg=A.wDeg;
    A.dirDeg=adapDirDeg;
    A.cyclesPerSecond=adapCyclesPerSecond;
    A.cyclesPerDeg=adapCyclesPerDeg;
    A.contrastFrac=adapContrastFracs;
    A.grayFrac=E.scr.backRGBA(1);
    A.squareWave=true;
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
    M.RGBAfrac=E.scr.backRGBA;
    maskDefaults=get(M);
    %
    V=dpxStimMccAnalogOut;
    V.name='mcc';
    V.onSec=0;
    V.durSec=C.durSec;
    V.initVolt=0;
    V.stepSec=[A.onSec A.onSec+A.durSec];
    V.stepVolt=[3 0];
    V.pinNr=lkSettings('MCCPIN');
    %
    C.addStim(V);
    C.addStim(M);                
    C.addStim(A);
    %
    E.addCondition(C);
    %
    % Create all topup-conditions
    %
    nrTestConditions=0;
    for direc=testDirDegs(:)'
        for cont=testContrastFracs(:)'
            for sf=testCyclesPerDeg(:)'
                for tf=testCyclesPerSecond(:)'
                    %
                    nrTestConditions=nrTestConditions+1;
                    %
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
                    V.pinNr=lkSettings('MCCPIN');
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
        seq=[seq randperm(nrTestConditions)+1 ]; %#ok<AGROW>
    end
    E.conditionSequence=seq;
    expDur=0;
    for i=1:numel(seq)
        expDur=expDur+E.conditions{seq(i)}.durSec;
    end
    xtr=lkSettings('2PHOTONEXTRASECS');
    dpxDispFancy(['Please set-up a ' num2str(expDur+xtr) ' s recording pattern in LasAF.']);
    E.run;
end
