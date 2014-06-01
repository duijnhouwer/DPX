function jdDpxRotCylExp
    
    E=dpxCoreExperiment;
    E.windowed(true); % true, false, [0 0 410 310]+100
    E.physScr.stereoMode='mono'; 
    for rotSpeed=[-120 120]
        C=dpxCoreCondition;
        set(C,'durSec',2);
        % The fixation dot
        S=dpxStimFix;
        set(S,'name','fix');
        C.addStim(S);
        % The feedback stimulus for correct responses
        S=dpxStimFix;
        set(S,'wDeg',2,'visible',false,'durSec',0.05,'RGBAfrac',[0 1 0 .5],'name','fbCorrect');
        C.addStim(S);
        % The feedback stimulus for wrong responses
        S=dpxStimFix;
        set(S,'wDeg',3,'visible',false,'durSec',0.15,'RGBAfrac',[1 0 0 .5],'name','fbWrong');
        C.addStim(S);
        % The response object
        R=dpxCoreResponse;
        set(R,'correctKbNames','LeftArrow','correctStimName','fbCorrect','correctEndsTrialAfterSec',.05,'wrongStimName','fbWrong','wrongEndsTrialAfterSec',.15,'name','resp');
        C.addResp(R);
        % The cylinder stimulus
        S=dpxStimRotCylinder;
        set(S,'rotSpeedDeg',rotSpeed,'name','cyl');
        C.addStim(S);
        %
        E.addCondition(C);
    end
    E.run;
end