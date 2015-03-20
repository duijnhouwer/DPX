
function jvDpxExpDDQvolControl
    
    dpxDispFancy('Make sure only one keyboard is connected!','!',2,2);
    
    E=dpxCoreExperiment;
    % Use dpxGetSetables(E) for a list of all properties that you can set
    % for the dpxCoreExperiment object
    E.expName='jvDpxExpDDQvolControl';
    E.startKey='UpArrow'
    
    E.outputFolder='/Users/iMac_2Photon/Desktop/Joost ';
    % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0+1680 0 1280+1680 960],'widHeiMm',[400 300], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',4); % Generated using dpxToolStimWindowGui on 2014-09-29
    
    
    aRatio= 1.2; %[.6:.2:2.2]; that is your PSE (point of subjective equality)
    durS=60*2 ;
    flashSec=.30; %[.25 .300 .400 .500 .750 1 ] % and here u can change the frequency
    nrSteps=2;
    ddqWid=11; % Here you can change the size 4 11
    bottomLeftTopRightFirst=[true];%[true false];
    
    for ar=aRatio
        for dotSize= 1.7 % here you can change the size of the dots [.5 .75 1]
            for fs=flashSec
                for b=bottomLeftTopRightFirst;
                    for ddqRightFromFix=[0] % here you can manipulate the position of DDQ on the x-Axis
                        
                        C=dpxCoreCondition;
                        C.durSec=durS;
                        %
                        F=dpxStimDot;
                        % type get(F) to see a list of parameters you can set
                        set(F,'xDeg',0); % set the fix dot 10 deg to the left
                        set(F,'name','fix','wDeg',0.5);
                        set(F,'RGBAfrac',[1 0 0 1]);
                        C.addStim(F);
                        %
                        DDQ=dpxStimDynDotQrt;
                        set(DDQ,'name','ddq','wDeg',ddqWid,'hDeg',ddqWid*ar,'flashSec',fs);
                        set(DDQ,'oriDeg',0,'onSec',0.5,'durSec',durS);
                        set(DDQ,'diamsDeg',ones(4,1)*dotSize);
                        set(DDQ,'bottomLeftTopRightFirst',b);
                        set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
                        C.addStim(DDQ);
                        %
                        R=dpxRespContiKeyboard;
                        R.name='LeftArrow';
                        R.kbName='LeftArrow';
                        R.allowAfterSec=0;
                        C.addResp(R);
                        %
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
        end
    end
    E.nRepeats=3; % here you can change the number of repetitions 
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(.5+.02);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
    
end

