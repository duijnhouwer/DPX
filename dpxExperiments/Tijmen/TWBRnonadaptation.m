function nonadaptation
% 23-01-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWBRadaptationexperiment';
Language = input('NL(1)/EN(2):');

if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze \n los om het experiment te starten.\nReageer met de linker-\n en rechtertoetspijl.\n');
E.txtEnd= 'Einde';
end

if Language ==2
E.txtStart = sprintf('Press and release $STARTKEY \n to start the experiment. \nUse left and right \n key to respond.\n');
E.txtEnd= 'The End';
end

E.breakFixTimeOutSec=0;
E.outputFolder='C:\dpxData\';

set=0; 
if set ==0
E.scr.set('winRectPx',[],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',0);
    strcmpi('mirror', E.scr.set); 
else 
E.scr.set('winRectPx',[],'widHeiMm',[390+1440 295+1440],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',1);
end

length = 20;
PCS = 0.5*ones(1,length); 
repeats=1; 

if round(rand(1))<0.5
n=-1; 
else 
    n=1;
end
                  
for nRepeats=1:2
    C=dpxCoreCondition;
    Toff=0; 
    Ton=2; 
    C.durSec = Ton+Toff;
    n=n*-1; 
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %STIMULUS presentation at the left side of the screen
%                   
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checkLeft';
        LeftCheck.RGBAfrac=[.5 .5 .5 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=5.6;
        LeftCheck.hDeg=5.6;
        LeftCheck.contrast=.8;
        LeftCheck.nHoleHori=8;
        LeftCheck.nHoleVert=8;
        LeftCheck.sparseness=1/3;  
        C.addStim(LeftCheck);
   
        ML = dpxStimMaskCircle;
        ML.name='maskLeft';
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1]; 
        ML.onSec = Toff;
        ML.durSec=Ton; 
        C.addStim(ML);
       
        GL = dpxStimGrating;
        GL.name = 'gratingLeft';
        GL.xDeg=0;
        
            switch n
            case 1
                GL.dirDeg=-45;
            case -1
                GL.dirDeg=45;
                GL.onSec = GL.onSec+2;
            otherwise
                error('Oh no! No flip could be performed!'); 
            end
            
        GL.onSec = Toff;
        GL.durSec= Ton;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;   
        C.addStim(GL); 
        
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checkRight';
        RightCheck.RGBAfrac=[.5 .5 .5 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=5.6;
        RightCheck.hDeg=5.6;
        RightCheck.contrast=.8;
        RightCheck.nHoleHori=8;
        RightCheck.nHoleVert=8;
        RightCheck.sparseness=1/3;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RightCheck);
        
        MR = dpxStimMaskCircle;
        MR.name='maskRight';
        MR.xDeg=0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.onSec = Toff;
        MR.durSec=Ton; 
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=0;
        
           switch n
            case 1
                GR.dirDeg=-45;
            case -1
                GR.dirDeg=45;
            otherwise
                error('Oh no! No flip could be performed!'); 
           end
           
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6./2.2;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.onSec=Toff;
        GR.durSec=Ton;
        C.addStim(GR);
 
for Ton=PCS; 
        C=dpxCoreCondition;
        Ton=1;
        Toff =0.5;

        C.durSec = Ton+Toff;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %STIMULUS presentation at the left side of the screen
                 
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checkLeft';
        LeftCheck.RGBAfrac=[.5 .5 .5 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=5.6;
        LeftCheck.hDeg=5.6;
        LeftCheck.contrast=.8;
        LeftCheck.nHoleHori=8;
        LeftCheck.nHoleVert=8;
        LeftCheck.sparseness=1/3;  
        C.addStim(LeftCheck);
   
        ML = dpxStimMaskCircle;
        ML.name='maskLeft';
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1]; 
        ML.onSec = Toff;
        ML.durSec=Ton; 
        C.addStim(ML);
       
        GL = dpxStimGrating;
        GL.name = 'gratingLeft';
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.onSec = Toff;
        GL.durSec= Ton;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;   
        C.addStim(GL); 
        
        Dot = dpxStimDot;
        Dot.name = 'Dotl';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checkRight';
        RightCheck.RGBAfrac=[.5 .5 .5 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=5.6;
        RightCheck.hDeg=5.6;
        RightCheck.contrast=.8;
        RightCheck.nHoleHori=8;
        RightCheck.nHoleVert=8;
        RightCheck.sparseness=1/3;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RightCheck);
        
        MR = dpxStimMaskCircle;
        MR.name='maskRight';
        MR.xDeg=0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.onSec = Toff;
        MR.durSec=Ton; 
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
        GR.onSec=Toff;
        GR.durSec=Ton;
        C.addStim(GR);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %RESPONSE   
        
        R=dpxRespKeyboard;
        R.name='keyboard2';
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=Toff;
        R.correctEndsTrialAfterSec=GR.onSec+GR.durSec;
        C.addResp(R);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        E.addCondition(C);
     
end
E.txtPause='Pauze';
E.txtPauseNrTrials=5;
end
       
    E.conditionSequence = 1:numel(E.conditions);
    E.run;
    sca; 
end