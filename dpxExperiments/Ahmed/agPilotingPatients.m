function agPilotingPatients
    
    % agPilotingPatients
    
    E=dpxCoreExperiment;
    E.paradigm='agPilotingPatients';
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';    E.window.set('rectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
    %
    E.startKey='UpArrow'
    
    javaaddpath(which('BrainMidi.jar'));
    
    
    durS=3.5 ;
    flashSec=.5; %the alternative is 1 sec
    ddqWid=6;
    dotSize=1;
    for ddqRightFromFix=[0]
        for ddqHei=ddqWid * [0]%it is the point of subjective equality
            for ori=0
                for bottomLeftTopRightFirst=[false]
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
                            set(F,'xDeg',0); % set the fix dot 10 deg to the left
                            set(F,'name','fix','wDeg',0.5);
                            C.addStimulus(F);
                            %
                            DDQ=dpxStimDynDotQrt;
                            set(DDQ,'name','ddqRight','wDeg',ddqWid,'hDeg',ddqHei,'flashSec',flashSec);
                            set(DDQ,'oriDeg',ori,'onSec',0.5,'durSec',durS,'antiJump',antiJump);
                            set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                            set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
                            if i==1
                                set(DDQ,'diamsDeg',[0 0 dotSize dotSize]); % diamsDeg is diameter of disks in degrees
%                             elseif i==2
%                                 set(DDQ,'diamsDeg',[0 0 dotSize dotSize]); % diamsDeg is diameter of disks in degrees
%                                 
% %                             elseif i==3
% %                                 set(DDQ,'diamsDeg',[ dotSize dotSize 0 0]); % diamsDeg is diameter of disks in degrees
% %                                 
% %                             elseif i==4
% %                                 set(DDQ,'diamsDeg',[0 0 dotSize dotSize]); % diamsDeg is diameter of disks in degrees
%                             else
%                                 error('i>4???');
                           
                            C.addStimulus(DDQ);
                            T=dpxStimTactileMIDI;
                            T.onSec=DDQ.onSec;
                            T.durSec=Inf;
                            T.tapOnSec=kron(flashSec:flashSec:durS,[1 1])-flashSec;
                            T.tapDurSec=2/60;
                            T.tapNote=[0 8 1 9];
                            C.addStimulus(T);
                            elseif i==2
                                set(DDQ,'diamsDeg',[0 0 dotSize dotSize]);
                                
                            C.addStimulus(DDQ);
                            end
                                
                                
                            
                            R=dpxRespKeyboard;
                            R.name='keyboard';
                            R.kbNames='2,1';
                            R.allowAfterSec=DDQ.onSec+DDQ.durSec; % allow the response no sooner than the end of the DDQ stim
                            R.correctEndsTrialAfterSec=0;
                            C.addResponse(R);
                            %
                            FB=dpxStimDot;
                            set(FB,'xDeg',F.xDeg,'yDeg',F.yDeg);
                            set(FB,'name','respfeedback','wDeg',1,'enabled',0);
                            C.addStimulus(FB);
                            %
                      
%                             T=dpxStimTactileMIDI;
%                             T.onSec=DDQ.onSec;
%                             T.durSec=Inf;
%                             T.tapOnSec=kron(flashSec:flashSec:durS,[1 1])-flashSec;
%                             T.tapDurSec=2/60;
%                             T.tapNote=[0 8 1 9];
%                             C.addStimulus(T);
                            %
                            E.addCondition(C);
                        end
                    end
                end
            end
        end
    end
    E.nRepeats=10;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(durS);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end

