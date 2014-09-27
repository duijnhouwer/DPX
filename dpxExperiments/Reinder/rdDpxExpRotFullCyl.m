function rdDpxExpRotFullCyl(pos,fb)
%%second feedback exercize, report the full cylinder
%%no inducer is present because we don't want any binding yet!
%
%%input needed: feedback excercise or not
%%position of where the inducer SHOULD BE (so left --> target on right)
%%this weird construction is because we want the position in all
%%experiments defined as the inducer position. 
%%i.e. rdDpxExpRotCyl('left','feedback') in this case is a full cylinder on
%%the right!!

if nargin==1
    fb='feedback';
end

E=dpxCoreExperiment;
% handle the position option
if strcmpi(pos,'left')
    flippos=1;
    E.txtStart='Kijk naar het rode kruisje.\n\nWelke richting draait het VOORVLAK van de volle cylinder?\nOmhoog = Pijltje omhoog\nOmlaag = Pijltje omlaag';
    E.expName='rdDpxExpRotFullCylLeft';
elseif strcmpi(pos,'right')
    flippos=-1;
    E.txtStart='Kijk naar het rode kruisje.\n\nWelke richting draait het VOORVLAK van de volle cylinder?\nOmhoog = Pijltje omhoog\nOmlaag = Pijltje omlaag';
    E.expName='rdDpxExpRotFullCylRight';
else
    error(['unknown pos mode ' pos]);
end


% Then the feedback option, make expname (used in output filename)
if strcmpi(fb,'feedback')
    E.expName=[E.expName 'Feedback'];
    E.txtStart=[ E.txtStart '\n\nFeedback Flits:\nGroen GOED, Rood FOUT'];
    fbCorrectStr='fbCorrect';
    fbWrongStr='fbWrong';
else
    E.expName=['rdDpxExpRotCyl' upper(pos(1)) lower(pos(2:end))];
    E.txtStart=[ E.txtStart '\nFeedback Flits:\nAltijd groen: Antwoord ontvangen.'];
    fbCorrectStr='fbCorrect';
    fbWrongStr='fbCorrect';
end

E.txtPauseNrTrials=151;
E.nRepeats=5;
E.outputFolder='/Users/laurens/Dropbox/DPX/Data/Exp1training';

% Set the stimulus window option
E.scr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
E.scr.set('stereoMode','mirror','SkipSyncTests',1);
E.windowed(false); % true, false, e.g. [10 10 410 310], for debugging

% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run
modes={'mono','stereo','both'};
for m=1:numel(modes)
    for dsp=[0:.5:1]
        for rotSpeed=[-120 120]
            C=dpxCoreCondition;
            set(C,'durSec',2.5);
            % The fixation cross
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
            C.addStim(S);
            % The feedback stimulus for correct responses
            S=dpxStimDot;
            set(S,'wDeg',.3,'visible',false,'durSec',0.10,'RGBAfrac',[0 1 0 .75],'name','fbCorrect');
            C.addStim(S);
            % The feedback stimulus for wrong responses
            S=dpxStimDot;
            set(S,'wDeg',.3,'visible',false,'durSec',0.15,'RGBAfrac',[1 0 0 .75],'name','fbWrong');
            C.addStim(S);
            % The response object
            R=dpxCoreResponse;
            set(R,'kbNames','UpArrow,DownArrow');
            set(R,'correctStimName',fbCorrectStr,'correctEndsTrialAfterSec',10000);
            set(R,'wrongStimName',fbWrongStr,'wrongEndsTrialAfterSec',10000);
            set(R,'name','rightHand');
            if rotSpeed>0 && dsp>0
                R.correctKbNames='UpArrow';
            elseif rotSpeed>0 && dsp<0
                R.correctKbNames='DownArrow';
            elseif rotSpeed<0 && dsp>0
                R.correctKbNames='DownArrow';
            elseif rotSpeed<0 && dsp<0
                R.correctKbNames='UpArrow';
            else
                R.correctKbNames='1';
            end
            C.addResp(R);
            % The full cylinder stimulus
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','front' ...
                ,'onSec',0,'durSec',1,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
                ,'name','halveCyl','visible',0);
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
            elseif strcmpi(modes{m},'both')
                lumcorr=1;
                dFog=dsp;
                dScale=dsp;
                dispa=dsp;
            end
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',dispa,'sideToDraw','both' ...
                ,'onSec',0,'durSec',1,'stereoLumCorr',lumcorr,'fogFrac',dFog,'dotDiamScaleFrac',dScale ...
                ,'name','fullCyl');
            C.addStim(S);
            %
            E.addCondition(C);
        end
    end
end
E.run;
end