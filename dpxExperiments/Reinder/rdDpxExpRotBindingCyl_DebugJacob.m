function rdDpxExpRotBindingCyl_DebugJacob(pos,BB)
%%baseline and binding experiment
%
%%input needed is: (pos) --> position of the !HALVE! cylinder (inducer), 'left' or 'right'
%%experiment type (BB) --> baseline or binding (depends on whihc stim the subject has to
%%report: 'base' or 'bind'
%%i.e. rdDpxExpRotCyl('left','bind')

if IsWin %disable laptop lid-button
    DisableKeysForKbCheck([233]);
end

E=dpxCoreExperiment;
E.txtPauseNrTrials=111;
E.nRepeats=2;


% handle the position option
if strcmpi(pos,'left')
    flippos=1;
    if strcmpi(BB,'base')
        E.txtStart='Kijk naar het rode kruis.\n\nIs de LINKER halve cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.expName='rdDpxExpBaseLineCylLeft';
    elseif strcmpi(BB,'bind')
        E.txtStart='Kijk naar het rode kruis.\n\nHoe beweegt het voorvlak van de RECHTER volle cylinder?\nOmhoog = Pijltje omhoog\nOmlaag = Pijltje omlaag';
        E.expName='rdDpxExpBindingCylLeft';
    else
        error(['unknown type of experiment ' BB]);
    end
elseif strcmpi(pos,'right')
    flippos=-1;
    if strcmpi(BB,'base')
        E.txtStart='Kijk naar het rode kruis.\n\nIs de RECHTER halve cylinder HOL of BOL?\nHol = Pijltje omhoog\nBol = Pijltje omlaag';
        E.expName='rdDpxExpBaseLineCylRight';
    elseif strcmpi(BB,'bind')
        E.txtStart='Kijk naar het rode kruis.\n\nHoe beweegt het voorvlak van de LINKER volle cylinder?\nOmhoog = Pijltje omhoog\nOmlaag = Pijltje omlaag';
        E.expName='rdDpxExpBindingCylRight';
    else
        error(['unknown type of experiment ' BB]);
    end
else
    error(['unknown pos mode ' pos]);
end

E.txtStart=[ E.txtStart '\nFeedback Flits:\nGrijs: Antwoord ontvangen.'];

% Then the experiment option, make expname (used in output filename)
if strcmpi(dpxGetUserName,'Reinder')
    E.outputFolder='C:\tempdata_PleaseDeleteMeSenpai';
elseif strcmpi(dpxGetUserName,'eyelink')
    if strcmpi(BB,'base')
        E.outputFolder='/home/eyelink/Dropbox/dpx/Data/Exp2Baseline';
    elseif strcmpi(BB,'bind')
        E.outputFolder='/home/eyelink/Dropbox/dpx/Data/Exp2Binding';
    end
end
    

% Set the stimulus window option
E.scr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
E.scr.set('interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1]);
E.scr.set('stereoMode','mirror','skipSyncTests',  0  );%'mono, mirror, anaglyph
% JACOB_DEBUG_NOTE de windowed option heb ik verwijderd, verwarrend omdat
% het anders werkte op verschillende systemen. 


% JACOB_DEBUG_NOTE ik heb in het experiment het volgende veranderd: de
% conditie duurt nu pratisch oneindig (feitelijk 1 uur)


% Add stimuli and responses to the conditions, add the conditions to
% the experiement, and run
modes={'stereo','anti-stereo','mono'}; %stereo, anti-stereo, mono
for m=1:numel(modes)
    for dsp=[-1 1]
        for rotSpeed=[120 -120] % >0 --> up
            C=dpxCoreCondition;
            set(C,'durSec',Inf); % JACOB_DEBUG_NOTE conditie houdt nu op na druk op knop, Even voor het begrip: Inf (oftewel "infinit" kun je ook bv 360 zetten voor een conditie 10 minuten zou duren tenzij er eerder op een knop gedrukt wordt, ook praktisch oneindig
            
            % The fixation cross
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
            C.addStim(S);
            
            % The feedback stimulus for correct responses
            S=dpxStimDot;
            set(S,'wDeg',.3,'visible',false,'durSec',Inf,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
            C.addStim(S);
            % JACOB_DEBUG_NOTE de feedback stimulus' durSec was voorheen
            % .5, ik heb dit naar Inf gezet. De stimulus verdwijnt als de
            % conditie ophoudt. Ik denk dat dit het grootste probleem was
            % in jouw versie. Tegen de tijd dat het antwoord gegeven werd
            % kon de stimulus al onzichtbaar voorbij gegaan zijn (.5). Het
            % is mogelijk dat dit in een eerdere versie anders werkte.
            % Overigens is durSec per default Inf, dus 'durSec',Inf, kan in
            % principe ook weggelaten worden voor de leesbaarheid
        
            % The full cylinder stimulus
            % JACOB_DEBUG_NOTE  ik heb de density even /10 zpdat het wat
            % soepeler draait op mijn laptopje
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',     12/10       ,'xDeg',flippos*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',0,'sideToDraw','both' ...
                ,'onSec',.5,'durSec',1,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
                ,'name','fullTargetCyl');
% JACOB_DEBUG_NOTE Ik heb de onSec van de Cylinder stimuli op .5 gezet, op
% deze manier is er een tijdje een van .6 seconde tussen het drukken op de
% knop en het beginnen van de volgende stim
            C.addStim(S);
            
            % The half cylinder stimulus
            % JACOB_DEBUG_NOTE  zelde notes als bij andere cylinder gelden
            if strcmpi(modes{m},'mono')
                lumcorr=1;
                dFog=dsp;
                dScale=dsp;
                dispa=0;
            elseif strcmpi(modes{m},'stereo')
                lumcorr=1;
                dFog=0;
                dScale=0;
                dispa=dsp;
            elseif strcmpi(modes{m},'anti-stereo')
                lumcorr=-1;
                dFog=0;
                dScale=0;
                dispa=dsp;
            else
                error('what you trying fool!?')
            end
            S=dpxStimRotCylinder;
            set(S,'dotsPerSqrDeg',     12/10       ,'xDeg',flippos*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
                ,'rotSpeedDeg',rotSpeed,'disparityFrac',dispa,'sideToDraw','front' ...
                ,'onSec',.5,'durSec',1,'stereoLumCorr',lumcorr,'fogFrac',dFog,'dotDiamScaleFrac',dScale ...
                ,'name','halfInducerCyl');
            C.addStim(S);
            
            
            % The response object
            R=dpxRespKeyboard;
            R.allowAfterSec=S.onSec+S.durSec;  % JACOB_DEBUG_NOTE  belangrijk: zo kan het antwoord pas gegeven worden nadat de stimulus voorbij is, Dat is wenselijk
            set(R,'kbNames','UpArrow,DownArrow');
            R.correctKbNames='1'; % % JACOB_DEBUG_NOTE  means response is correct with chance of 1, maakt niet uit welke knop 
            set(R,'correctStimName','fbCorrect','correctEndsTrialAfterSec',.1); % JACOB_DEBUG_NOTE  na de response .1 seconde flits, dan einde trial
            %set(R,'wrongStimName','fbCorrect','wrongEndsTrialAfterSec',.1); % JACOB_DEBUG_NOTE  na de response .1 seconde flits, dan einde trial. Deze kan weg omdat het antwoord altijd goed is
            C.addResp(R);
            
            E.addCondition(C);
        end
    end
end
E.run;
end