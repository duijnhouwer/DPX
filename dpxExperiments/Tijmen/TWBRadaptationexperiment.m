function TWBRadaptationexperiment
% 19-01-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWBRadaptationexperiment';
Language = input('NL(1)/EN(2):');

if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los om het experiment te starten.\nReageer met de linker- en rechtertoetspijl\n');
E.txtEnd= 'Einde';
end

if Language ==2
E.txtStart = sprintf('Press and release $STARTKEY to start the experiment. \nUse left and right key to respond\n');
E.txtEnd= 'The End';
end

W = dpxCoreWindow;

E.breakFixTimeOutSec=0.5;

%E.outputFolder='C:\dpxData\';
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mono','skipSyncTests',1,'scrNr', 1);

%Toff= [0.125, 0.25, 0.5, 1, 2];
Toff=0.5;
Ton=1;

length = 20;
PCS = ones(1,length); 

for Ton=[60, PCS];
    C=dpxCoreCondition;     
    C.durSec = Ton+Toff;
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presntation at the left side of the screen            
        
<<<<<<< .mine
        Check=dpxStimCheckerboard; 
        Check.name='checkLeft';
        Check.RGBAfrac=[.5 .5 .5 1];
        Check.xDeg=-5;
        Check.wDeg=400*(2/3)/(W.deg2px*2);
        Check.hDeg=400*(2/3)/(W.deg2px*2);
        Check.contrast=.5;
        Check.nHoleHori=10;
        Check.nHoleVert=10;
        Check.sparseness=2/3;
        Check.nHori=18;
        Check.nVert=18;
        C.addStim(Check);
   
        M = dpxStimMask;
        M.name='maskLeft';
        M.wDeg=400*(2/3)/(W.deg2px*4);
        M.hDeg=400*(2/3)/(W.deg2px*4);
        M.grayFrac=.5;
        M.onSec = Toff;
        M.durSec=Ton; 
        M.xDeg=-5;
        C.addStim(M);
%         M.hDeg = 400*(2/3)/(W.deg2px*4);
%         M.wDeg = 400*(2/3)/(W.deg2px*4);
%         M.innerDiamDeg=0;
%         M.outerDiamDeg=400*(2/3)/(W.deg2px*2);
%         M.RGBAfrac=[.5 .5 .5 1];
%         M.onSec = Toff;
%         M.durSec=Ton; 
%         C.addStim(M);
%     
        GR = dpxStimGrating;
        GR.name = 'gratingLeft';
        GR.xDeg=-5;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=1.75;
        GR.wDeg=200/(W.deg2px*4);
        GR.hDeg=200/(W.deg2px*4);    
        GR.onSec = Toff;
        GR.durSec=Ton; 
        C.addStim(GR);
        
=======
        ML = dpxStimMask;
        ML.name='maskLeft';
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
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec=Ton; 
        C.addStim(GL);
          
>>>>>>> .r403
        Dot = dpxStimDot;
        Dot.name = 'dotLeft';
        Dot.xDeg=-5; 
        Dot.RGBAfrac=[0 0 0 1];
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % STIMULUS presentation at the right side of the screen
        
        Check=dpxStimCheckerboard;
        Check.name='checkRight';
        Check.RGBAfrac=[.5 .5 .5 1];
        Check.xDeg=5;
        Check.wDeg=4.2;
        Check.hDeg=4.2;
        Check.contrast=.9;
        Check.nHoleHori=8;
        Check.nHoleVert=8;
        Check.sparseness=0;
        Check.rndSeed=Check.rndSeed;
        C.addStim(Check);
        
<<<<<<< .mine
        M = dpxStimMask;
        M.name='maskRight';
        M.wDeg=400*(2/3)/(W.deg2px*4);
        M.hDeg=400*(2/3)/(W.deg2px*4);
        M.grayFrac=.5;
        M.onSec = Toff;
        M.durSec=Ton; 
        M.xDeg=5;
        C.addStim(M);
        
%         M = dpxStimMaskCircle;
%         M.name='maskRight';
%         M.xDeg=5;
%         M.hDeg = 2.4; 
%         M.wDeg = 2.4;
%         M.innerDiamDeg=1;
%         M.outerDiamDeg=1.5;
%         M.RGBAfrac=[.5 .5 .5 1];
%         M.onSec = Toff;
%         M.durSec=Ton; 
%         C.addStim(M);
=======
        MR = dpxStimMask;
        MR.name='maskRight';
        MR.xDeg=0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.durSec=Ton; 
        C.addStim(MR);
>>>>>>> .r403

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=5;
        GR.dirDeg=-45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6;
        GR.wDeg=1.5;
        GR.hDeg=1.5;      
        GR.onSec=Toff;
        GR.durSec=Ton;
        C.addStim(GR);
        
<<<<<<< .mine
=======
        if Ton==8
        R=dpxRespKeyboard;
        R.name='keyboard1';
        R.kbNames='LeftControl,RightControl';
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=Ton;
        C.addResp(R);
        end  
           
        E.addCondition(D);
        E.addCondition(C);        
end
        A = dpxCoreCondition; 
        A.durSec = Inf;
        PA = dpxStimPause;
        PA.name = 'PA2'; 
        PA.durSec=Inf;
        PA.onSec = 0; 

        if  Language==1  
            PA.textPause1 = 'Intermezzo';  
            PA.textPause2 = 'Druk op spatiebar om door te gaan';
        else
            PA.textPause1 = 'Intermission'; 
            PA.textPause2 = 'Press spacebar to continue';
        end
        
        A.addStim(PA); 

        R=dpxRespKeyboard;
        R.name='keyboard2';
        R.kbNames= 'space' ;
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=0;
        A.addResp(R);
        
        E.addCondition(A); 
        
for i = 1:length(Toff)
    
    if i<3
        cont = 30; 
        adap= 30;  
    else 
        cont = []; 
        adap = [];                                                          % scraps the two (unnecessary) adaptation trials at the end 
    end
    
    rep = trialLength./(1+Toff(i));                                         % length of interleaved percept choice sequences = 60 seconds (1 min)  
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
        
        PA = dpxStimPause;
        PA.name = 'PA3'; 
        PA.durSec=5; 
        PA.onSec = 0; 
        
        if  Language==1
            if j==1
            PA.textPause1 = 'Conditie: Interrupties (1 min)';
            PA.textPause2 = 'Kijk en gebruik beide controltoetsen'; 
            elseif j==2
            PA.textPause1 = 'Conditie: Continu (30 sec)';
            PA.textPause2 = 'Kijk en gebruik beide controltoetsen';
            else 
         	PA.textPause1 = 'Conditie: Continu (30 sec)';  
            PA.textPause2 = 'Alleen kijken';
            end
        else   
        if j==1
            PA.textPause1 = 'Condition: Interruptions (1 min)';
            PA.textPause2 = 'View and use both control keys'; 
            elseif j==2
            PA.textPause1 = 'Condition: Continuous (30 sec)';    
            PA.textPause2 = 'View and use both control keys'; 
            else 
            PA.textPause1 = 'Condition: Continuous (30 sec)';    
            PA.textPause2 = 'View only'; 
        end
       
        end
        B.addStim(PA);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the left side of the screen     
        
       
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
        
        for nRepeats=1:rep
        ML = dpxStimMask;
        ML.name = sprintf('MaskLeft%d', nRepeats);
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
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec = 1; 
        GL.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(GL);
        end
        
>>>>>>> .r403
        Dot = dpxStimDot;
        Dot.name = 'dotRight';
        Dot.xDeg=5; 
        Dot.RGBAfrac=[0 0 0 1];
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %RESPONSE   
        
<<<<<<< .mine
=======
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
        
        for nRepeats =1:rep
        MR = dpxStimMask;
        MR.name = sprintf('MaskRight%d', nRepeats);
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
        GR.cyclesPerDeg=6./2.2;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec = 1;
        GR.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(GR);
        end
        
        if j < 3
>>>>>>> .r403
        R=dpxRespKeyboard;
        R.name='keyboard';
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=Toff;
        R.correctEndsTrialAfterSec=Ton+Toff;
        C.addResp(R);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        E.addCondition(C);  
        
        if Language==1
        E.txtPause = 'O N D E R B R E K I N G'; 
        else
        E.txtPause='I N T E R M I S S I O N';
        end
end
    E.nRepeats=5;
    E.run;
    sca; 
end
