function jdDpxRdkExp
    
    E=dpxCoreExperiment;
    E.windowed(true); % true, false, [0 0 410 310]+100
    E.physScr.stereoMode='mono';
    for x=[-12 12]
        C=dpxCoreCondition;
        C.addStim(dpxStimFix);
        C.addResp(dpxCoreResponse);
        C.durSec=2;
        S=dpxStimRdk;
        set(S,'xDeg',x);
        C.addStim(S);
        E.addCondition(C);
    end
    E.run;
    
    
end
