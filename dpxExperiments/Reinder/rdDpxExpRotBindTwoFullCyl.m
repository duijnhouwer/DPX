function rdDpxExpRotBindTwoFullCyl()
%%report the front fields of both full cylinders
%
%%input needed: none
%%i.e. rdDpxExpRotFullCyl()

fb='';
pos='shuffled';

E=dpxCoreExperiment;
E.txtPauseNrTrials=151;
E.nRepeats=5;

E.txtStart='Kijk naar het rode kruisje.\n\nWelke richting draaien de voorvlakken van beide cylinders\nRechter Omhoog = Pijltje omhoog\n Rechter Omlaag = Pijltje omlaag \n\n Linker Omhoog = Linker shift\nLinker Omlaag = Linker ctrl';
E.expName='rdDpxExpBindTwoFull';
E.expName=['rdDpxExpRotCyl' upper(pos(1)) lower(pos(2:end))];
E.txtStart=[ E.txtStart '\nFeedback Flits:\nAltijd grijs: Antwoord ontvangen.'];

% Folder options
if strcmpi(dpxGetUserName,'Reinder')
    E.outputFolder='C:\tempdata_PleaseDeleteMeSenpai';
elseif strcmpi(dpxGetUserName,'EyeLink-admin')
    E.outputFolder='C:\Users\EyeLink-admin\Dropbox\DPX\Data\Exp3BindTwoFull';
end

% Set the stimulus window option
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[394 295],'distMm',1000,'scrNr',1);
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1]);
E.scr.set('stereoMode','mirror','skipSyncTests',1);

% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run
modes={'mono','stereo','anti-stereo'};
for m=1:numel(modes)
    for flippos=[-1 1];
        for dsp=[0:.2:1]
            for rotSpeed=[-120 120]
                C=dpxCoreCondition;
                set(C,'durSec',2.5);
                
                % The fixation cross
                S=dpxStimCross;
                set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
                C.addStim(S);
                
                % The feedback stimulus for correct responses
                S=dpxStimDot;
                set(S,'wDeg',.3,'xDeg',-0.2,'visible',false,'durSec',inf,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrectLeft');
                C.addStim(S);
                
                S=dpxStimDot;
                set(S,'wDeg',.3,'xDeg',0.2,'visible',false,'durSec',inf,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrectRight');
                C.addStim(S);
                    
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
                
                % The right hand response object
                R=dpxRespKeyboard;
                R.allowAfterSec=S.onSec+S.durSec;
                set(R,'kbNames','UpArrow,DownArrow');
                set(R,'correctStimName','fbCorrectRight','correctEndsTrialAfterSec',10000);
                set(R,'name','rightHand');
                R.correctKbNames='1';
                C.addResp(R);
                
                % The left hand response object
                R=dpxRespKeyboard;
                R.allowAfterSec=S.onSec+S.durSec;
                set(R,'kbNames','a,z');
                set(R,'correctStimName','fbCorrectLeft','correctEndsTrialAfterSec',10000);
                set(R,'name','leftHand');
                R.correctKbNames='1';
                C.addResp(R);
                
                E.addCondition(C);
            end
        end
    end
end
E.run;
end