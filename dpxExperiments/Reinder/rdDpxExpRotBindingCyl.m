function rdDpxExpRotBindingCyl(pos,BB)
%%baseline and binding experiment
%
%%input needed is: (pos) --> position of the !HALVE! cylinder (inducer), 'left' or 'right'
%%experiment type (BB) --> baseline or binding (depends on whihc stim the subject has to
%%report: 'base' or 'bind'
%%i.e. rdDpxExpRotCyl('left','bind')

if IsWin %disable laptop lid-button
    DisableKeysForKbCheck([233]);
end

E=dpxCoreExperiment;
E.txtPauseNrTrials=120;
E.nRepeats=20;
fullWhite=false;
dispShift=false;

% handle the position option
if strcmpi(pos,'left')
    flippos=1;
    if strcmpi(BB,'base')
        E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nIs de LINKER halve cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag\n\nDruk op spatie om te beginnen';
        E.paradigm='rdDpxExpBaseLineCylLeft';
    elseif strcmpi(BB,'bind')
        E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nHoe beweegt het voorvlak van de RECHTER volle cylinder?\nOmhoog = Pijltje omhoog\nOmlaag = Pijltje omlaag\n\nDruk op spatie om te beginnen';
        E.paradigm='rdDpxExpBindingCylLeft';
    else
        error(['unknown type of experiment ' BB]);
    end
elseif strcmpi(pos,'right')
    flippos=-1;
    if strcmpi(BB,'base')
        E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nIs de RECHTER halve cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.paradigm='rdDpxExpBaseLineCylRight';
    elseif strcmpi(BB,'bind')
        E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nHoe beweegt het voorvlak van de LINKER volle cylinder?\nOmhoog = Pijltje omhoog\nOmlaag = Pijltje omlaag';
        E.paradigm='rdDpxExpBindingCylRight';
    else
        error(['unknown type of experiment ' BB]);
    end
else
    error(['unknown pos mode ' pos]);
end

E.txtStart=[ E.txtStart '\nFeedback Flits:\nGrijs: Antwoord ontvangen.\n\nDruk op spatie om te beginnen'];

% Then the experiment option, make expname (used in output filename)
if strcmpi(dpxGetUserName,'Reinder')
    E.outputFolder='C:\tempdata_PleaseDeleteMeSenpai';
elseif strcmpi(dpxGetUserName,'EyeLink-admin')
    if strcmpi(BB,'base')
        E.outputFolder='C:\Users\EyeLink-admin\Dropbox\DPX\Data\Exp2Baseline';
    elseif strcmpi(BB,'bind')
        E.outputFolder='C:\Users\EyeLink-admin\Dropbox\DPX\Data\Exp2Binding';
    end
end

% Set the stimulus window option
% [1440 0 1600+1440 1200]
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[394 295],'distMm',1000,'scrNr',0); % Eyelink PC, Nr=1 : crt
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
E.scr.set('stereoMode','mirror','skipSyncTests',1); %  stereoModes: mono, mirror, anaglyph

% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run
modes={'stereo','anti-stereo','mono'}; % {'stereo','anti-stereo','mono'}
for m=1:numel(modes)
    for dsp=[-.8 -.4 0 .4 .8]
        for rotSpeed=[120 -120] % >0 --> up
            C=dpxCoreCondition;
            set(C,'durSec',2.5);
            
            % The fixation cross
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
            C.addStim(S);
            
            % The feedback stimulus for correct responses
            S=dpxStimDot;
            set(S,'wDeg',0.3,'enabled',false,'durSec',.1,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
            C.addStim(S);
            
            % The full cylinder stimulus
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                ,'onSec',0,'durSec',1,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
                ,'name','fullTargetCyl');
            if fullWhite==true %make a full white
                set(S,'dotRGBA1frac',[1 1 1 1],'dotRGBA2frac',[1 1 1 1]);  
            end
            C.addStim(S);
            
            % The half cylinder stimulus
            if strcmpi(modes{m},'mono')
                lumcorr=1;
                dFog=dsp;
                dScale=dsp;
                dispa=0;
            elseif strcmpi(modes{m},'stereo')
                lumcorr=1;
                dFog=0;
                dScale=0;
                dispa=dsp;
            elseif strcmpi(modes{m},'anti-stereo')
                lumcorr=-1;
                dFog=0;
                dScale=0;
                dispa=dsp;
            else
                error('what you trying fool!?')
            end
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',flippos*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',dispa,'sideToDraw','front' ...
                ,'onSec',0,'durSec',1,'stereoLumCorr',lumcorr,'fogFrac',dFog,'dotDiamScaleFrac',dScale ...
                ,'name','halfInducerCyl');
            if dispShift==true;
                set(S,'dispShiftMono',true); % make a shifted image in both sides
            end
            if fullWhite==true; % make full white
                set(S,'dotRGBA1frac',[1 1 1 1],'dotRGBA2frac',[1 1 1 1]);
            end
            C.addStim(S);
            
            % The response object
            R=dpxRespKeyboard;
            R.allowAfterSec=S.onSec+S.durSec;
            R.kbNames='UpArrow,DownArrow';
            R.correctStimName='fbCorrect';
            R.name='rightHand';
            R.correctKbNames='1';
            R.correctEndsTrialAfterSec=inf;
            R.wrongEndsTrialAfterSec=inf;
            C.addResp(R);
            
            E.addCondition(C);
        end
    end
end
E.run;
end