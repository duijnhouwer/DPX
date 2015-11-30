function agDpxExpOnlyVisual
    
    dpxDispFancy('Make sure only one keyboard is connected!','!',2,2);
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.paradigm=mfilename;
    E.outputFolder='/Users/iMac_2Photon/Desktop/AhmedData';
    E.startKey='UpArrow';
    
    testscr=[20 20 800 600];
    
    
    
    %     E.txtPause='Press and release $STARTKEY to start';
    %    E.txtPauseNrTrials=1;
    
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0+1680 0 1280+1680 960],'widHeiMm',[480 300], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',1);
    
    %[0+1680 0 1280+1680 960]
    % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio=[1.4]; %here is the aspect ratio
    flashSec=.35; %[.300 .400 .500 .750 1 ]
    nrSteps=10000;
    ddqWid=4;
    bottomLeftTopRightFirst=[true];%[true false];
    durS=62.5*2;
    ddqRightFromFix=-15;
    dotSize=1;
    conditionCounter=0;
    
    for ar=aRatio
        for fs=flashSec
            for b=bottomLeftTopRightFirst;
                for i=1:3
                    conditionCounter=conditionCounter+1;
                    C=dpxCoreCondition;
                    C.durSec=durS;
                    %
                    F=dpxStimDot;
                    % type get(F) to see a list of parameters you can set
                    set(F,'xDeg',0); % set the fix dot 10 deg to the left
                    set(F,'name','fix','wDeg',1);
                    C.addStim(F);
                    %
                    DDQ=dpxStimDynDotQrt;
                    set(DDQ,'name','ddq','wDeg',ddqWid,'hDeg',ddqWid*ar,'flashSec',fs);
                    set(DDQ,'oriDeg',0,'onSec',0.5,'durSec',fs*(nrSteps+1));
                    set(DDQ,'diamsDeg',[1 1 1 1]*dotSize);
                    set(DDQ,'bottomLeftTopRightFirst',b);
                    set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix)
                    C.addStim(DDQ);
                    %
                    if conditionCounter==1
                        % Add  a text stimulus
                        TEXT=dpxStimTextSimple;
                        TEXT.name='text';
                        TEXT.str=['Passive\nUpArrow to start ...'];
                        TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                        TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                    elseif conditionCounter==2
                        TEXT=dpxStimTextSimple;
                        TEXT.name='text';
                        TEXT.str=['Hold\nUpArrow to start ...'];
                        TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                        TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                    else
                        TEXT=dpxStimTextSimple;
                        TEXT.name='text';
                        TEXT.str=['Switch\nUpArrow to start ...'];
                        TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                        TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                    end
                    C.addStim(TEXT);
                    
                    % Add a trial trigger. The experiment will be stuck in flip-0 until
                    % the trigger is received ('left' for left arrow). All stimuli with
                    % a negative start time (such as the dxpStimText in this example
                    % experiment will be drawn during flip-0. Trial starting at onSec=0
                    % will be drawn on flip-1 and further.
                    % Type help dpxTriggerKey for help on finding the name of the key
                    %                     % you wish to use.
                    TRIG=dpxTriggerKey;
                    TRIG.name='startkey';
                    TRIG.kbName='UpArrow';
                    C.addTrialTrigger(TRIG);
                    
                    %
                    R=dpxRespContiKeyboard;
                    R.name='LeftArrow';
                    R.kbName='LeftArrow';
                    R.allowAfterSec=0;
                    C.addResp(R);
                    
                    R=dpxRespContiKeyboard;
                    R.name='DownArrow';
                    R.kbName='DownArrow';
                    R.allowAfterSec=0;
                    C.addResp(R);
                    
                    %
                    E.addCondition(C);
                    
                    
                end
            end
        end
        E.nRepeats=2;
        nTrials=numel(E.conditions)*E.nRepeats;
        expectedSecs=nTrials*(C.durSec+1+.55);
        dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
        E.run;
    end
    
