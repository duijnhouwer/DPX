function rdDpxExpRotHalfCyl(pos,fb)
%%first feedback excersize, report halve cylinder
%
%%input needed is: position of the halve cylinder, and whether this is a
%%feedback exercise or not.
%%i.e. rdDpxExpRotCyl('left','feedback')

if IsWin %disable laptop lid-button
    DisableKeysForKbCheck([233]);
end

if nargin==1
    fb='feedback';
end


E=dpxCoreExperiment;
E.txtPauseNrTrials=120;
E.nRepeats=8;

% handle the position option
if strcmpi(pos,'left')
    flippos=1;
    E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nIs de LINKER cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
    E.paradigm='rdDpxExpRotHalfCylLeft';
elseif strcmpi(pos,'right')
    flippos=-1;
    E.txtStart='Straks verschijnt een rood kruis.\nFixeer hierop.\n\nIs de RECHTER cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
    E.paradigm='rdDpxExpRotHalfCylRight';
else
    error(['unknown pos mode ' pos]);
end

% Then the feedback option, make expname (used in output filename)
if strcmpi(fb,'feedback')
    E.paradigm=[E.paradigm 'Feedback'];
    E.txtStart=[ E.txtStart '\n\nFeedback Flits:\nGroen GOED, Rood FOUT'];
    fbCorrectStr='fbCorrect';
    fbWrongStr='fbWrong';
else
    E.paradigm=['rdDpxExpRotCyl' upper(pos(1)) lower(pos(2:end))];
    E.txtStart=[ E.txtStart '\nFeedback Flits:\nAltijd groen: Antwoord ontvangen.'];
    fbCorrectStr='fbCorrect';
    fbWrongStr='fbCorrect';
end

if strcmpi(dpxGetUserName,'Reinder')
    E.outputFolder='C:\tempdata_PleaseDeleteMeSenpai';
elseif strcmpi(dpxGetUserName,'EyeLink-admin')
    E.outputFolder='C:\Users\EyeLink-admin\Dropbox\DPX\Data\Exp1training';
end

% Set the stimulus window option
E.window.set('rectPx',[1440 0 1600+1440 1200],'widHeiMm',[394 295],'distMm',1000,'scrNr',1);
E.window.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
E.window.set('stereoMode','mirror','skipSyncTests',1);

% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run
modes={'mono','stereo','both'};
for m=1:numel(modes)
    for dsp=[-1 -.4 0 .4 1]
        for rotSpeed=[-120 120]
            C=dpxCoreCondition;
            set(C,'durSec',2.5);
            
            % The fixation cross
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
            C.addStimulus(S);
            
            % The feedback stimulus for correct responses
            S=dpxStimDot;
            set(S,'wDeg',.3,'enabled',false,'durSec',inf,'RGBAfrac',[0 1 0 .75],'name','fbCorrect');
            C.addStimulus(S);
            
            % The feedback stimulus for wrong responses
            S=dpxStimDot;
            set(S,'wDeg',.3,'enabled',false,'durSec',inf,'RGBAfrac',[1 0 0 .75],'name','fbWrong');
            C.addStimulus(S);
            
            % The full cylinder stimulus
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                ,'onSec',0,'durSec',1,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
                ,'name','fullCyl');
            C.addStimulus(S);
            
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
            elseif strcmpi(modes{m},'both')
                lumcorr=1;
                dFog=dsp;
                dScale=dsp;
                dispa=dsp;
            end
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',flippos*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',dispa,'sideToDraw','front' ...
                ,'onSec',0,'durSec',1,'stereoLumCorr',lumcorr,'fogFrac',dFog,'dotDiamScaleFrac',dScale ...
                ,'name','halfCyl');
            C.addStimulus(S);
            E.addCondition(C);
            
            % The response object
            R=dpxRespKeyboard;
            R.allowAfterSec=S.onSec+S.durSec;
            set(R,'kbNames','UpArrow,DownArrow');
            set(R,'correctStimName',fbCorrectStr,'correctEndsTrialAfterSec',10000);
            set(R,'wrongStimName',fbWrongStr,'wrongEndsTrialAfterSec',10000);
            if dsp<0
                R.correctKbNames='UpArrow';
            elseif dsp>0
                R.correctKbNames='DownArrow';
            else
                R.correctKbNames='1';
            end
            set(R,'name','rightHand');
            C.addResponse(R);
        end
    end
end
E.run;
end