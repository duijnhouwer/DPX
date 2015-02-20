 function TWBRadaptationexperiment
% 09-02-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWBRadaptationexperiment';

W =dpxCoreWindow;

Language = input('NL(1)/EN(2):');
if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los \n om het experiment te starten.\n\n Druk eenmalig op de \n linker- en rechter controltoets.\n Interrupties: druk voor elke interruptie. \n  Continu: druk bij elke nieuwe waarneming.');
E.txtEnd= 'Einde van het experiment';
end

if Language ==2
E.txtStart = sprintf('Press and release $STARTKEY \n to start the experiment.\n\n Press left and right\n control key once to respond.\n Interruption: press before each interruption. \n Continuous: press for every new percept.');
E.txtEnd= 'End of the experiment';
end

E.breakFixTimeOutSec=0;
E.outputFolder='C:\dpxData';

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

trialLength=60; 
% generate Toff Times with a shuffled order
Toff = [0.25,0.5,1]; 
shuffle = [randperm(3); Toff]; 
Toff = sortrows(shuffle',1); 
Toff = Toff(:,2);
k = 0; 
cont0 = 8;                                                                  % s, this should be 480 for the 'real experiment'
adap0 = 1;                                                                  % S, this should be 1 for the 'real experiment'

for Ton=[cont0, adap0];   
    k=k+1;
    C=dpxCoreCondition;    
    C.durSec = Ton;
     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the left side of the screen
                 
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[1 1 1 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=200/W.deg2px;
        LeftCheck.hDeg=200/W.deg2px; 
        LeftCheck.contrast=.75;
        LeftCheck.nHoleHori=10;
        LeftCheck.nHoleVert=10;
        LeftCheck.nHori=18;
        LeftCheck.nVert=18;
        LeftCheck.sparseness=2/3;
        LeftCheck.durSec = Ton; 
        C.addStim(LeftCheck);
        
        ML = dpxStimMaskCircle;
        ML.name='MaskCircleLeft';
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1];
        ML.durSec=Ton; 
        C.addStim(ML);
    
        GL = dpxStimGrating;
        GL.name = 'gratingLeft';
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=1.75;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec=Ton; 
        C.addStim(GL);
          
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck = dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[1 1 1 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=200/W.deg2px;
        RightCheck.hDeg=200/W.deg2px;
        RightCheck.contrast=.75;
        RightCheck.nHori=18;
        RightCheck.nVert=18;
        RightCheck.nHoleHori=10;
        RightCheck.nHoleVert=10;
        RightCheck.sparseness=2/3;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RightCheck);
        
        MR = dpxStimMaskCircle;
        MR.name='MaskCircleRight';
        MR.xDeg=0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.durSec=Ton; 
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=1.75;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec=Ton;
        C.addStim(GR);
        
        if Ton==cont0
        R=dpxRespKeyboard;
        R.name='keyboard1';
        R.kbNames='LeftControl,RightControl';
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=Ton;
        C.addResp(R);
        end  
           
        E.addCondition(C);        
end
        
for i = 1:length(Toff)
    D = dpxCoreCondition;
    D.durSec = Inf;
    
    if i<3
        cont = 30; 
        adap= 30;  
    else 
        cont = []; 
        adap = [];                                                          % scraps the two (unnecessary) adaptation trials at the end 
    end
    
    rep = trialLength./(1+Toff(i));                                          % length of interleaved percept choice sequences = 60 seconds (1 min)  
    if mod(rep,1) ~0
        error('The trial length should be divisble by 30'); 
    end
    
    j = 0; 
    for Ton = [trialLength, cont, adap];
        j = j+1;
        C = dpxCoreCondition; 
        B = dpxCoreCondition;
        
        if Ton==60
        offTime = Toff(i); 
        else 
        offTime = 0;
        end
        
        C.durSec = Ton;

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the left side of the screen     
       
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[1 1 1 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=200/W.deg2px;
        LeftCheck.hDeg=200/W.deg2px; 
        LeftCheck.contrast=.75;
        LeftCheck.nHoleHori=10;
        LeftCheck.nHoleVert=10;
        LeftCheck.nHori=18;
        LeftCheck.nVert=18;
        LeftCheck.sparseness=2/3;
        LeftCheck.durSec = Inf; 
        LeftCheck.onSec = 0; 
        C.addStim(LeftCheck);
        
        for nRepeats=1:rep
        ML = dpxStimMaskCircle;
        ML.name = sprintf('MaskCircleLeft%d', nRepeats);
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1];
        ML.durSec = 1;
        ML.onSec =(offTime + 1)*(nRepeats-1) ;
        C.addStim(ML);
             
        GL = dpxStimGrating;
        GL.name = sprintf('GratingLeft%d', nRepeats);
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=1.75;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec = 1; 
        GL.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(GL);
        end
        
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[1 1 1 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=200/W.deg2px;
        RightCheck.hDeg=200/W.deg2px;
        RightCheck.contrast=.75;
        RightCheck.nHori=18;
        RightCheck.nVert=18;
        RightCheck.nHoleHori=10;
        RightCheck.nHoleVert=10;
        RightCheck.sparseness=2/3;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        RightCheck.durSec = Inf; 
        RightCheck.onSec = 0; 
        C.addStim(RightCheck);
        
        for nRepeats =1:rep
        MR = dpxStimMaskCircle;
        MR.name = sprintf('MaskCircleRight%d', nRepeats);
        MR.xDeg = 0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.durSec = 1; 
        MR.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = sprintf('GratingRight%d', nRepeats);
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=1.75;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec = 1;
        GR.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(GR);
        end
        
        if j < 3
        R=dpxRespKeyboard;
        R.name='keyboard3';
        R.kbNames='LeftControl,RightControl';
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=Ton;
        C.addResp(R);
        end
        
      E.addCondition(B);   
      E.addCondition(C); 
    end
    
end 
    E.conditionSequence = 1:numel(E.conditions);
    E.nRepeats=1; 
    E.run;
    sca; 
end