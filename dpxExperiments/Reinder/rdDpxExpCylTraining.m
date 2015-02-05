function rdDpxExpCylTraining(size,disparities)
%% Training for the half cylinders
% in essence just a movie of a concave shifting to a convex shape. Subjects
% gives a response where the cylinder changes shape
%
% size = integer. arbitrary value for the size. 1 is 3x3, 2=4x4, 3=5x5
% best is to start large, with 3, and work your way down. standard is 1
%
% dsp = disparities using. always in steps of .2, format is the outer
% value's. from positive to negative! i.e: [2 -2] gives [2:.2:-2] standard is [1 -1]

if nargin==0
    size=1;
    dsp=1:-0.2:-1;
end
if nargin==1
    if ~exist('disparities','var')
        dsp=1:-0.2:-1;
    elseif ~exist('size','var')
        size=1;
    end
end
if nargin==2
    dsp=disparities(1):-0.2:disparities(2);
end

if IsWin %disable laptop lid-button
    DisableKeysForKbCheck(233);
end


E=dpxCoreExperiment; 
Block=10; %number of repeats in one block
nReps=10; %number of repeats of a total trial from +1 to -1 to +1
E.txtPauseNrTrials=(numel(dsp)*4-2)*Block;
% fullWhite=false;
% dispShift=false;

% handle the position option

E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nDan verschijnt een halve Cylinder\ndie van bol naar hol gaat.\n\nGeef door middel van de pijltjes aan welke vorm het heeft\n\nPijlteje omhoog = Hol\nPijltje omlaag = Bol';
E.expName='rdDpxExpTraining';

% Then the experiment option, make expname (used in output filename)
if strcmpi(dpxGetUserName,'Reinder')
    E.outputFolder='C:\tempdata_PleaseDeleteMeSenpai';
elseif strcmpi(dpxGetUserName,'EyeLink-admin')
    E.outputFolder='C:\Users\EyeLink-admin\Dropbox\DPX\Data\Exp0Training';
end

% Set the stimulus window option
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[394 295],'distMm',1000,'scrNr',1); % Eyelink PC, Nr=1 : crt
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
E.scr.set('stereoMode','mirror','skipSyncTests',1); %  stereoModes: mono, mirror, anaglyph

% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run

% set stimulus critical value's which stay the same over the trials

for rotSpeed=[120 -120] % >0 -> up
    for disp=dsp
        C=dpxCoreCondition;
        set(C,'durSec',1);%4*numel(dsp)-2);
        
        % The fixation cross
        S=dpxStimCross;
        set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
        C.addStim(S);
        
        % The feedback stimulus for correct responses
        S=dpxStimDot;
        set(S,'wDeg',.3,'visible',false,'durSec',1,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
        C.addStim(S);
        
        % The half cylinder stimulus
        S=dpxStimRotCylinder;
        set(S,'dotsPerSqrDeg',12,'xDeg',0,'wDeg',2+(1*size),'hDeg',2+(1*size),'dotDiamDeg',0.11 ...
            ,'rotSpeedDeg',rotSpeed,'disparityFrac',disp,'sideToDraw','front' ...
            ,'onSec',0,'durSec',1,'name','halfInducerCyl');
        C.addStim(S);
        
        % The response objects
        R=dpxRespContiKeyboard;
        set(R,'kbName','UpArrow');
        set(R,'name','Concave');
        C.addResp(R);
        
        R=dpxRespContiKeyboard;
        set(R,'kbName','DownArrow');
        set(R,'name','Convex');
        C.addResp(R);
        
        E.addCondition(C);
    end
end
E.conditionSequence=repmat([1:1:numel(dsp) numel(dsp)-1:-1:1 numel(dsp)+1:1:2*numel(dsp) 2*numel(dsp)-1:-1:numel(dsp)+1],1,nReps);

E.run;
end