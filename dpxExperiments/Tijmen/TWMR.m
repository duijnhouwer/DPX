function TWMR
% 14-01-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWMR';
Language = input('NL(1)/EN(2):'); 

if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los om het experiment te starten.\nReageer met de linker- en rechtertoetspijl\n');
E.txtEnd= 'Einde';
elseif Language ==2
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
Ton=60;
    
for c=1:numel(Toff)
    C=dpxCoreCondition;     
    C.durSec = Toff+Ton;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presntation at the left side of the screen
        
        SFM = dpxSFM;
        SFM.name = 'SFMl';
        SFM.wDeg=4;
        SFM.hDeg=4;
        SFM.xDeg=-5; 
        SFM.onSec = Toff(c);
        SFM.durSec=Ton; 
        SFM.veloSinus = 1;
        C.addStim(SFM);
        
        Dot = dpxStimDot;
        Dot.name = 'Dotl';
        Dot.xDeg=-5; 
        C.addStim(Dot);
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen

        SFM = dpxSFM;
        SFM.name = 'SFMr';
        SFM.wDeg=4;
        SFM.hDeg=4;
        SFM.xDeg=5; 
        SFM.onSec = Toff(c);
        SFM.durSec=Ton; 
        SFM.veloSinus = 1;
        C.addStim(SFM);
        
        Dot = dpxStimDot;
        Dot.name = 'Dotr';
        Dot.xDeg=5; 
        C.addStim(Dot);
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %RESPONSE   
        
        R=dpxRespKeyboard;
        R.name='keyboard';
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=Toff(c);
        R.correctEndsTrialAfterSec=Toff + Ton;
        C.addResp(R);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        E.addCondition(C); 
        
end
    E.nRepeats=5;
    E.run;
    sca; 
end
