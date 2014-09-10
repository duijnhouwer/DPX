function jdDpxDDQtactile 
    
    % jdDpxDDQOblique
    
    E=dpxCoreExperiment;
    E.expName='dpxDDQtest';
    % E.outputFolder='C:\dpxData\';
    E.physScr.set('winRectPx',[],'widHeiMm',[677 423],'distMm',500, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','SkipSyncTests',0);
    E.windowed(false); % true, false, [0 0 410 310]+100
    %
    durS=30;
    flashSec=.5;
    wid=7;
    for hei=1*wid
        for ori=45
            for bottomLeftTopRightFirst=[false]
                for antiJump=false
                    if hei==wid && antiJump
                        continue;
                    end
                    %
                    
                    C=dpxCoreCondition;
                    C.durSec=36000;
                    %
                    S=dpxStimDot;
                    set(S,'name','fix','wDeg',0.25);
                    C.addStim(S);
                    %
                    S=dpxStimDynDotQrt;
                    set(S,'name','ddq','wDeg',wid,'hDeg',hei,'flashSec',flashSec);
                    set(S,'oriDeg',ori,'onSec',.5,'durSec',durS,'antiJump',antiJump);
                    set(S,'diamsDeg',[4 4 4 4]);
                    set(S,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                    C.addStim(S);
                    %
                    R=dpxRespKeyboard;
                    R.name='kb';
                    R.kbNames='LeftArrow,RightArrow';
                    R.allowAfterSec=0;
                    R.correctEndsTrialAfterSec=0.1;
                    R.correctStimName='respfeedback';
                    C.addResp(R);
                    %
                    S=dpxStimDot;
                    set(S,'name','respfeedback','wDeg',0.5,'visible',0);
                    C.addStim(S);
                    %
                    S=dpxStimTactileMIDI;
                    S.onSec=.5;
                    S.durSec=Inf;
                    
                    tmp=flashSec:flashSec:durS;
                    tmp2=[];
                    for i=1:numel(tmp)
                        tmp2(end+1)=tmp(i);
                        tmp2(end+1)=tmp(i);
                    end
                    S.tapOnSec=tmp2;
                    S.tapOnSec=S.tapOnSec+2/60;
                    S.tapDurSec=2/60;
                    S.tapNote=repmat([0 1 9 10],1,1000);
                    S.tapNote=S.tapNote(1:numel(S.tapOnSec));
                    C.addStim(S);
                    %
                    E.addCondition(C);
                end
            end
        end
    end
    E.nRepeats=100;
    E.run;
end

