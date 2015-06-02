function agDpxDDQTactileSwitches
    
    % agDpxDDQTactileSwitches
    
    E=dpxCoreExperiment;
    E.expName='agDpxDDQTactileSwitches';
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';
    E.scr.set('winRectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
    %
    E.startKey='UpArrow'
    
    %     E.txtPause='';
    %     E.txtPauseNrTrials=1;
    javaaddpath(which('BrainMidi.jar'));
    
    
    durS=2*3 ;
    flashSec=.5; %the alternative is 1 sec
    
    conditionCounter=1;
    
    TrialCounter=0;
    for tac=1
        C=dpxCoreCondition;
        C.durSec=durS;
        
        
        
        %
        F=dpxStimDot;
        % type get(F) to see a list of parameters you can set
        set(F,'xDeg',0); % set the fix dot 10 deg to the left
        set(F,'name','fix','wDeg',0.5);
        C.addStim(F);
        %
        
        TrialCounter=TrialCounter+1;
        T=dpxStimTactileMIDI;
        T.onSec=0.5;
        T.durSec=durS;
        
        tmp=flashSec:flashSec:durS;
        tmp2=[];
        for i=1:numel(tmp)
            tmp2(end+1)=tmp(i);
            tmp2(end+1)=tmp(i);
        end
        if conditionCounter==1
            TEXT=dpxStimTextSimple;
            TEXT.name='text';
            TEXT.str=['Short Break\n UpArrow to start ...\n' ]; %Trial #' num2str(TrialCounter,'%3d')
            TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
            TEXT.durSec=0; % stimulus disappears when flip-1 is reached
        end
        C.addStim(TEXT);
        TRIG=dpxTriggerKey;
        TRIG.name='startkey';
        TRIG.kbName='UpArrow';
        C.addTrialTrigger(TRIG);
        
        T.tapOnSec=tmp2;
        T.tapOnSec=T.tapOnSec;%+2/60;
        T.tapDurSec=2/60;
        T.tapNote=repmat([0 1 8 9],1,1000);
        T.tapNote=T.tapNote(1:numel(T.tapOnSec));
        C.addStim(T);
        
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
        
        %
        E.addCondition(C);
    end
    
    E.nRepeats=2;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(durS);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end

