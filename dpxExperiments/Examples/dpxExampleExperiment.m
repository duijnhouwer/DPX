function dpxExampleExperiment
    
    % dpxExampleExperiment
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
    % See also: dpxExampleExperimentAnalyse
    %
    % Jacob Duijnhouwer, 2014-09-05
    
    % At the basis of each experiment is the Experiment class. This class,
    % called dpxCoreExperiment has functionality for most psychophysical
    % and 2-photon microscopy experiments.
    % [However, it is possible to make
    % a derived class of dpxCoreExperiment. This class would inherit the
    % functionality of dpxCoreExperiment and allows a user to change that
    % functionality or add features without breaking the experiments of
    % other users. Inheritance is a general and powerful feature of object
    % oriented programming..]
    
    % Make an object E of the class dpxCoreExperiment now ...
    E=dpxCoreExperiment;
    
    % Set the name, this will be used as the stem of the output filename.
    % If no name is provided, the experiment will take the name of the
    % experiment class, in this (if not all) case(s): dpxCoreExperiment.
    E.expName='dpxExampleExperiment';
    
    % Define the folder to which to save the output. This defaults to
    % '/tmp/dpxData' on Unix systems, and 'C:\temp\dpxData\' on windows, so
    % you can leave this commented out if your happy with that, or provide
    % a valid path for your system.
    % E.outputFolder='C:\dpxData\';
    
    % 'physScr' is a property of the dpxExperiment class that contains a
    % dpxCoreWindow object. This object gets instantiated automatically
    % when dpxCoreExperiment object is made. The settings of physScr can be
    % viewed by typing get(E.physScr) and set by typing, for example,
    % set(E.physScr,'distMm',1000) to set the viewing distance to a meter.
    % Note that not all properties of E.physScr that are displayed when
    % calling get(E.physScr) can also be set using set, some properties are
    % read-only. A convenient way to set your physScr properties,
    % visualize, and test them is through the amazing GUI I created. Evoke
    % this by typing:
    %   E.physScr.gui
    % The "disp" button in this GUI generates a set-string to your command
    % window that you can copy/paste into your experiment, as I've done for
    % this experiment here:
    E.physScr.set('winRectPx',[],'widHeiMm',[508 318],'distMm',500, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','SkipSyncTests',0);
    % Note (1) that i've manually cut the line using elipses (...) for
    % legibility; and (2) that an empty 'winRectPx' (i.e., []), triggers
    % full screen display, regardless what resolution the screen is set to.
    
    % 'windowed' is a method of the dpxCoreExperiment. If called with false
    % as the argument the experiment runs in full screen. If called with
    % true it will run in a small window. Alternatively, a 4-element vector
    % representing a display window [topLeftX topLeftY botRightX botRightY]
    % in pixels can be provided for custom window sizes. Running in
    % windowed mode is convenient when designing an experiment as it
    % doesn't obscure the view of the matlab environment. When ommited from
    % your function, windowed defaults to false.
    E.windowed(false); % true, false, [0 0 410 310]+100
    
    % In this experiment, we vary coherence and motion direction. Define
    % the ranges of these properties here values of those here:
    cohFrac=-1:.25:1;
    
    for c=1:numel(cohFrac)
        
        % The experiment will have numel(cohFrac) condition. We will now
        % create these conditions one at a time in this loop. Tip: use
        % nested for loop for multiple stimulus dimensions.
        
        C=dpxCoreCondition;
        
        % Set the duration of the condition (trial). In this example,
        % we make it infinite and have the response finish the trial.
        C.durSec=Inf;
        
        % Create and add a default fixation-dot 'stimulus'. We add this
        % stimulus first because the stimuli are drawn in a
        % first-added-last-drawn order. This way the fixation dot will
        % be on top.
        S=dpxStimDot;
        S.wDeg=0.5;
        C.addStim(S);
        
        % Add the random dot motion stimulus to this condition, and set
        % the properties. Remember, to get a list of all properties and
        % their current values of a stimulus object (or any object for
        % that matter) use get with the object as the argument (e.g.
        % get(S)). You don't have to memorize the properties. Moreover,
        % all these properties and their value per trial will be stored
        % in the data-file.
        
        % [The RDK is one of the earliest stimuli I've programmed for
        % DPX. The design is that new stimuli can be added as modules,
        % little files that inherit from dpxBasicStim like dpxStimRdk
        % does, or that inherit from an existing stimulus (say you want
        % the RDK to have some additional exotic behavior, don't tweak
        % the dpxStimRdk file, but instead inherit from that class into
        % a new class, say dpxStimRdkExotic, and add the properties and
        % override the methods as required. This way the stimulus
        % modules (classes) stay clean and backward compatible.]
        S=dpxStimRdk;
        % We will use default settings except for the coherence. Note,
        % dpxStimRdk takes the sign of the coherence to multiply the
        % direction with. So if the property dirDeg is 0 (right) a
        % condition with negative coherence will move left.
        S.cohereFrac=cohFrac(c);
        % We want the stimulus to go on 100 ms after the start of the
        % trial and last for half a second
        S.onSec=0.1;
        S.durSec=0.5;
        % Provide a name for this stimulus, this is how the stimulus
        % will be called in the data-file. If no name is provided, the
        % name will default to the class-name (dpxStimRdk). In an
        % experiment, no two stimuli can have the same name, not even
        % if they are in different conditions.
        S.name='motionStim'; % no spaces allowed in name
        % Add the stimulus to the condition
        C.addStim(S);

        % Create and add a response object to record the keyboard
        % presses.
        R=dpxRespKeyboard;
        R.name='keyboard';
        % A comma separated list of keys-names that are valid responses To
        % find out the name of key press type 'KbName('UnifyKeyNames')' on
        % the command line and press Enter. Then, type 'KbName' followed by
        % Enter and, after a second, press the key you want to use.
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=0.6; % allow the response no sooner than the end of the RDK stim
        R.correctEndsTrialAfterSec=0;
        C.addResp(R);
        
        % Add this condition to the experiment
        E.addCondition(C);
    end
    % Set the number of repeats of each condition, aka blocks.
    E.nRepeats=3;
    % Start the experiment. It will run until all trials are finished, or
    % until Escape is pressed. If the program crashes for whatever reason
    % and the window remains visible (obscuring the matlab environment),
    % type the shorthand 'cf' and press Enter.
    E.run;
    %
    dpxDispFancy('TIP: use dpxExampleExperimentAnalysis to analyse this data');
end
