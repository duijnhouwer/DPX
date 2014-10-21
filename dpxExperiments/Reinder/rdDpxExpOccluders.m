function rdDpxExpOccluders()

if IsWin
    DisableKeysForKbCheck([233]);
end

E=dpxCoreExperiment;

E.txtStart='textstart';
E.expName='rdDpxExpOccluders';
E.nRepeats=10;
E.txtPauseNrTrials=5;
E.nRepeats=1;
E.outputFolder='';

E.scr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0 0 0 1]);
E.scr.set('stereoMode','mirror','SkipSyncTests',1);

barConfigs={'even','uneven'};
for B=1:numel(barConfigs)
    for dsp=[-1:1]
        C=dpxCoreCondition;
        set(C,'durSec',1)%+'responsetijd?')
        %responsetijd moet afgepakt indien antwoord
  
        %fix cross
        S=dpxStimCross;
        set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
        C.addStim(S);
        
        % response object
        R=dpxCoreResponse;
        set(R,'KbNames','1!,0)');
        set(R,'name','recall');
        C.addResp(R);
        
        %first pictures, encoding
        S=dpxStimImage;
        set(S,'wDeg',4);
        C.addStim(S);

        E.addCondition(C);
    end
end
E.run
end

