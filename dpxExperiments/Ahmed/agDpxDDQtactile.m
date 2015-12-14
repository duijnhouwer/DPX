function agDpxDDQtactile
    
    % agDpxDDQtactile
    
    E=dpxCoreExperiment;
    E.paradigm='dpxDDQtest';
    % E.outputFolder='C:\dpxData\';
    E.window.set('rectPx',[0+1680 0 1280+1680 960],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
    %
    
    javaaddpath(which('BrainMidi.jar'));
    
    
    durS=60;
    flashSec=.5; %the alternative is 1 sec 
    ddqWid=4;
    for dotSize=1
        for ddqRightFromFix=[0]
            for ddqHei=ddqWid * [1.1]%more or less it is the point of subjective equality
                for ori=0
                    for bottomLeftTopRightFirst=[false]
                        for antiJump=false
                            if ddqHei==ddqWid && antiJump
                                continue;
                            end
                            %
                            
                            C=dpxCoreCondition;
                            C.durSec=36000;
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
                            set(DDQ,'diamsDeg',ones(4,1)*dotSize); % diamsDeg is diameter of disks in degrees
                            set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                            set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
                            C.addStimulus(DDQ);
                            %
                            %                           DDQ=dpxStimDynDotQrt;
                            %                     set(DDQ,'name','ddqLeft','wDeg',ddqWid,'hDeg',ddqHei,'flashSec',flashSec);
                            %                     set(DDQ,'oriDeg',ori,'onSec',.5,'durSec',durS,'antiJump',antiJump);
                            %                     set(DDQ,'diamsDeg',[1 1 1 1]*2); % diamsDeg is diameter of disks in degrees
                            %                     set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                            %                     set(DDQ,'xDeg',-10);
                            %                     C.addStimulus(DDQ);
                            
                            %
                            R=dpxRespKeyboard;
                            R.name='kb';
                            R.kbNames='LeftArrow,UpArrow';
                            R.allowAfterSec=0;
                            R.correctEndsTrialAfterSec=0.1;
                            R.correctStimName='respfeedback';
                            C.addResponse(R);
                            %
                            FB=dpxStimDot;
                            set(FB,'xDeg',F.xDeg,'yDeg',F.yDeg);
                            set(FB,'name','respfeedback','wDeg',1,'enabled',0);
                            C.addStimulus(FB);
                            %
                            T=dpxStimTactileMIDI;
                            T.onSec=DDQ.onSec;
                            T.durSec=Inf;
                            
                            tmp=flashSec:flashSec:durS;
tmp
tmp2=[];
                            for i=1:numel(tmp)
                                tmp2(end+1)=tmp(i);
                                tmp2(end+1)=tmp(i);
                            end
                            T.tapOnSec=tmp2;
                            T.tapOnSec=T.tapOnSec;%+2/60;
                            T.tapDurSec=2/60;
                            T.tapNote=repmat([0 1 8 9],1,1000);
                            T.tapNote=T.tapNote(1:numel(T.tapOnSec));
                            C.addStimulus(T);
                            %
                            E.addCondition(C);
                        end
                    end
                end
            end
        end
    end
    E.nRepeats=100;
    E.run;
end

