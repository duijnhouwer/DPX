function TWBR
% 14-01-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWBR';
Language = input('NL(1)/EN(2):');

if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los om het experiment te starten.\nReageer met de linker- en rechtertoetspijl\n');
E.txtEnd= 'Einde';
end

if Language ==2
E.txtStart = sprintf('Press and release $STARTKEY to start the experiment. \nUse left and right key to respond\n');
E.txtEnd= 'The End';
end

E.breakFixTimeOutSec=0.5;

%E.outputFolder='C:\dpxData\';
E.scr.set('winRectPx',[],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mono','skipSyncTests',0,'scrNr',0);
    
%Toff= [0.125, 0.25, 0.5, 1, 2];
Toff=0.5;
Ton=1;
    
for c=1:numel(Toff)
    C=dpxCoreCondition;     
    C.durSec = Ton+Toff(c);
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presntation at the left side of the screen
                 
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[.5 .5 .5 1];
        LeftCheck.xDeg=-5;
        LeftCheck.wDeg=4.2;
        LeftCheck.hDeg=4.2;
        LeftCheck.contrast=.9;
        LeftCheck.nHoleHori=8;
        LeftCheck.nHoleVert=8;
        LeftCheck.sparseness=0;
        LeftCheck.onSec = Toff(c);
        LeftCheck.durSec = Ton; 
        C.addStim(LeftCheck);
   
        ML = dpxStimMaskCircle;
        ML.name='maskLeft';
        ML.xDeg=-5;
        ML.hDeg = 2.4; 
        ML.wDeg = 2.4;
        ML.innerDiamDeg=1;
        ML.outerDiamDeg=1.5;
        ML.RGBAfrac=[.5 .5 .5 1];
        ML.onSec = Toff(c);
        ML.durSec=Ton; 
        C.addStim(ML);
    
        GL = dpxStimGrating;
        GL.name = 'gratingLeft';
        GL.xDeg=-5;
        GL.dirDeg=45;
        GL.squareWave=false;
        GL.gEnvelope=true; 
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6;
        GL.wDeg=1.5;
        GL.hDeg=1.5;    
        GL.onSec = Toff(c);
        GL.durSec=Ton; 
        C.addStim(GL);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[.5 .5 .5 1];
        RightCheck.xDeg=5;
        RightCheck.wDeg=4.2;
        RightCheck.hDeg=4.2;
        RightCheck.contrast=.9;
        RightCheck.nHoleHori=8;
        RightCheck.nHoleVert=8;
        RightCheck.sparseness=0;
        RightCheck.onSec = Toff(c);
        RightCheck.durSec=Ton; 
        RightCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RightCheck);
        
        MR = dpxStimMaskCircle;
        MR.name='maskRight';
        MR.xDeg=5;
        MR.hDeg = 2.4; 
        MR.wDeg = 2.4;
        MR.innerDiamDeg=1;
        MR.outerDiamDeg=1.5;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.onSec = Toff(c);
        MR.durSec=Ton; 
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=5;
        GR.dirDeg=-45;
        GR.squareWave=false;
        GR.gEnvelope=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6;
        GR.wDeg=1.5;
        GR.hDeg=1.5;      
        GR.onSec=Toff(c);
        GR.durSec=Ton;
        C.addStim(GR);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %RESPONSE   
        
        R=dpxRespKeyboard;
        R.name='keyboard';
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=Toff(c);
        R.correctEndsTrialAfterSec=GR.onSec+GR.durSec;
        C.addResp(R);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        E.addCondition(C);  
end
    E.nRepeats=5;
    E.run;
    sca; 
end
