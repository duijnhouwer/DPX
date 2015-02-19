 function TWtest
% 02-02-15 
% Binocular rivalry experiment with gratings 
% C refreshes 124 times

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWtest';

Language = input('NL(1)/EN(2):');
if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los \n om het experiment te starten.\nReageer met de linker- en\n rechter controltoets.\n');
E.txtEnd= 'Einde van het experiment.';
end

if Language ==2
E.txtStart = sprintf('Press and release $STARTKEY \n to start the experiment.\nUse left and right\n control key to respond.\n');
E.txtEnd= 'End of the experiment.';
end

E.breakFixTimeOutSec=0;
%E.outputFolder='C:\dpxData\';

set=0;                                                                      % screen settings for philips screen
if set ==0
E.scr.set('winRectPx',[],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',0); 
else 
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[390 295], ...     % screen settings for eyelink
        'distMm',1000, 'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',1);
end

% generate Tofftimes with a shuffled order
Toff=[0.25,0.5,1]; 
shuffle = [randperm(3); Toff]; 
Toff = sortrows(shuffle',1); 
Toff = Toff(:,2);


        C = dpxCoreCondition
        C.durSec=60; 
        i=1;
        
        for time = 0:1.5:58.5
            i=i+1; 
            
        ML = dpxStimMaskCircle;
        ML.name=sprintf('StimMaskCircle%d', i);
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1];
        ML.durSec=1; 
        ML.onSec=time; 
        C.addStim(ML);
    
        GL = dpxStimGrating;
        GL.name = sprintf('StimGrating%d', i);
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec=1; 
        GL.onSec=time; 
        C.addStim(GL);
        
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        Dot.durSec=1; 
        Dot.onSec=time; 
        C.addStim(Dot);
                
        MR = dpxStimMaskCircle;
        MR.name=sprintf('StimMaskCircle%d', i);
        MR.xDeg=0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.durSec=1; 
        MR.onSec=time; 
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6./2.2;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec=1;
        GR.onSec=time;
        C.addStim(GR);
             
        E.addCondition(C); 
 end
        
    E.conditionSequence = 1:numel(E.conditions);
    E.run;
    sca; 
end