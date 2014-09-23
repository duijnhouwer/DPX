function jdDpxDDQtactile
    
    % jdDpxDDQOblique
    
    E=dpxCoreExperiment;
    E.expName='dpxDDQtest';
    % E.outputFolder='C:\dpxData\';
    E.physScr.set('winRectPx',[0 0 1680 1050],'widHeiMm',[430 270],'distMm',500,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','SkipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22

    E.windowed(false); % true, false, [0 0 410 310]+100
    %
    
    javaaddpath(which('BrainMidi.jar'));
    
    
    durS=60;
    flashSec=1.25; %the alternative is 1 sec 
    ddqWid=3;
    for dotSize=.75
        for ddqRightFromFix=20
            for ddqHei=ddqWid * [1.45] %more or less it is the point of subjective equality
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
                            set(F,'xDeg',-16); % set the fix dot 10 deg to the left
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
                            %
                            %                           DDQ=dpxStimDynDotQrt;
                            %                     set(DDQ,'name','ddqLeft','wDeg',ddqWid,'hDeg',ddqHei,'flashSec',flashSec);
                            %                     set(DDQ,'oriDeg',ori,'onSec',.5,'durSec',durS,'antiJump',antiJump);
                            %                     set(DDQ,'diamsDeg',[1 1 1 1]*2); % diamsDeg is diameter of disks in degrees
                            %                     set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                            %                     set(DDQ,'xDeg',-10);
                            %                     C.addStim(DDQ);
                            
                            %
                            R=dpxRespKeyboard;
                            R.name='kb';
                            R.kbNames='LeftArrow,UpArrow';
                            R.allowAfterSec=0;
                            R.correctEndsTrialAfterSec=0.1;
                            R.correctStimName='respfeedback';
                            C.addResp(R);
                            %
                            FB=dpxStimDot;
                            set(FB,'xDeg',F.xDeg,'yDeg',F.yDeg);
                            set(FB,'name','respfeedback','wDeg',1,'visible',0);
                            C.addStim(FB);
                            %
                            T=dpxStimTactileMIDI;
                            T.onSec=DDQ.onSec;
                            T.durSec=Inf;
                            
                            tmp=flashSec:flashSec:durS;
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
                            C.addStim(T);
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

