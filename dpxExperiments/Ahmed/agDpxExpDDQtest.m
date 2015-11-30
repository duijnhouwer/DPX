
function agDpxExpDDQtest
    
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.paradigm='agDpxExpDDQaspectRatio';
    E.startKey='UpArrow';
    
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[],'widHeiMm',[400 300], ... [20 20 400 300]
        'distMm',600,'interEyeMm',65,'gamma',.8,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',1,'verbosity0min5max',3); % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio=[.6:.2:2.2];
    flashSec=2;
    pwmFrac=.75;
    nrSteps=8;
    ddqWid=4;
    bottomLeftTopRightFirst=[true false];
    
    for ar=aRatio
        for fs=flashSec
            for b=bottomLeftTopRightFirst;
                for ddqRightFromFix=[0]
                
                C=dpxCoreCondition;
                C.durSec=36000;
                %
                F=dpxStimDot;
                % type get(F) to see a list of parameters you can set
                set(F,'xDeg',0); % set the fix dot 10 deg to the left
                set(F,'name','fix','wDeg',0.5);
                C.addStim(F);
                %
                DDQ=dpxStimDynDotQrtPWM; % PWM = Pulse Width Modulation
                set(DDQ,'name','ddq','wDeg',ddqWid,'hDeg',ddqWid*ar,'flashSec',fs);
                set(DDQ,'oriDeg',0,'onSec',0.5,'durSec',fs*(nrSteps+1));
                set(DDQ,'pwmFrac',pwmFrac); % Pulse width modulation factor
                set(DDQ,'diamsDeg',[1 1 1 1]);
                set(DDQ,'bottomLeftTopRightFirst',b);
                set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
                C.addStim(DDQ);
                %
                R=dpxRespKeyboard;
                R.name='kb';
                R.kbNames='LeftArrow,DownArrow';
                R.allowAfterSec=DDQ.onSec+DDQ.durSec;
                R.correctEndsTrialAfterSec=0.1;
                R.correctStimName='respfeedback';
                C.addResp(R);
                %
                FB=dpxStimDot;
                set(FB,'xDeg',F.xDeg,'yDeg',F.yDeg);
                set(FB,'name','respfeedback','wDeg',1,'enabled',0);
                C.addStim(FB);
                %
                E.addCondition(C);
                end
                
            end
        end
    end
    E.nRepeats=10;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(.5+.02);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
    
end

