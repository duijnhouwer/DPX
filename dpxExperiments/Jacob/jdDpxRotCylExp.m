function jdDpxRotCylExp
    
    E=dpxCoreExperiment;
    E.windowed(false); % true, false, [0 0 410 310]+100
    E.physScr.set('winRectPx',[0 0 1600 1200],'widHeiMm',[394 295],'distMm',1000 ...
        ,'interEyeMm',65,'gamma',0.49,'backRGBA',[0.5 0.5 0.5 1] ...
        ,'stereoMode','mirror','SkipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-06-02]
    E.txtStart='Kijk naar de rode stip. Is linker cylinder hol of bol?\nHol = Pijltje omhoog\nBol=Pijltje omlaag';
    
    
    for dsp=[-1:.2:1]
        for rotSpeed=[-120 120]
            C=dpxCoreCondition;
            set(C,'durSec',2.5);
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
            % The distractor cylinder stimulus
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                ,'onSec',0,'durSec',1 ...
                ,'name','distractor');
            C.addStim(S);
            % The target cylinder stimulus
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',12,'xDeg',-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',dsp,'sideToDraw','front' ...
                ,'onSec',0,'durSec',1 ...
                ,'name','target');
            C.addStim(S);
            %
            E.addCondition(C);
        end
    end
    %HideCursor;
    E.run;
end