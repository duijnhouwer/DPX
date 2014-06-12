function rdDpxExpRotBindTwoFullCyl()
%%report the front fields of both full cylinders
%
%%input needed: feedback excercise or not
%%i.e. rdDpxExpRotCyl('left','feedback')


E=dpxCoreExperiment;
E.txtStart='Kijk naar het rode kruisje.\n\nWelke richting draaien de voorvlakken van beide cylinders\nRechter Omhoog = Pijltje omhoog\n Rechter Omlaag = Pijltje omlaag \n\n Linker Omhoog = Linker shift\nLinker Omlaag = Linker ctrl';
E.expName='rdDpxExpBindTwoFull';

E.txtPauseNrTrials=151;
E.nRepeats=5;
E.outputFolder='/Users/laurens/Dropbox/DPX/Data/Exp3BindTwoFull';

fb='';
pos='shuffled';

E.expName=['rdDpxExpRotCyl' upper(pos(1)) lower(pos(2:end))];
E.txtStart=[ E.txtStart '\nFeedback Flits:\nAltijd grijs: Antwoord ontvangen.'];
fbCorrectStr='fbCorrect';
fbWrongStr='fbCorrect';
% Set the stimulus window option
E.physScr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
E.physScr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
E.physScr.set('stereoMode','mirror','SkipSyncTests',1);
E.windowed(false); % true, false, e.g. [10 10 410 310], for debugging

% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run
modes={'mono','stereo','anti-stereo'};
for m=1:numel(modes)
    for flippos=[-1 1];
        for dsp=[-1:.2:1]
            for rotSpeed=[-120 120]
                C=dpxCoreCondition;
                set(C,'durSec',2.5);
                % The fixation cross
                S=dpxStimCross;
                set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
                C.addStim(S);
                % The feedback stimulus for correct responses
                S=dpxStimDot;
                set(S,'wDeg',.3,'visible',false,'durSec',0.20,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
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
                
                R=dpxCoreResponse;
                set(R,'kbNames','LeftShift,LeftControl');
                set(R,'correctStimName',fbCorrectStr,'correctEndsTrialAfterSec',10000);
                set(R,'wrongStimName',fbWrongStr,'wrongEndsTrialAfterSec',10000);
                set(R,'name','leftHand');
                if rotSpeed>0 && dsp>0
                    R.correctKbNames='LeftShift';
                elseif rotSpeed>0 && dsp<0
                    R.correctKbNames='LeftControl';
                elseif rotSpeed<0 && dsp>0
                    R.correctKbNames='LeftShift';
                elseif rotSpeed<0 && dsp<0
                    R.correctKbNames='LeftControl';
                else
                    R.correctKbNames='1';
                end
                C.addResp(R);
                
                % The full cylinder stimulus
                S=dpxStimRotCylinder;
                set(S,'dotsPerSqrDeg',12,'xDeg',flippos*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                    ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                    ,'onSec',0,'durSec',1,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
                    ,'name','fullTargetCyl');
                C.addStim(S);
                % The full inducer cylinder stimulus
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
                end
                S=dpxStimRotCylinder;
                set(S,'dotsPerSqrDeg',12,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                    ,'rotSpeedDeg',rotSpeed,'disparityFrac',dispa,'sideToDraw','both' ...
                    ,'onSec',0,'durSec',1,'stereoLumCorr',lumcorr,'fogFrac',dFog,'dotDiamScaleFrac',dScale ...
                    ,'name','fullInducerCyl');
                C.addStim(S);
                %
                E.addCondition(C);
            end
        end
    end
end
E.run;
end