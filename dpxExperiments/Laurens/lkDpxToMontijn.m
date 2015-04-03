function structMP=lkDpxToMontijn(filename)
    
    % Conversion function for output of dpxGratingExp style 2-photon
    % microscope experiments (TF TS contrast grating) to Jorrit Montijn
    % output so that it can be used with Jorrit's analysis suite
    
    if nargin==0
        files2convert=dpxUIgetfiles('dialogtitle','Select lkDpxGratingExp output file(s)','filterspec','*.mat');
    else
        if ~ischar(filename)
            error('Either give a single filename, or no argument to bring up a multiple file selection tool');
        end
        files2convert={filename};
    end
    for i=1:numel(files2convert)
        dpxData=dpxdLoad(files2convert{i});
        switch dpxData.exp_expName{1}
            case 'lkDpxGratingExp'
                structMP(i)=convertLkDpxGratingExp(dpxData); %#ok<AGROW>
            case 'lkDpxGratingAdaptExp'
                structMP(i)=convertLkDpxGratingAdaptExp(dpxData); %#ok<AGROW>
            otherwise
                error(['Conversion of ' dpxData.exp_expName{1} ' not implemented']);
        end
        outfile=createOutputFilename(files2convert{i});
        save(outfile,'structMP');
        disp(['Saved ''' outfile '''.']);
    end
end

% --- FUNCTIONS -----------------------------------------------------------

function of=createOutputFilename(filename)
    of=[dpxStrReplaceExtension(filename,'') '_Montijn.mat'];
end


function M=convertLkDpxGratingExp(K)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% convertLkDpxGratingExp %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Fill out the fields in the structMP (the name of the datastruct in
    % the Jorrit Montijn datafiles, with (converted) values from the Chris
    % Klink datafile.
    
    % naam van experiment
    M.strFile=K.exp_expName{1};%'MP_OrientationTuning8BiDirections'
    
    % Weet niet precies wat dit voorstelt. Ik gok de rate waarmee de camera
    % (eye en lick) werden gecheckt. We hebben niet van die camera's dus
    % laat dit maar even zoals het was.
    M.dblCheckInterval=1.0000e-03;
    
    % Dit lijken me de kanaalnummers waarop de oog en lik camerasignalen
    % binnenkwamen. Wij hebben die niet dus zet ze maar op 0, hopende dat
    % dat door de analyse begrepen word. 
    M.intPortCam1=0;% 7
    M.intPortCam2=0;% 8
    
    % Ik denk dat dit het nummer is van het stim scherm in psychtoolbox,
    % lijkt me niet belangrijk
    M.intUseScreen='who gives a crap';%  2
    
    % Dit lijkt me flag voor of het wel of niet een echt experiment was
    % oid, om de stimulus danwel de analyse te debuggen. Ik hardcode dat op
    % 0 (i.e, false)
    M.debug=0; % 0
    
    % De volgende scherm info staat ook in de klink-file
    M.dblScreenDistance_cm=K.scr_distMm(1)/10;
    M.dblScreenWidth_cm=K.scr_widHeiMm{1}(1)/10; % 34
    M.dblScreenHeight_cm=K.scr_widHeiMm{1}(2)/10; % 27
    M.dblScreenWidth_deg=atan2d(M.dblScreenWidth_cm/2,M.dblScreenDistance_cm)*2; %93.4714
    M.dblScreenHeight_deg=atan2d(M.dblScreenHeight_cm/2,M.dblScreenDistance_cm)*2; % 80.3120
    M.intScreenWidth_pix=K.scr_winRectPx{1}(3); % 1280
    M.intScreenHeight_pix=K.scr_winRectPx{1}(4); % 1024
    
    
    % Herbereken een paar conversie factoren, deze zijn ten minste nodig om
    % de spatiele frequentie te berekenen, die is in de klink-file alleen
    % in de lengte van de periode in pixels opgegeven ....
    Mm2Pix = M.intScreenWidth_pix/(M.dblScreenWidth_cm*10);
    Deg2Pix = tand(1).*(M.dblScreenDistance_cm*10)*Mm2Pix;
        
    % diameter aperture
    M.dblStimSizeRetinalDegrees=K.grating_wDeg(1);
    
    % Spatiele frequentie (ik gok in cycles/degree)
    M.dblSpatialFrequency=K.grating_cyclesPerDeg; % lijst van lengte nTrials
    
    % Ik weet niet zeker wat dit voorsteld, mogelijk aantal keer dat
    % periode in de grating past. Ik zet het zolang maar op -1, dan zien we
    % later wel weer.
    M.dblTotalCycles=-1;
    
    % dit wordt een lijst met contrast waarden per trial, weet niet of de
    % montijn analyse daarmee om kan gaan, was daar een scalar.
    M.amplitude = K.grating_contrastFrac;
    
    % Ik denk dat dit voorsteld welke waarde in dKe stimulus codering het
    % achtergrondsgrijs voorsteld. Ik hardcode dit maar even op 0.5;
    M.bgIntStim = K.grating_grayFrac;
    M.bgInt = 'who cares'; % 128
    
    % Een beschrijving van welke richitng wat is
    M.str90Deg = '0 deg is right, 90 deg is up'; % '0 degrees is leftward motion; 90 degrees is upward motion'
    
    % Number of repeats per conditions, ik neem aan REQUESTED, not
    % necessarily completed 
    M.intNumRepeats = K.exp_nRepeats(1); % 5
    
    % Orientatie. Montijn-files gebruiken orientaties 2 keer, met
    % vecDirections 0 en 1. Klink-files hebben alle richtingen in graden
    % gedefinieerd. ik behoud dat nu, ik hoop dat het de analyse niet
    % verstoord. anders moet alles boven de 180 een andere vecDirections
    % krijgen en de Orientations modudolo 180 genomen worden.
    M.vecOrientations = unique(K.grating_dirDeg); % [0 22.5000 45 67.5000 90 112.5000 135 157.5000]

    % Ik neem aan dat dit spatiele frequentie voorstelt. Ik geloof niet dat
    % deze waarde in de analyse gebruikt wordt structMP. Speed daarentegen
    % wel, die is in Montijn gevult met deze waarde. Die waarde wordt
    % gebruikt om te bepalen welke voorberekende texture matrix geladen
    % moet worden per trial. Zo dus een nominale waarde kunnen zijn ook.
    % Dit zal later moeten blijken. Ik zet er voor nu de gebruikte SF
    % waarden uit de klink-file in ....
   % M.dblSpeed = unique(K.STIM.Grat.SpeedHz(:)'); % 1
    
    % Dit is de duur van 1 microscoop-frame. Ik geloof niet dat dat in de
    % klink-file staat opgeslagen. Kan wel uit de XML die bij de microscoop
    % frame TIFFs hoort worden achterhaald. Ik neem aan (hoop) dat we
    % dezelfde instelling gebruiken als Montijn et al., heb die hier
    % hardcoded.
    s=input('Enter the microscopes''s frame duration in seconds [Can be found in the XML file, Default: 0.039 ms] >> ','s');
    if isempty(strtrim(s))
        M.dblSecsForSingleFrame = 0.0390;
        disp('0.039');
    else
        M.dblSecsForSingleFrame = str2double(s);
    end
    
    % In the Montijn stimulus, the ISI is divided in a part before the
    % stim and a part after the stim. in the klink files we have just one
    % setting... I looked into the klink-stimulation code and a stim starts
    % with ISI, so it should correspond to dblSecsBlankPre. I therefore
    % hardcode dblSecsBlankPost to be 0.
   % M.dblSecsBlankPre = K.STIM.ISIDuration; % 3
   % M.dblSecsStimDur = K.STIM.PresDuration; % 3
   % M.dblSecsBlankPost = 0; % 2

    % Timing values again but expressed in microscope frames, rounded
   % M.intPulseBlankAtStart = round(M.dblSecsBlankAtStart/M.dblSecsForSingleFrame); % 77
   % M.intPulseBlankAtEnd = round(M.dblSecsBlankAtEnd/M.dblSecsForSingleFrame); % 77
   % M.intPulseBlankPre = round(M.dblSecsBlankPre/M.dblSecsForSingleFrame); % 77
   % M.intPulseStimDur = round(M.dblSecsStimDur/M.dblSecsForSingleFrame); % 77
   % M.intPulseBlankPost = round(M.dblSecsBlankPost/M.dblSecsForSingleFrame); % 51
    
    % aantal condities
    M.intStimTypes = numel(unique(K.condition));
    
    % de orientaties op volgorde van presentatie
    M.vecPresStimOri = K.grating_dirDeg;
    % het teken van de richting op volgorde van presentatie, wordt niet
    % gebruikt in de analyse...
    %M.vecPresStimDir = 1.0*K.grating_cyclesPerSecond>0;   % [0 1 0 1 0 1 0 0 1 0 1 0 1 1 1 0 1 1 0 0 0 0 0 1 1 1 0 0 1 1 1 0 0 0 1 0 1 0 1 1 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 1 0 1 0 0 1 1 1 1 0 1 0 1]
    % aantal getoonde trials (presentaties) Deze waarde lijkt nergens in de
    % analyse gebruikt te worden (i.t.t.  M.intStimNumber, see below)
    %M.intTrialNum = K.STIM.NumbOfPres; % 80 wordt niet gebruikt in de
    %analyse
    % Sync-pulse waarden. Klink en Montijn geven niet op dezelfde momenten
    % pulsjes. Bovendien lijkt het erop dat Montijn daadwerkelijk pulsjes
    % geeft terwijl in Klink het voltage gedurende de ON en OFF in een UP
    % (4 Volt ofzo) of DOWN state is (0 volt) Dit gaat dus lastig worden,
    % de analyse zal aangepast moeten worden.
    % 
    % Voor deze waarden kunnen we het ons makkelijk maken, ik vroeg me al
    % af wat de overlap met de M.Act... (see below) waarden was. Deze
    % vecTrial waarden worden in de analyse niet gebruikt (Find Files)
    M.vecTrialStartPulses = 'doesnt seem to be used'; % [1x80 double]
    M.vecTrialStimOnPulses = 'doesnt seem to be used';% [1x80 double]
    M.vecTrialStimMidPulses = 'doesnt seem to be used'; % [1x80 double]
    M.vecTrialStimOffPulses = 'doesnt seem to be used'; % [1x80 double]
    M.intStimNumber = K.N;
    
    % TrialNumber is een lijst met trial-nummber, gewoon oplopend dus
    % reconstrueer m hier (niet als zodaning in klink opgeslagen)
    M.TrialNumber = 1:K.N; % [1x80 double]
    
    % Deze zijn in Montijn in absolute microscoop
    % frames, de tegenhanges in Klink zijn in secondes, conversie is
    % vereist. Dit moet goed gecheckt worden, zijn er wellicht onverwachte
    % offset e.d.?
  
    % TIMING STUFF
    % 
    % Get the time of the startpulse given off by the microscope at the
    % beginning of the experiment. It's hidden in string txtStart, because
    % a magic value of that string triggers 'wait for pulse' behavior in
    % DPX and is also used to store the time stamp. Recover that now.
    startpulseSecs=str2double(K.exp_txtStart{1}(find(K.exp_txtStart{1}=='@')+1:end));
    endpulseSecs=str2double(K.exp_txtEnd{1}(find(K.exp_txtEnd{1}=='@')+1:end));
    
    
    % Ik denk dat ActOn het moment is waarop de stimulus aangaat. Dat lijkt
    % netjes te corresponderen met [K.LOG.ON]:
    stimOnRelativeToStartPulseSeconds = K.grating_onSec + K.startSec - startpulseSecs;
    M.ActOnPulses = stimOnRelativeToStartPulseSeconds/M.dblSecsForSingleFrame;
    

    warning('WE SHOULD CHANGE THE PULSING BEHAVIOR OF THE KLINK STIMULUS TO MATCH THAT OF THE MONTIJN STIMULUS.');
    % Ik geloof dat er een groot verschil tussen de pulsjes in Klink en
    % Montijn. Klink slaat de pulsjes op in microscope output file, terwijl
    % Montijn de stimulus presentatie synct aan de frame-rate van de
    % microscope. Dit is een fundamenteel verschil. Het zal mogelijk niet
    % veel uitmaken, vooral niet met korte experimenten (weinig tijd om uit
    % de pas te gaan lopen) en brede averaging windows. Wel iets om in de
    % gaten te houden.
    
    % Dit is wat verwarrend, OFF in Montijn betekend wanneer de stim
    % uitgaat. K.LOG.OFF is het moment waarop de OFF phase van de Klink
    % stimulus begint, gaat dus vooraf aan ON van die trial. Ik gebruik
    % daarom nu als OFF voor de ene trial de OFF van de volgende, dat zou
    % overeen moeten komen. We hebben dan een probleem met de laatste, ik
    % verzin die maar op basis van de stimulus duratie...
    
    stimOffRelativeToStartPulseSeconds = K.grating_onSec + K.grating_durSec + K.startSec - startpulseSecs;
    M.ActOffPulses = stimOffRelativeToStartPulseSeconds/M.dblSecsForSingleFrame;
    
    % In klink is er niet zoiets als een mid-pulse, voor zover ik weet.
    % Gelukkig blijkt met 'Find Files' dat 'ActMidPulses' ook niet in de
    % Montijn analyse voorkomt. Ik hardcode m daarom met nan-values
    % (not-a-number) 
    %M.ActMidPulses = nan(size(M.ActOnPulses)); % [1x80 double]
    
    % Orientaties per presentatie
    M.Orientation = K.grating_dirDeg;
    % Richtingen (hardcoded 0) per presentatie
    M.Direction = 1.0*K.grating_cyclesPerSecond>0;  % [0 1 0 1 0 1 0 0 1 0 1 0 1 1 1 0 1 1 0 0 0 0 0 1 1 1 0 0 1 1 1 0 0 0 1 0 1 0 1 1 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 1 0 1 0 0 1 1 1 1 0 1 0 1]
    % Speeds (ik gok in cycles/second) per presentatie
    M.Speed = K.grating_cyclesPerSecond; %  [1 1 1 1 1  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
    % Spatfreq per presentatie
    M.SpatialFrequency = K.grating_cyclesPerDeg; % [1x80 double]
end


function M=convertLkDpxGratingAdaptExp(K)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% convertLkDpxGratingAdaptExp %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % For clarity, I removed the comments from this function as far as they
    % are identical to the convertLkDpxGratingExp.
    M.strFile=K.exp_expName{1};
    M.dblCheckInterval=1.0000e-03;
    M.intPortCam1=0;% 7
    M.intPortCam2=0;% 8
    M.intUseScreen='who gives a crap';%  2
    M.debug=0; % 0
    M.dblScreenDistance_cm=K.scr_distMm(1)/10;
    M.dblScreenWidth_cm=K.scr_widHeiMm{1}(1)/10; % 34
    M.dblScreenHeight_cm=K.scr_widHeiMm{1}(2)/10; % 27
    M.dblScreenWidth_deg=atan2d(M.dblScreenWidth_cm/2,M.dblScreenDistance_cm)*2; %93.4714
    M.dblScreenHeight_deg=atan2d(M.dblScreenHeight_cm/2,M.dblScreenDistance_cm)*2; % 80.3120
    M.intScreenWidth_pix=K.scr_winRectPx{1}(3); % 1280
    M.intScreenHeight_pix=K.scr_winRectPx{1}(4); % 1024
    Mm2Pix = M.intScreenWidth_pix/(M.dblScreenWidth_cm*10);
    Deg2Pix = tand(1).*(M.dblScreenDistance_cm*10)*Mm2Pix;
    M.dblStimSizeRetinalDegrees=K.test_wDeg(1);
    M.dblSpatialFrequency=K.test_cyclesPerDeg; % lijst van lengte nTrials
    M.dblTotalCycles=-1;
    M.amplitude = K.test_contrastFrac;
    M.bgIntStim = K.test_grayFrac;
    M.bgInt = 'who cares'; % 128
    M.str90Deg = '0 deg is right, 90 deg is up';
    M.intNumRepeats = K.exp_nRepeats(1); % 5
    M.vecOrientations = unique(K.test_dirDeg); % e.g. [0 22.5000 45 67.5000 90 112.5000 135 157.5000]
    s=input('Enter the microscopes''s frame duration in seconds [Can be found in the XML file, Default: 0.039 ms] >> ','s');
    if isempty(strtrim(s))
        M.dblSecsForSingleFrame = 0.0390;
    else
        M.dblSecsForSingleFrame = str2double(s);
    end
    M.intStimTypes = numel(unique(K.condition));
    M.vecPresStimOri = K.test_dirDeg;
    M.vecTrialStartPulses = 'doesnt seem to be used'; % [1x80 double]
    M.vecTrialStimOnPulses = 'doesnt seem to be used';% [1x80 double]
    M.vecTrialStimMidPulses = 'doesnt seem to be used'; % [1x80 double]
    M.vecTrialStimOffPulses = 'doesnt seem to be used'; % [1x80 double]
    M.intStimNumber = K.N;
    M.TrialNumber = 1:K.N; % [1x80 double]
    startpulseSecs=str2double(K.exp_txtStart{1}(find(K.exp_txtStart{1}=='@')+1:end));
    endpulseSecs=str2double(K.exp_txtEnd{1}(find(K.exp_txtEnd{1}=='@')+1:end));
    stimOnRelativeToStartPulseSeconds = K.test_onSec + K.startSec - startpulseSecs;
    M.ActOnPulses = stimOnRelativeToStartPulseSeconds/M.dblSecsForSingleFrame;
    stimOffRelativeToStartPulseSeconds = K.test_onSec + K.test_durSec + K.startSec - startpulseSecs;
    M.ActOffPulses = stimOffRelativeToStartPulseSeconds/M.dblSecsForSingleFrame;
    M.Orientation = K.test_dirDeg;
    M.Direction = 1.0*K.test_cyclesPerSecond>0;  % [0 1 0 1 0 1 0 0 1 0 1 0 1 1 1 0 1 1 0 0 0 0 0 1 1 1 0 0 1 1 1 0 0 0 1 0 1 0 1 1 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 1 0 1 0 0 1 1 1 1 0 1 0 1]
    M.Speed = K.test_cyclesPerSecond; %  [1 1 1 1 1  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
    M.SpatialFrequency = K.test_cyclesPerDeg; % [1x80 double]
end


