function dpxExampleExperimentWithText(testscr)
    
    % dpxExampleExperimentWithText
    %
    % Tutorial on creating experiments using the DPX toolkit.
    %
    % This example is a simple 2AFC experiment of left-right motion
    % discrimination with different levels of coherence (fraction of
    % motion-signal embedded in motion-noise).
    %
    % Sections between [] explain some of the ideas and intended advantages
    % of the object oriented design of DPX.
    %
    % See also: dpxStimText, dpxStimTextSimple
    %
    % Jacob Duijnhouwer, 2015-04-25
    
    if nargin==0
        testscr=[20 20 800 600];
    end
    
    % Make an object E of the class dpxCoreExperiment now ...
    E=dpxCoreExperiment;
    
    % Set the name, this will be used as the stem of the output filename.
    % If no name is provided, the experiment will take the name of the
    % experiment class (in this case 'dpxCoreExperiment').
    E.expName='dpxExampleExperimentWithText';
    
    % Define the folder to which to save the output. This defaults to
    % '~/Documents/dpxData' on Unix systems, and 'C:\temp\dpxData\' on
    % windows, so you can leave this commented out if your happy with the
    % default, or provide a valid path for your system.
    % E.outputFolder='C:\dpxData\';
    
    % 'scr' is a property of the dpxExperiment class that contains a
    % dpxCoreWindow object. This object gets instantiated automatically
    % when dpxCoreExperiment object is made. The settings of scr can be
    % viewed by typing get(E.scr) and set by typing, for example,
    % set(E.scr,'distMm',1000) or E.scr.distMm=1000 to set the viewing
    % distance to a meter. Note that not all properties of E.scr that are
    % displayed when calling get(E.scr) can also be set using set, some
    % properties are read-only. A convenient way to set your scr
    % properties, visualize, and test them is through the amazing GUI I
    % created. Evoke
    % this by typing:
    %   E.scr.gui
    % The "disp" button in this GUI generates a set-string to your command
    % window that you can copy/paste into your experiment, as I've done for
    % this experiment here:
    E.scr.set('winRectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',   1    ,'verbosity0min5max',3);
    % Note (1) that i've manually cut the line using elipses (...) for
    % legibility; and (2) that an empty 'winRectPx' (i.e., []), triggers
    % full screen display, regardless what resolution the screen is set to.
    
    % Add a plugin to use the eyelink, the eyelink software needs to be
    % installed for this and the eyelink hardware needs to be hooked up.
    % Further below you can designate one of the stimuli present in a
    % condition to require fixation (in this example, that will be the
    % stimulus with name 'fixdot'. 
    %P=dpxPluginEyelink;
    %E.addPlugin(P);
    
    % In this experiment, we vary coherence and motion direction. Define
    % the ranges of these properties here values of those here:
    cohFrac=-1:.5:1;
    
    conditionCounter=0;
    for c=1:numel(cohFrac)
        conditionCounter=conditionCounter+1;
        % The experiment will have numel(cohFrac) condition. We will now
        % create these conditions one at a time in this loop. Tip: use
        % nested for loop for multiple stimulus dimensions.
        
        C=dpxCoreCondition;
        
        % Set the duration of the condition (trial). In this example,
        % we make it infinite and have the response finish the trial.
        C.durSec=Inf;
        
        % When using eyelink you might want to set a grace period for
        % blinks, if you use really long adaptation conditions for example:
        % C.breakFixGraceSec=0.1;
        
        % Create fixation-dot 'stimulus'. 
        FIX=dpxStimDot;
        FIX.name='fixdot';
        FIX.onSec=-1;
        FIX.wDeg=0.5;
        % if you have an eyelink installed, you could add the following
        % line to require the fixation dot to be fixated within a 2 degree
        % radius:
        % FIX.fixWithinDeg=2;

        
        % Add the random dot motion stimulus to this condition, and set
        % the properties. Remember, to get a list of all properties and
        % their current values of a stimulus object (or any object for
        % that matter) use get with the object as the argument (e.g.
        % get(S)). You don't have to memorize the properties. Moreover,
        % all these properties and their value per trial will be stored
        % in the data-file.
        
        % [The RDK is one of the earliest stimuli I've programmed for
        % DPX. The design is that new stimuli can be added as modules,
        % little files that inherit from dpxAbstractStim like dpxStimRdk
        % does, or that inherit from an existing stimulus (say you want
        % the RDK to have some additional exotic behavior, don't tweak
        % the dpxStimRdk file, but instead inherit from that class into
        % a new class, say dpxStimRdkExotic, and add the properties and
        % override the methods as required. This way the stimulus
        % modules (classes) stay clean and backward compatible.]
        RDK=dpxStimRdk;
        % Set the coherence. Note,  dpxStimRdk takes the sign of the coherence to multiply the
        % direction with. So if the property dirDeg is 0 (right) a
        % condition with negative coherence will move left.
        RDK.cohereFrac=cohFrac(c);
        % Set the diameter of the RDK
        RDK.wDeg=20;
        RDK.hDeg=20;
        % We want the stimulus to go on 500 ms after the start of the
        % trial and last for half a second
        RDK.onSec=.5;
        RDK.durSec=2;
        % Provide a name for this stimulus, this is how the stimulus
        % will be called in the data-file. If no name is provided, the
        % name will default to the class-name (dpxStimRdk). In an
        % experiment, no two stimuli can have the same name, not even
        % if they are in different conditions.
        RDK.name='motionStim'; % no spaces allowed in name

        
        % Add a semi-transparent mask for over the RDK
        MASK=dpxStimMaskGaussian;
        MASK.name='envelope';
        MASK.RGBAfrac=E.scr.backRGBA;
        MASK.sigmaDeg=5;
        MASK.onSec=RDK.onSec;
        MASK.durSec=RDK.durSec;
        MASK.wDeg=RDK.wDeg+RDK.dotDiamDeg;      
        MASK.hDeg=RDK.hDeg+RDK.dotDiamDeg; 
        
        % Add  a text stimulus
        TEXT=dpxStimText;
        TEXT.str=['Condition #' num2str(conditionCounter,'%3d') '\nLeftArrow to start ...'];
        TEXT.onSec=-1; % stimulus starts on flip-0 (see below)
        TEXT.durSec=0; % stimulus disappears when flip-1 is reached
        
        
        % Add the stimuli to the condition
        C.addStim(FIX); % first added will be on top
        C.addStim(TEXT);
        C.addStim(MASK);
        C.addStim(RDK);
        
        % Add a trial trigger. The experiment will be stuck in flip-0 until
        % the trigger is received ('left' for left arrow). All stimuli with
        % a negative start time (such as the dxpStimText in this example
        % experiment will be drawn during flip-0. Trial starting at onSec=0
        % will be drawn on flip-1 and further.
        % Type help dpxTriggerKey for help on finding the name of the key
        % you wish to use.
        TRIG=dpxTriggerKey;
        TRIG.kbName='LeftArrow';
        C.addTrialTrigger(TRIG);
        
        % Create and add a response object to record the keyboard
        % presses.
        R=dpxRespKeyboard;
        R.name='keyboard';
        % A comma separated list of keys-names that are valid responses To
        % find out the name of key press type 'KbName('UnifyKeyNames')' on
        % the command line and press Enter. Then, type 'KbName' followed by
        % Enter and, after a second, press the key you want to use.
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=RDK.onSec+RDK.durSec; % allow the response no sooner than the end of the RDK stim
        R.correctEndsTrialAfterSec=0;
        C.addResp(R);
        
        % Add this condition to the experiment
        E.addCondition(C);
    end
    % Set the number of repeats of each condition, aka blocks.
    E.nRepeats=2;
    % Start the experiment. It will run until all trials are finished, or
    % until Escape is pressed. If the program crashes for whatever reason
    % and the window remains visible (obscuring the matlab environment),
    % type the shorthand 'cf' and press Enter.
    E.run;
    %
    dpxDispFancy('TIP: use dpxExampleExperimentAnalysis to analyse this data');
end
