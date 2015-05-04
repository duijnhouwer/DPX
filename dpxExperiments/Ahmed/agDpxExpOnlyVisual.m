function agDpxExpOnlyVisual
    
    dpxDispFancy('Make sure only one keyboard is connected!','!',2,2);
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.expName='agDpxExpOnlyVisual';
    if IsWin
        E.outputFolder='C:\temp\dpxData';
    else
        E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';
    end
    E.startKey='UpArrow'
    
    
    
    
    
    %     E.txtPause='Press and release $STARTKEY to start';
    %    E.txtPauseNrTrials=1;
    %[0+1680 0 1280+1680 960]
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0 0 400 400],'widHeiMm',[480 300], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',1);
    % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio=[1.4];
    flashSec=.25;
    nrSteps=10000;
    ddqWid=4;
    bottomLeftTopRightFirst=[true];
    conditionCounter=1;
    %     for i=1:3
    %         conditionCounter=conditionCounter+1;
    
    for ar=aRatio
        for fs=flashSec
            for b=bottomLeftTopRightFirst;
                
                C=dpxCoreCondition;
                C.durSec=10*1;
                %
                F=dpxStimDot;
                % type get(F) to see a list of parameters you can set
                set(F,'xDeg',0); % set the fix dot 10 deg to the left
                set(F,'name','fix','wDeg',0.5);
                C.addStim(F);
                %
                DDQ=dpxStimDynDotQrt;
                set(DDQ,'name','ddq','wDeg',ddqWid,'hDeg',ddqWid*ar,'flashSec',fs);
                set(DDQ,'oriDeg',0,'onSec',0.5,'durSec',fs*(nrSteps+1));
                set(DDQ,'diamsDeg',[1 1 1 1]);
                set(DDQ,'bottomLeftTopRightFirst',b);
                C.addStim(DDQ);
                %
                % Add  a text stimulus
                TEXT=dpxStimTextSimple;
                TEXT.name='text';
                TEXT.str=['Condition #' num2str(conditionCounter,'%3d') '\n' E.startKey ' to start ...'];
                TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                
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
        %         end
    end
    E.nRepeats=2;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(C.durSec+1+.55);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end

