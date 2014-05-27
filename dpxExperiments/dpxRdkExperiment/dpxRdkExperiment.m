function dpxRdkExperiment
    
    E=dpxBasicExperiment;
    E.physScr.winRectPx=[];
    tmp=dpxStimRdk;
    tmp.xDeg=-10;
    tmp.dirDeg=90;
    E.conditions.addStim(tmp,'left');
    tmp=dpxStimRdk;
    tmp.xDeg=10;
    E.conditions.addStim(tmp,'right');
    E.condition.durSec=6;
    E.run;
    
end
