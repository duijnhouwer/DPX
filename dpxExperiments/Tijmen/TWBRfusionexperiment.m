 function TWBRfusionexperiment
% 17-03-15 
% Binocular fusion experiment with gratings 1
clear all; clf;  
condition = []; 
KbName('UnifyKeyNames');
E=dpxCoreExperiment;
E.paradigm='TWBRfusionexperiment';

W =dpxCoreWindow;

Language = input('NL(1)/EN(2):');
if Language == 1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los \n om het experiment te starten.\n\n Druk eenmalig op de \n linker- en rechter controltoets.\n Interrupties: druk voor elke interruptie. \n  Continu: druk bij elke nieuwe waarneming.');
E.txtEnd= 'Einde van het experiment';
end

if Language == 2
E.txtStart = sprintf('Press and release $STARTKEY \n to start the experiment.\n\n Press left and right\n control key once to respond.\n Interruption: press before each interruption. \n Continuous: press for every new percept.');
E.txtEnd= 'End of the experiment';
end

E.breakFixTimeOutSec=0;
E.outputFolder='C:\dpxData';

set=0;                                                                      % screen settings for philips screen
if set == 0
E.scr.set('winRectPx',[],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',0); 
else 
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[390 295], ...     % screen settings for eyelink
        'distMm',1000, 'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',1);
end

% generate Toff Times with a shuffled order
offTime = [0.25,0.5,1]; 
shuffle = [randperm(3); offTime]; 
offTime = sortrows(shuffle',1); 
offTime = offTime(:,2);

disp('Loading (may take a while). Please wait...'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ton = 30; 
if  mod(Ton, 2) == 0
TWBF(Ton);
[condition] = [condition, TWBF(Ton)];
end

Ton = 30;
TWCONT(Ton);
[condition] = [condition, TWCONT(Ton)]; 

Ton = 30;
if  mod(Ton, 2) == 0
TWBF(Ton); 
[condition] = [condition, TWBF(Ton)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:3
Toff = offTime(i);
    
Ton = 60; 
TWBR(Ton, Toff); 
[condition] = [condition, TWBR(Ton, Toff)]; 

if i<3

Ton = 15;
if  mod(Ton, 2) == 0
TWBF(Ton); 
[condition] = [condition, TWBF(Ton)];
end

Ton = 30;
TWCONT(Ton);
[condition] = [condition, TWCONT(Ton)]; 

Ton = 15;
if  mod(Ton, 2) == 0
TWBF(Ton); 
[condition] = [condition, TWBF(Ton)];
end
end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    E.conditions = condition;  
    E.conditionSequence = 1:numel(E.conditions);
    E.nRepeats=1; 
    E.run;
    sca; 
 end