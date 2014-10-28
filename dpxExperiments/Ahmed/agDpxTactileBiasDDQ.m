function agDpxTactileBiasDDQ

% agDpxTactileBiasDDQ

E=dpxCoreExperiment;
E.expName='agDpxTactileBiasDDQ';
E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';    E.scr.set('winRectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
%     E.windowed(true); % true, false, [0 0 410 310]+100
%
E.txtPause='';
E.txtPauseNrTrials=1;
javaaddpath(which('BrainMidi.jar'));


durS=2;
flashSec=.5; %the alternative is 1 sec
ddqWid=4;
for dotSize=1
    for ddqRightFromFix=[0]
        for ddqHei=ddqWid * [1.5]%more or less it is the point of subjective equality
            for ori=0
                for bottomLeftTopRightFirst=[true]
                    for antiJump=false
                        for i=1:4
                        if ddqHei==ddqWid && antiJump
                            continue;
                        end
                        %
                        
                        C=dpxCoreCondition;
                        C.durSec=durS;
                        
                        %
                        F=dpxStimDot;
                        % type get(F) to see a list of parameters you can set
                        set(F,'xDeg',0); % set the fix dot 10 deg to the left
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
                        %                             R=dpxRespKeyboard;
                        %                             R.name='kb';
                        %                             R.kbNames='LeftArrow,UpArrow';
                        %                             R.allowAfterSec=0;
                        %                             R.correctEndsTrialAfterSec=0.1;
                        %                             R.correctStimName='respfeedback';
                        %                             C.addResp(R);
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
                        T.tapNote=flashSec:flashSec:durS;
                        
                            if i==1
                                T.tapNote=[0  8 ];
                            elseif i==2
                                T.tapNote=[0  9 ];
                            elseif i==3
                                T.tapNote=[9 1 ];
                            elseif i==4
                                T.tapNote=[1 8 ];
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
E.nRepeats=5;
nTrials=numel(E.conditions)*E.nRepeats;
expectedSecs=nTrials*(durS);
dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
E.run;
end

