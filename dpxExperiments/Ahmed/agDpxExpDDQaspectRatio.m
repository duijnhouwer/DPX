function agDpxExpDDQaspectRatio
    
    dpxDispFancy('Make sure only one keyboard is connected!','!',2,2);
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.expName='agDpxExpDDQaspectRatio';
    
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0+1680 0 1280+1680 960],'widHeiMm',[400 300], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',4); % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio=[.6:.2:2.2];
    flashSec=.25;
    nrSteps=2;
    ddqWid=4;
    bottomLeftTopRightFirst=[true false];
    
    for ar=aRatio
        for fs=flashSec
            for b=bottomLeftTopRightFirst;
                
                C=dpxCoreCondition;
                C.durSec=36000;
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
                set(FB,'name','respfeedback','wDeg',1,'visible',0);
                C.addStim(FB);
                %
                E.addCondition(C);
                
            end
        end
    end
    E.nRepeats=10;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(.5+.02);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
    
    
end

