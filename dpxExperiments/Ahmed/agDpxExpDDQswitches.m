function agDpxExpDDQswitches
    
    dpxDispFancy('Make sure only one keyboard is connected!','!',2,2);
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.expName='agDpxExpDDQswitches';
    E.nRepeats=100;
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';
    E.txtPause='';
    E.txtPauseNrTrials=1;
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0+1680 0 1280+1680 960],'widHeiMm',[480 300], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',1);
    % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio=[1.57];
    flashSec=.25;
    nrSteps=10000;
    ddqWid=4;
    bottomLeftTopRightFirst=[true false];
    
    for ar=aRatio
        for fs=flashSec
            for b=bottomLeftTopRightFirst;
                
                C=dpxCoreCondition;
                C.durSec=120;
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
                R=dpxRespContiKeyboard;
                R.name='LeftArrow';
                R.kbName='LeftArrow';
                R.allowAfterSec=0;
                C.addResp(R);
                  %
                R=dpxRespContiKeyboard;
                R.name='UpArrow';
                R.kbName='UpArrow';
                R.allowAfterSec=0;
                C.addResp(R);
                %
                E.addCondition(C);
                
            end
        end
    end
        nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(.25+1+.55);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;    
end

