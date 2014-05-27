function jdDpxRdkExp
    
    E=dpxBasicExperiment;
    E.windowed;
    set(E.conditions.stims{1},'durSecs',2);
    tmp=dpxStimRdk;
    tmp.xDeg=-10;
    tmp.dirDeg=90;
    E.conditions.addStim(tmp,'left');
    tmp=dpxStimRdk;
    tmp.xDeg=10;
    E.conditions.addStim(tmp,'right');
    E.condition.durSec=2;
    E.run;
    
end
