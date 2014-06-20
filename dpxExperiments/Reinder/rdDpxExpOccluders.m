function rdDpxExpOccluders()
E=DpxCoreExperiment

E.txtStart='textstart';
E.expName='rdDpxExpOccluders';
E.repeats=10;
E.txtPauseNrTrials=5;
E.nRepeats=5;
E.outputFolder='';

E.physScr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
E.physScr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0 0 0 1]);
E.physScr.set('stereoMode','mirror','SkipSyncTests',1);
E.windowed(true);

barConfigs={'even','uneven'};
for B=1:numel(barConfigs)
    for dsp=[-1:1]
        C=dpxCoreCondition
        set(C,'durSec',5+1+0.6+'responsetijd?')
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
        S=dpxStimOccluders;
        set(S,'NrEncoding',5,'NrBars',4,'barConfig',barConfigs{B}...
            ,'disparityFrac',dsp,'durSec',5,'name','EncodePics');
        C.addStim(S);
        
        %second pictures, recall
        S=dpxStimRecallOccluders;
        set(S,'NrRecall',5,'NrBars',4,'barConfig',barConfigs{B}...
            ,'disparityFrac',dsp,'onSec',5+1,'durSec',0.6...
            ,'name','EncodePics');
        C.addStim(S);
        
        E.addCondition(C);
    end
end
E.Run;
end

