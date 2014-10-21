function jdDpxRdkExp
    E=dpxCoreExperiment;
    E.scr.stereoMode='mono';
    for x=[-12 12]
        C=dpxCoreCondition;
        S=dpxStimDot;
        S.wDeg=1;
        S.hDeg=1;
        C.addStim(S);
        C.addResp(dpxCoreResponse);
        C.durSec=2;
        S=dpxStimRdk;
        set(S,'xDeg',x);
        C.addStim(S);
        E.addCondition(C);
    end
    E.run; 
end
