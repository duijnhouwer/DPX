function jdDpxRotCylExp
    
    E=dpxBasicExperiment;
    E.windowed(false); % true, false, [0 0 410 310]+100
    E.physScr.stereoMode='mono';    
    for rotSpeed=[-120 120]
        C=dpxBasicCondition;
        C.durSec=2;
        S=dpxStimRotCylinder;
        set(S,'rotSpeedDeg',rotSpeed);
        C.addStim(S);
        E.addCondition(C);
    end
    E.run;
end