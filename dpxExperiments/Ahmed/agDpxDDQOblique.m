function jdDpxDDQOblique 
    
    % jdDpxDDQOblique
    
    E=dpxCoreExperiment;
    E.expName='jdDpxDDQOblique';
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';
      % Use E.scr.gui to bring up the gui to set the screen properties
    E.scr.set('winRectPx',[0+1680 0 1280+1680 960],'widHeiMm',[400 300], ...
        'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',1); % Generated using dpxToolStimWindowGui on 2014-09-29
    
    E.windowed(false); % true, false, [0 0 410 310]+100
    %
    wid=4;
    for hei=[.5 .75 1 1.25 1.5 1.75 2]*wid
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
                    set(S,'name','fix','wDeg',0.5);
                    C.addStim(S);
                    %
                    S=dpxStimDynDotQrt;
                    set(S,'name','ddq','wDeg',wid,'hDeg',hei,'flashSec',.75);
                    set(S,'oriDeg',ori,'onSec',.25,'durSec',1,'antiJump',antiJump);
                    set(S,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                    C.addStim(S);
                    %
                    R=dpxRespKeyboard;
                    R.name='kb';
                    R.kbNames='LeftArrow,RightArrow';
                    R.allowAfterSec=S.onSec+S.durSec+0.200; % only after stim + 200 ms minimal reaction time
                    R.correctEndsTrialAfterSec=0.05;
                    R.correctStimName='respfeedback';
                    C.addResp(R);
                    %
                    S=dpxStimDot;
                    set(S,'name','respfeedback','wDeg',1,'visible',0);
                    C.addStim(S);
                    %
                    E.addCondition(C);
                end
            end
        end
    end
    E.nRepeats=7;
    keyboard
    
    E.run;
end

