function rdDpxExpRotCylFeedback(pos)
   
    E=dpxCoreExperiment;
    if strcmpi(pos,'left')
        flippos=1;
        E.txtStart='Kijk naar de rode stip. Is de LINKER cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.expName='rdDpxExpRotCylFeedbackLeft';
    elseif strcmpi(pos,'right')
        flippos=-1;
        E.txtStart='Kijk naar de rode stip. Is de RECHTER cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.expName='rdDpxExpRotCylFeedbackRight';
    else
        error(['unknown pos: ' pos]);
    end
    E.txtPauseNrTrials=10;
    E.nRepeats=5;
    E.outputFolder='';
    E.physScr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000 ...
        ,'interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1] ...
        ,'stereoMode','mirror','SkipSyncTests',1);
    E.windowed(true); % true, false, [0 0 410 310]+100
    
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
                set(R,'correctStimName','fbCorrect','correctEndsTrialAfterSec',10000);
                set(R,'wrongStimName','fbWrong','wrongEndsTrialAfterSec',10000);
                set(R,'name','resp');
                if dsp<0
                    R.correctKbNames='UpArrow';
                elseif dsp>0
                    R.correctKbNames='DownArrow';
                else
                    R.correctKbNames='1';
                end
                C.addResp(R);
                % Add the two cylinders
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
                % The full cylinder stimulus
                S=dpxStimRotCylinder;
                set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                    ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                    ,'onSec',0,'durSec',1,'stereoLumCorr',lumcorr ...
                    ,'name','fullCyl');
                C.addStim(S);
                % The half cylinder stimulus
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