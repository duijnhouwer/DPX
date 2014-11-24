function agDpxOnlyTactile
    
    % agDpxOnlytactile
    
    E=dpxCoreExperiment;
    E.expName='agDpxOnlyTactile';
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';
    E.scr.set('winRectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
    %
    E.startKey='UpArrow'
    
    javaaddpath(which('BrainMidi.jar'));
    % We will make 8 conditions...
    for i=1:8
        C=dpxCoreCondition;
        % Make a fixation dot that each condition will have
        F=dpxStimDot;
        set(F,'xDeg',0);
        set(F,'name','fix','wDeg',0.5);
        % Make a response object that each condition will have
        R=dpxRespKeyboard;
        R.name='kb';
        R.kbNames='LeftArrow,DownArrow';
        R.allowAfterSec=2+.200; % only allow response after the stimulus + 200 ms minimum reaction time
        R.correctEndsTrialAfterSec=0.05;
        %
        C.durSec=3600;
        C.addStim(F);
        C.addResp(R);
        T=dpxStimTactileMIDI;
        T.tapOnSec=0.5 : 0.5 : 2; %[0.5 1 1.5 2 ];
        if i>4
            a=T.tapOnSec;
            a=[a;a];
            a=reshape(a,1,numel(a));
            T.tapOnSec=a;
        end
        if i==1
            T.tapNote=[8 1];
        elseif i==2
            T.tapNote=[0 9];
        elseif i==3
            T.tapNote=[8 0];
        elseif i==4
            T.tapNote=[1 9];
        elseif i==5
            T.tapNote=[0 1  8 9];
        elseif i==6
            T.tapNote=[1 8  0 9];
        elseif i==7
            T.tapNote=[0 8  1 9];
        elseif i==8
            T.tapNote=[8 9  0 1];
        else
            error('Unknown condition number ....');
        end
        T.tapDurSec=0.020;
        C.addStim(T);
        E.addCondition(C);
        if i==5 || i==8
            E.addCondition(C);
            E.addCondition(C);
        end
    end
    E.nRepeats=20;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(max(T.tapOnSec)+.5);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end

