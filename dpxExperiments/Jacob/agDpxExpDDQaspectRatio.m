function agDpxExpDDQaspectRatio
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.expName='agDpxExpDDQaspectRatio';
    E.nRepeats=10;
    E.outputFolder='/tmp/dpxData';
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0 0 1680 1050],'widHeiMm',[430 270], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',4); % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio=[1:.2:2];
    flashSec=[.5 2];
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
                set(DDQ,'diamsDeg',[2 2 2 2]);
                set(DDQ,'bottomLeftTopRightFirst',b);
                C.addStim(DDQ);
                %
                
            end
        end
    end
    
    
end

