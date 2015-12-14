function jdDpxRdkExp
    E=dpxCoreExperiment;
    E.window.stereoMode='mono';
    for x=[-12 12]
        C=dpxCoreCondition;
        S=dpxStimDot;
        S.wDeg=1;
        S.hDeg=1;
        C.addStimulus(S);
        C.addResponse(dpxCoreResponse);
        C.durSec=2;
        S=dpxStimRdk;
        set(S,'xDeg',x);
        C.addStimulus(S);
        E.addCondition(C);
    end
    E.run; 
end
