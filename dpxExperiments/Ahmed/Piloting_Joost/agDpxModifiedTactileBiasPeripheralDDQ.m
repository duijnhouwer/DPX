function agDpxModifiedTactileBiasPeripheralDDQ
    
    % agDpxModifiedTactileBiasPeripheralDDQ
    
    E=dpxCoreExperiment;
            
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';    
    E.window.set('rectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
    %     E.windowed(true); % true, false, [0 0 410 310]+100
    %
    % E.txtPause='';
    % E.txtPauseNrTrials=1;
    E.startKey='UpArrow'
    
    javaaddpath(which('BrainMidi.jar'));
    
    
    durS=3.5;
    flashSec=.5; %the alternative is 1 sec
    ddqWid=3;
    for dotSize=1
        for ddqRightFromFix=[-20]
            for ddqHei=ddqWid * [1.3]%more or less it is the point of subjective equality
                for ori=0
                    for bottomLeftTopRightFirst=[true]
                        for antiJump=false
                            for i=1:2
                                if ddqHei==ddqWid && antiJump
                                    continue;
                                end
                                %
                                C=dpxCoreCondition;
                                C.durSec=3600;
                                %
                                F=dpxStimDot;
                                % type get(F) to see a list of parameters you can set
                                set(F,'xDeg',15); % set the fix dot 10 deg to the left
                                set(F,'name','fix','wDeg',0.5);
                                C.addStim(F);
                                %
                                DDQ=dpxStimDynDotQrt;
                                set(DDQ,'name','ddqRight','wDeg',ddqWid,'hDeg',ddqHei,'flashSec',flashSec);
                                set(DDQ,'oriDeg',ori,'onSec',0.5,'durSec',durS,'antiJump',antiJump);
                                set(DDQ,'diamsDeg',ones(4,1)*dotSize); % diamsDeg is diameter of disks in degrees
                                set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                                set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
                                C.addStim(DDQ);
                                
                                R=dpxRespKeyboard;
                                R.name='keyboard';
                                R.kbNames='LeftArrow,DownArrow';
                                R.allowAfterSec=DDQ.onSec+DDQ.durSec; % allow the response no sooner than the end of the DDQ stim
                                R.correctEndsTrialAfterSec=0;
                                C.addResp(R);
                                %
                                FB=dpxStimDot;
                                set(FB,'xDeg',F.xDeg,'yDeg',F.yDeg);
                                set(FB,'name','respfeedback','wDeg',1,'enabled',0);
                                C.addStim(FB);
                                %
                                T=dpxStimTactileMIDI;
                                T.onSec=DDQ.onSec;
                                T.durSec=Inf;
                                
                                T.tapOnSec=(DDQ.onSec:flashSec:durS);
                                T.tapDurSec=2/60;
                                
                                a=T.tapOnSec;
                                a=[a;a];
                                a=reshape(a,1,numel(a));
                                T.tapOnSec=a;
                                
                                if i==1
                                    T.tapNote=[0 9 8 1];
                                elseif i==2
                                    T.tapNote=[0 8 9 1];
                                    
                                else
                                    error('Unknown condition number ....');
                                end
                                
                                C.addStim(T);
                                %
                                E.addCondition(C);
                            end
                        end
                    end
                end
            end
        end
    end
    E.nRepeats=50;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(durS);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end

