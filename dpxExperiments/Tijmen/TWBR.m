function [condition ] = TWBR(Ton, Toff)
W =dpxCoreWindow;
E=dpxCoreExperiment;

rep = Ton /(1+Toff);

        D = dpxCoreCondition;     
        D.durSec = Ton;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the left side of the screen     
        
        
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[1 1 1 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=125/W.deg2px;
        LeftCheck.hDeg=125/W.deg2px; 
        LeftCheck.contrast=.25;
        LeftCheck.nHoleHori=10;
        LeftCheck.nHoleVert=10;
        LeftCheck.nHori=18;
        LeftCheck.nVert=18;
        LeftCheck.sparseness=2/3;
        LeftCheck.durSec = Inf; 
        LeftCheck.onSec = 0; 
        D.addStim(LeftCheck);
        
        for nRepeats=1:rep
        ML = dpxStimMask;
        ML.name = sprintf('MaskLeft%d', nRepeats);
        ML.grayFrac=.5;
        ML.pars=.5;
        ML.typeStr='gaussian';
        ML.xDeg=0;
        ML.hDeg = (50*sqrt(2))/W.deg2px; 
        ML.wDeg = (50*sqrt(2))/W.deg2px;
        ML.durSec = 1;
        ML.onSec =(Toff + 1)*(nRepeats-1) ;
        D.addStim(ML);
                
        GL = dpxStimGrating;
        GL.name = sprintf('GratingLeft%d', nRepeats);
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=2.5;
        GL.wDeg= (50)/W.deg2px;
        GL.hDeg= (50)/W.deg2px;
        GL.durSec = 1; 
        GL.onSec = (Toff + 1)*(nRepeats-1) ;
        D.addStim(GL);
        end
        
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        D.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[1 1 1 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=125/W.deg2px;
        RightCheck.hDeg=125/W.deg2px;
        RightCheck.contrast=.25;
        RightCheck.nHori=18;
        RightCheck.nVert=18;
        RightCheck.nHoleHori=10;
        RightCheck.nHoleVert=10;
        RightCheck.sparseness=2/3;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        RightCheck.durSec = Inf; 
        RightCheck.onSec = 0; 
        D.addStim(RightCheck);
        
        for nRepeats =1:rep
        MR = dpxStimMask;
        MR.name = sprintf('MaskRight%d', nRepeats);
        MR.grayFrac=.5;
        MR.pars=.5;
        MR.typeStr='gaussian';
        MR.xDeg=0;
        MR.hDeg = (50*sqrt(2))/W.deg2px; 
        MR.wDeg = (50*sqrt(2))/W.deg2px;
        MR.durSec = 1;
        MR.onSec =(Toff + 1)*(nRepeats-1) ;
        D.addStim(MR);

        GR = dpxStimGrating;
        GR.name = sprintf('GratingRight%d', nRepeats);
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=2.5;
        GR.wDeg= (50)/W.deg2px;
        GR.hDeg= (50)/W.deg2px;  
        GR.durSec = 1;
        GR.onSec = (Toff + 1)*(nRepeats-1) ;
        D.addStim(GR);
        end

        RL = dpxRespContiKeyboard;
        RL.name = 'keyboardl';
        RL.kbName='LeftControl';
        D.addResp(RL); 
        
        RR = dpxRespContiKeyboard;
        RR.name = 'keyboardr'; 
        RR.kbName ='RightControl';
        D.addResp(RR);
      
        E.addCondition(D); 

condition = E.conditions;

end
