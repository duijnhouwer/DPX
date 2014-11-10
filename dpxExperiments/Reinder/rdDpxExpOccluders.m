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

E.physScr.set('winRectPx',[0 0 800 600],'widHeiMm',[394 295],'distMm',1000);
E.physScr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0 0 0 1]);
E.physScr.set('stereoMode','mirror','SkipSyncTests',1);
E.windowed(false);

nRecallPics=5;
barConfigs={'even','uneven'};
for B=1:numel(barConfigs)
    for dsp=[-1:1]
        C=dpxCoreCondition;
        set(C,'durSec',16.5)
        
        %fix cross
        for c=1:nRecallPics
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name',['fix' num2str(c)]);
            set(S,'durSec',1.5,'onSec',6.6+2.1*(c-1))
            C.addStim(S);
        end
        
        %feedback stim
        S=dpxStimDot;
        set(S,'wDeg',.3,'visible',false,'durSec',0.20,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
        C.addStim(S);
        
        % response objects
        R=dpxCoreResponse;
        set(R,'KbNames','UpArrow,DownArrow');
        set(R,'name','recallOne');
        set(R,'correctStimName','fbCorrect','correctEndsTrialAfterSec',10000);
        set(R,'wrongStimName','fbCorrect','wrongEndsTrialAfterSec',10000);
        set(R,'allowAfterSec',6.6);
        set(R,'allowUntilSec',7.1);
        C.addResp(R);
        
        R=dpxCoreResponse;
        set(R,'KbNames','UpArrow,DownArrow');
        set(R,'name','recallTwo');
        set(R,'correctStimName','fbCorrect','correctEndsTrialAfterSec',10000);
        set(R,'wrongStimName','fbCorrect','wrongEndsTrialAfterSec',10000);
        set(R,'allowAfterSec',7.7);
        set(R,'allowUntilSec',9.2);
        C.addResp(R);
        
        %first pictures, encoding
        S=dpxStimImage;
        set(S,'mode','Encode','durSec',5,'wDeg',1); %input=PicFolder
        set(S,'name','EncodingPics');
        C.addStim(S);
        
        %second pictues, recall
        T=(0.6+1.5); %stim duration plus its pause until next
        for t=1:nRecallPics
            onSet=6+T*(t-1);
            S=dpxStimImage;
            set(S,'mode','Recall','durSec',0.6,'onSec',onSet,'wDeg',1); %input=PicFolder
            set(S,'NrBars',4,'HorDisp',1,'BarConfig',barConfigs{B}) 
            set(S,'name',['RecallPic' num2str(t)] );
            C.addStim(S);
            
            E.addCondition(C);
        end
    end
end
E.run
end

