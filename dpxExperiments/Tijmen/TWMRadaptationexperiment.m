function TWMRadaptationexperiment
% 16-01-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWMRadaptationexperiment';
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
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',1,'scrNr', 1);

%Toff= [0.125, 0.25, 0.5, 1, 2];
Toff=0.5;
Ton=1;

length = 20;
PCS = ones(1,length); 

for Ton=[60, PCS];
    C=dpxCoreCondition;     
    C.durSec = Toff+Ton;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presntation at the left side of the screen
        
        SFM = dpxSFM;
        SFM.name = 'SFMl';
        SFM.wDeg=4;
        SFM.hDeg=4;
        SFM.xDeg=0; 
        SFM.onSec = Toff;
        SFM.durSec=Ton; 
        SFM.veloSinus = 1;
        C.addStim(SFM);
        
        Dot = dpxStimDot;
        Dot.name = 'Dotl';
        Dot.xDeg=0; 
        Dot.RGBAfrac=[0 0 0 1];
        C.addStim(Dot);
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen

        SFM = dpxSFM;
        SFM.name = 'SFMr';
        SFM.wDeg=4;
        SFM.hDeg=4;
        SFM.xDeg=0; 
        SFM.onSec = Toff;
        SFM.durSec=Ton; 
        SFM.veloSinus = 1;
        C.addStim(SFM);
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %RESPONSE   
        
        R=dpxRespKeyboard;
        R.name='keyboard';
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=Toff;
        R.correctEndsTrialAfterSec=Toff + Ton;
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
    E.conditionSequence = 1:numel(E.conditions);
    E.run;
    sca; 
end