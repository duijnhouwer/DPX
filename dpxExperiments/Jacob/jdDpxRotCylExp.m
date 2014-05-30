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
        % The response feedback stimulus
        S=dpxStimFix;
        set(S,'wDeg',3,'visible',false,'name','feedback');
        C.addStim(S);
        % The response object
        R=dpxCoreResponse;
        set(R,'correctKbNames','1','correctStimName','feedback','name','resp');
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