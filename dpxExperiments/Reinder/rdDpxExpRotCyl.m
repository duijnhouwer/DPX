function rdDpxExpRotCyl(pos,fb)
   
    E=dpxCoreExperiment;
    % handle the position option
    if strcmpi(pos,'left') && strcmpi(fb,'feedback')
        flippos=1;
        E.txtStart='Kijk naar de rode stip.\nIs de LINKER cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.expName='rdDpxExpRotCylFeedbackLeft';
    elseif strcmpi(pos,'right') && strcmpi(fb,'feedback')
        flippos=-1;
        E.txtStart='Kijk naar de rode stip.\nIs de RECHTER cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.expName='rdDpxExpRotCylFeedbackRight';  
    else
        error(['unknown pos mode ' pos]);
    end
    % Then the feedback option, make expname (used in output filename)
    if strcmpi(fb,'feedback')
        E.txtStart=[ E.txtStart '\nFeedback Flits:\nGroen GOED\nRood FOUT'];
        fbCorrectStr='fbCorrect';
        fbWrongStr='fbWrong';
    else
        E.expName=['rdDpxExpRotCyl' upper(pos(1)) lower(pos(2:end))];
        E.txtStart=[ E.txtStart '\nFeedback Flits:\nAltijd groen: Antwoord ontvangen.'];
        fbCorrectStr='fbCorrect';
        fbWrongStr='fbCorrect';
    end
    
    E.txtPauseNrTrials=10;
    E.nRepeats=5;
    E.outputFolder='';
    
    % Set the stimulus window option
    E.physScr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
    E.physScr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
    E.physScr.set('stereoMode','mirror','SkipSyncTests',1);
    E.windowed(true); % true, false, e.g. [10 10 410 310], for debugging
    
    % Add stimuli and responses to the conditions, add the conditions to
    % the experiement, and run
    modes={'mono','stereo','antistereo'};
    for m=1:numel(modes)
        for dsp=[-1:.5:1]
            for rotSpeed=[-120 120]
                C=dpxCoreCondition;
                set(C,'durSec',1.5);
                % The fixation dot
                S=dpxStimFix;
                set(S,'wDeg',.15,'name','fix');
                C.addStim(S);
                % The feedback stimulus for correct responses
                S=dpxStimFix;
                set(S,'wDeg',.3,'visible',false,'durSec',0.05,'RGBAfrac',[0 1 0 .75],'name','fbCorrect');
                C.addStim(S);
                % The feedback stimulus for wrong responses
                S=dpxStimFix;
                set(S,'wDeg',.3,'visible',false,'durSec',0.15,'RGBAfrac',[1 0 0 .75],'name','fbWrong');
                C.addStim(S);
                % The response object
                R=dpxCoreResponse;
                set(R,'kbNames','UpArrow,DownArrow');
                set(R,'correctStimName',fbCorrectStr,'correctEndsTrialAfterSec',10000);
                set(R,'wrongStimName',fbWrongStr,'wrongEndsTrialAfterSec',10000);
                set(R,'name','resp');
                if dsp<0
                    R.correctKbNames='UpArrow';
                elseif dsp>0
                    R.correctKbNames='DownArrow';
                else
                    R.correctKbNames='1';
                end
                C.addResp(R);
                % The full cylinder stimulus
                S=dpxStimRotCylinder;
                set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                    ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                    ,'onSec',0,'durSec',1,'stereoLumCorr',1 ...
                    ,'name','fullCyl');
                C.addStim(S);
                % The half cylinder stimulus
                if strcmpi(modes{m},'mono')
                    lumcorr=1;
                    fog=1;
                    dispa=0;
                elseif strcmpi(modes{m},'stereo')
                    lumcorr=1;
                    fog=0;
                    dispa=dsp;
                elseif strcmpi(modes{m},'antistereo')
                    lumcorr=-1;
                    fog=0;
                    dispa=dsp;
                end
                S=dpxStimRotCylinder;
                set(S,'dotsPerSqrDeg',12,'xDeg',flippos*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                    ,'rotSpeedDeg',rotSpeed,'disparityFrac',dispa,'sideToDraw','front' ...
                    ,'onSec',0,'durSec',1,'stereoLumCorr',lumcorr ...
                    ,'name','halfCyl');
                C.addStim(S);
                %
                E.addCondition(C);
            end
        end
    end
    E.run;
end