function rdDpxExpAdaptDepth()

%%%%%%%%%%%%%%%%%%
% STIMULUS INPUT %
%%%%%%%%%%%%%%%%%%
global IN

% General
IN.cylRepeats = 20;

% adaptation
IN.adapSec     = 10;

% cylinders
IN.cylOnSec    = 1;
IN.cylOffSec   = 1.5;
IN.disp        = [-.8];
IN.flippos     = 1;
IN.reps        = 20;
IN.rotSpeed    = [120];
IN.modes       = 'stereo';

IN.iRep=0;

%%%%%%%%%%%%%%%%%%%%%
%   START STUFF     %
%%%%%%%%%%%%%%%%%%%%%
E=dpxCoreExperiment;
E.paradigm      = mfilename;
E.txtStart      = 'intro';
E.outputFolder  = 'C:\tempdata_PleaseDeleteMeSenpai';
E.window.set('scrNr',0,'stereoMode','mirror');
E.window.set('gamma',0.49,'backRGBA',[.5 .5 .5 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%
%   FIRST ADAPTATION    %
%%%%%%%%%%%%%%%%%%%%%%%%%

adapC=dpxCoreCondition;
adapC = defineAdaptationStimulation(E.window,true,adapC);
adapC = defineCylinderStimulinder(false,adapC);
E.addCondition(adapC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   AFTER 1800 SEC CYLINDER STIMULUS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cylC = dpxCoreCondition;
cylC = defineCylinderStimulinder(true,cylC);
cylC = defineAdaptationStimulation(E.window,false,cylC);
E.addCondition(cylC);

%%%%%%%%%%%%%%%%%%%%%%%%%
% ALL STIMULI COLLECTED %
%%%%%%%%%%%%%%%%%%%%%%%%%
%        ! RUN !        %
%%%%%%%%%%%%%%%%%%%%%%%%%

E.conditionSequence=[1 repmat(2,1,IN.cylRepeats)];

E.run;

end

function C = defineAdaptationStimulation(W,state,C)
global IN

if state; visible = 1; C.durSec    = IN.adapSec;
elseif ~state; visible = 0; C.durSec = IN.cylOnSec+IN.cylOffSec;
end

%left stimulus
ML = dpxStimMaskGaussian;
ML.name='MaskLeft';
ML.xDeg=0;
ML.hDeg = (50*sqrt(2))/W.deg2px;
ML.wDeg = (50*sqrt(2))/W.deg2px;
ML.sigmaDeg = ML.hDeg/8;
ML.durSec=IN.adapSec;
ML.visible=visible;
C.addStimulus(ML);

GL = dpxStimGrating;
GL.name = 'gratingLeft';
GL.xDeg=0;
GL.dirDeg=-45;
GL.contrastFrac=1;
GL.squareWave=false;
GL.cyclesPerSecond=0;
GL.cyclesPerDeg=2.5;
GL.wDeg=(50)/W.deg2px;
GL.hDeg=(50)/W.deg2px;
GL.durSec=IN.adapSec;
GL.buffer=0;
GL.visible=visible;
C.addStimulus(GL);

%right stimulus
MR = dpxStimMaskGaussian;
MR.name='MaskRite';
MR.xDeg=0;
MR.hDeg = (50*sqrt(2))/W.deg2px;
MR.wDeg = (50*sqrt(2))/W.deg2px;
MR.sigmaDeg = MR.hDeg/8;
MR.durSec=IN.adapSec;
MR.visible=visible;
C.addStimulus(MR);

GR = dpxStimGrating;
GR.name = 'gratingRight';
GR.xDeg=0;
GR.dirDeg=45;
GR.squareWave=false;
GR.cyclesPerSecond=0;
GR.cyclesPerDeg=2.5;
GR.wDeg= (50)/W.deg2px;
GR.hDeg= (50)/W.deg2px;
GR.durSec=IN.adapSec;
GR.buffer=1;
GR.visible=visible;
C.addStimulus(GR);

end

function C = defineCylinderStimulinder(state,C)
global IN

if state; visible = 1; C.durSec = IN.cylOnSec+IN.cylOffSec;
elseif ~state; visible = 0; C.durSec    = IN.adapSec;
end

% The fixation cross
S=dpxStimCross;
set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix','visible',visible);
C.addStimulus(S);

% The feedback stimulus for correct responses
S=dpxStimDot;
set(S,'wDeg',.3,'enabled',false,'durSec',.1,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
C.addStimulus(S);

% The full cylinder stimulus
S=dpxStimRotCylinder;
set(S,'dotsPerSqrDeg',12,'xDeg',IN.flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
    ,'rotSpeedDeg',IN.rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
    ,'onSec',0,'durSec',IN.cylOnSec,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
    ,'name','fullTargetCyl','visible',visible);
C.addStimulus(S);

% The half cylinder stimulus
if strcmpi(IN.modes,'mono')
    lumcorr=1;
    dFog=dsp;
    dScale=IN.disp;
    dispa=0;
elseif strcmpi(IN.modes,'stereo')
    lumcorr=1;
    dFog=0;
    dScale=0;
    dispa=IN.disp;
elseif strcmpi(IN.modes,'anti-stereo')
    lumcorr=-1;
    dFog=0;
    dScale=0;
    dispa=IN.disp;
else
    error('what you trying fool!?')
end

S=dpxStimRotCylinder;
set(S,'dotsPerSqrDeg',12,'xDeg',IN.flippos*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
    ,'rotSpeedDeg',IN.rotSpeed,'disparityFrac',dispa,'sideToDraw','front' ...
    ,'onSec',0,'durSec',IN.cylOnSec,'stereoLumCorr',lumcorr,'fogFrac',dFog,'dotDiamScaleFrac',dScale ...
    ,'name','halfInducerCyl','visible',visible);
C.addStimulus(S);

% The response object
    R=dpxRespKeyboard;
    R.name='rightHand';
    if state; R.allowAfterSec=S.onSec+S.durSec;
    elseif ~state R.allowAfterSec=IN.adapSec; end
    R.kbNames='UpArrow,DownArrow';
    R.correctStimName='fbCorrect';
    R.correctKbNames='1';
    R.correctEndsTrialAfterSec=inf;
    R.wrongEndsTrialAfterSec=inf;
    C.addResponse(R);
end


