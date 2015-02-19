 function TWBRadaptationexperiment
% 02-02-15 
% Binocular rivalry experiment with gratings 
% C refreshes 124 times

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWBRadaptationexperiment';

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
Toff=Toff(:,2);

% for Ton=[8, 1];    
%     C=dpxCoreCondition;     
%     C.durSec = Ton;
%      
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % STIMULUS presntation at the left side of the screen
%                  
%         LeftCheck=dpxStimCheckerboard;
%         LeftCheck.name='checksLeft';
%         LeftCheck.RGBAfrac=[.5 .5 .5 1];
%         LeftCheck.xDeg=0;
%         LeftCheck.wDeg=5.6;
%         LeftCheck.hDeg=5.6;
%         LeftCheck.contrast=.8;
%         LeftCheck.nHoleHori=8;
%         LeftCheck.nHoleVert=8;
%         LeftCheck.sparseness=0;
%         LeftCheck.durSec = Ton; 
%         C.addStim(LeftCheck);
%         
%         ML = dpxStimMaskCircle;
%         ML.name='maskLeft';
%         ML.xDeg=0;
%         ML.hDeg = 3.2; 
%         ML.wDeg = 3.2;
%         ML.innerDiamDeg=0;
%         ML.outerDiamDeg=2.2;
%         ML.RGBAfrac=[.5 .5 .5 1];
%         ML.durSec=Ton; 
%         C.addStim(ML);
%     
%         GL = dpxStimGrating;
%         GL.name = 'gratingLeft';
%         GL.xDeg=0;
%         GL.dirDeg=-45;
%         GL.squareWave=false;
%         GL.cyclesPerSecond=0;
%         GL.cyclesPerDeg=6./2.2;
%         GL.wDeg=2.2;
%         GL.hDeg=2.2;    
%         GL.durSec=Ton; 
%         C.addStim(GL);
%           
%         Dot = dpxStimDot;
%         Dot.name = 'Dot';
%         Dot.xDeg=0; 
%         Dot.wDeg=0;
%         Dot.hDeg=0;
%         C.addStim(Dot);
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % STIMULUS presentation at the right side of the screen
%         
%         RightCheck=dpxStimCheckerboard;
%         RightCheck.name='checksRight';
%         RightCheck.RGBAfrac=[.5 .5 .5 1];
%         RightCheck.xDeg=0;
%         RightCheck.wDeg=5.6;
%         RightCheck.hDeg=5.6;
%         RightCheck.contrast=.8;
%         RightCheck.nHoleHori=8;
%         RightCheck.nHoleVert=8;
%         RightCheck.sparseness=0;
%         %RightCheck.rndSeed=LeftCheck.rndSeed;
%         C.addStim(RightCheck);
%         
%         MR = dpxStimMaskCircle;
%         MR.name='maskRight';
%         MR.xDeg=0;
%         MR.hDeg = 3.2; 
%         MR.wDeg = 3.2;
%         MR.innerDiamDeg=0;
%         MR.outerDiamDeg=2.2;
%         MR.RGBAfrac=[.5 .5 .5 1];
%         MR.durSec=Ton; 
%         C.addStim(MR);
% 
%         GR = dpxStimGrating;
%         GR.name = 'gratingRight';
%         GR.xDeg=0;
%         GR.dirDeg=45;
%         GR.squareWave=false;
%         GR.cyclesPerSecond=0;
%         GR.cyclesPerDeg=6./2.2;
%         GR.wDeg=2.2;
%         GR.hDeg=2.2;      
%         GR.durSec=Ton;
%         C.addStim(GR);
%         
%         if Ton==8
%         R=dpxRespKeyboard;
%         R.name='keyboard1';
%         R.kbNames='LeftControl,RightControl';
%         R.allowAfterSec=0;
%         R.correctEndsTrialAfterSec=Ton;
%         C.addResp(R);
%         end
%      
%         E.addCondition(C);
% 
% end
% 
%         PA = dpxStimPause;
%         PA.name = 'PA1'; 
%         PA.durSec=Inf;
%         PA.onSec = 0; 
%         if  Language==1
%         PA.textPause1 = 'Pauze'; 
%         else
%         PA.textPause1= 'Interception'; 
%         end
%         C.addStim(PA);
%         
%         E.addCondition(C);

for i = 1:length(Toff)
    D = dpxCoreCondition;
    D.durSec = Inf;
    
    if i<3
        cont = 3; 
        adap= 2;  
    else 
        cont = []; 
        adap =[];                                                          % scraps the two (unnecessary) adaptation trials at the end 
    end
    
    rep = 6./(1+Toff(i));                                                   %length of interleaved percept choice sequences = 60 seconds (1 min)  
    
    for j=1:3
        C = dpxCoreCondition; 
        C.durSec = Ton + OffTime;
    for Ton = [0.5*ones(1,20)];
        C = dpxCoreCondition; 
       
        if Ton==1
        OffTime = Toff(i); 
        else 
        OffTime = 0;
        en  
                 
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[.5 .5 .5 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=5.6;
        LeftCheck.hDeg=5.6;
        LeftCheck.contrast=.9;
        LeftCheck.nHoleHori=8;
        LeftCheck.nHoleVert=8;
        LeftCheck.sparseness=0;
        LeftCheck.durSec = Inf; 
        LeftCheck.onSec = 0; 
        C.addStim(LeftCheck);
        
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[.5 .5 .5 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=5.6;
        RightCheck.hDeg=5.6;
        RightCheck.contrast=.9;
        RightCheck.nHoleHori=8;
        RightCheck.nHoleVert=8;
        RightCheck.sparseness=0;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        RightCheck.durSec = Inf; 
        RightCheck.onSec = 0; 
        C.addStim(RightCheck);
           
    end
    
        GL = dpxStimGrating;
        GL.name = 'gratingLeft';
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec = Ton; 
        GL.onSec = OffTime;
        C.addStim(GL);
    
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
    
        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6./2.2;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec = Ton; 
        GR.onSec = OffTime; 
        C.addStim(GR);
           
        E.addCondition(C); 
    
end
    
        PA = dpxStimPause;
        PA.name = 'PA2'; 
        PA.durSec=Inf; 
        PA.onSec = 0; 
        if  Language==1
        PA.textPause1=sprintf('Uitgevoerd: %d/3', i);
        PA.textPause2='Druk op spatiebar om door te gaan'; 
        else
        PA.textPause1=sprintf('Completed part: %d/3', i);
        PA.textPause2='Press and release spacekey to continue';
        end
        D.addStim(PA);
      
        R=dpxRespKeyboard;
        R.name='keyboard3';
        R.kbNames= 'space' ;
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=0;
        D.addResp(R);
        
      E.addCondition(D);
end 
    E.conditionSequence = 1:numel(E.conditions);
    E.run;
    sca; 
end