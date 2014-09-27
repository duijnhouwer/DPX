function jdDpxDDQOblique 
    
    % jdDpxDDQOblique
    
    E=dpxCoreExperiment;
    E.expName='dpxDDQtest';
    % E.outputFolder='C:\dpxData\';
    E.scr.set('winRectPx',[],'widHeiMm',[677 423],'distMm',500, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','SkipSyncTests',0);
    E.windowed(false); % true, false, [0 0 410 310]+100
    %
    wid=1.8;
    for hei=[.5 1 1.5 2 2.5 3]*wid
        for ori=[0 45 90 135]
            for bottomLeftTopRightFirst=[false true]
                for antiJump=[false true]
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
                    set(S,'name','ddq','wDeg',wid,'hDeg',hei,'flashSec',.75);
                    set(S,'oriDeg',ori,'onSec',.5,'durSec',1,'antiJump',antiJump);
                    set(S,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                    C.addStim(S);
                    %
                    R=dpxRespKeyboard;
                    R.name='kb';
                    R.kbNames='LeftArrow,RightArrow';
                    R.allowAfterSec=S.onSec+S.durSec; % only after stim
                    R.correctEndsTrialAfterSec=0.1;
                    R.correctStimName='respfeedback';
                    C.addResp(R);
                    %
                    S=dpxStimDot;
                    set(S,'name','respfeedback','wDeg',0.5,'visible',0);
                    C.addStim(S);
                    %
                    %S=dpxStimTactileMIDI;
                   % set(S,'onSec',1.25);
                   % C.addStim(S);
                    %
                    E.addCondition(C);
                end
            end
        end
    end
    E.nRepeats=10;
    E.run;
end

