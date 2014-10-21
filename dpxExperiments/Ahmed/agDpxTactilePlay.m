function agDpxTactilePlay

% agDpxTactilePlay

E=dpxCoreExperiment;
E.expName='agDpxTactilePlay';
% E.outputFolder='C:\dpxData\';
E.scr.set('winRectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
%

javaaddpath(which('BrainMidi.jar'));


durS=60;
flashSec=.5; %the alternative is 1 sec
ddqWid=4;

    %
    
    C=dpxCoreCondition;
    C.durSec=36000;
    %
    F=dpxStimDot;
    % type get(F) to see a list of parameters you can set
    set(F,'xDeg',0); % set the fix dot 10 deg to the left
    set(F,'name','fix','wDeg',0.5);
    C.addStim(F);
    %
%     DDQ=dpxStimDynDotQrt;
%     set(DDQ,'name','ddqRight','wDeg',ddqWid,'hDeg',ddqHei,'flashSec',flashSec);
%     set(DDQ,'oriDeg',ori,'onSec',0.5,'durSec',durS,'antiJump',antiJump);
%     set(DDQ,'diamsDeg',ones(4,1)*dotSize); % diamsDeg is diameter of disks in degrees
%     set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
%     set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
%     C.addStim(DDQ);
    %
    
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
    % 
    T=dpxStimTactileMIDI;
    T.onSec=0.5;
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


E.nRepeats=100;
E.run;
end

