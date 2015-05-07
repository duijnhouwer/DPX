function agDpxMultisensoryHorizontal

% agDpxMultisensoryHorizontal
KbName('UnifyKeyNames');
E=dpxCoreExperiment;
E.expName='agDpxMultisensoryHorizontal';
E.outputFolder='D:\'%'/Users/iMac_2Photon/Dropbox/dpxData';
testscr=[20 20 800 600];

E.scr.set('winRectPx',testscr,'widHeiMm',[400 300],...
    'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],...
    'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22

%[0+1680 0 1280+1680 960]
%
E.startKey='UpArrow'


javaaddpath(which('BrainMidi.jar'));


durS=2*1 ;
flashSec=.5; %the alternative is 1 sec
ddqWid=4;
conditionCounter=0;

for dotSize=1
    for ddqRightFromFix=[0]
        for ddqHei=ddqWid * [1.2]%it is the point of subjective equality
            for ori=0
                for bottomLeftTopRightFirst=[true]
                    for antiJump=false
                        if ddqHei==ddqWid && antiJump
                            continue;
                        end
                        for i=1:3
                            conditionCounter=conditionCounter+1;
                            for tac=1:2
                                           
                                %
                                
                                C=dpxCoreCondition;
                                C.durSec=durS;
                                %
                                F=dpxStimDot;
                                % type get(F) to see a list of parameters you can set
                                set(F,'xDeg',0); % change the position of the Fixation dot
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
                                if conditionCounter==1
                                    % Add  a text stimulus
                                    TEXT=dpxStimTextSimple;
                                    TEXT.name='text';
                                    TEXT.str=['Passive\nUpArrow to start ...'];
                                    TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                                    TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                                elseif conditionCounter==2
                                    TEXT=dpxStimTextSimple;
                                    TEXT.name='text';
                                    TEXT.str=['Hold\nUpArrow to start ...'];
                                    TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                                    TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                                else
                                    TEXT=dpxStimTextSimple;
                                    TEXT.name='text';
                                    TEXT.str=['Switch\nUpArrow to start ...'];
                                    TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
                                    TEXT.durSec=0; % stimulus disappears when flip-1 is reached
                                end
                                C.addStim(TEXT);
                                
                                % Add a trial trigger. The experiment will be stuck in flip-0 until
                                % the trigger is received ('left' for left arrow). All stimuli with
                                % a negative start time (such as the dxpStimText in this example
                                % experiment will be drawn during flip-0. Trial starting at onSec=0
                                % will be drawn on flip-1 and further.
                                % Type help dpxTriggerKey for help on finding the name of the key
                                %                     % you wish to use.
                                TRIG=dpxTriggerKey;
                                TRIG.name='startkey';
                                TRIG.kbName='UpArrow';
                                C.addTrialTrigger(TRIG);
                                %
                                R=dpxRespContiKeyboard;
                                R.name='LeftArrow';
                                R.kbName='LeftArrow';
                                R.allowAfterSec=0;
                                C.addResp(R);
%                                 %
                                R=dpxRespContiKeyboard;
                                R.name='Down';
                                R.kbName='DownArrow';
                                R.allowAfterSec=0;
                                C.addResp(R);
%                                 %
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
                                
                                if tac==1
                                    T.tapNote=repmat([0 8 1 9],1,1000);
                                    T.tapNote=T.tapNote(1:numel(T.tapOnSec));
                                else
                                    T.tapNote=repmat([1 8 0 9],1,1000);
                                    T.tapNote=T.tapNote(1:numel(T.tapOnSec));
                                end
                                
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
    
    E.nRepeats=2;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(durS);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end

