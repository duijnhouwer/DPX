function dpxRotCylExperiment
    
    
    E=dpxBasicExperiment;
    E.physScr.stereoMode='mirror';
    E.physScr.winRectPx=[];%[50 100 400 300];
    set(E.conditions.stims{1},'durSecs',2);
    tmp=dpxStimRotCylinder;
    tmp.stereoLumCorr=-1;
    tmp.xDeg=-8;
    E.conditions.addStim(tmp,'inducer');
    tmp=dpxStimRotCylinder;
    tmp.xDeg=8;
    tmp.sideToDraw='both';
    E.conditions.addStim(tmp,'target');
    E.condition.durSec=2;
    E.run;
    
end