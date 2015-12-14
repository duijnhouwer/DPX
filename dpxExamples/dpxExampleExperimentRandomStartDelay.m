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
    E.paradigm='dpxExampleExperimentWithText';
    
    % Define the folder to which to save the output. This defaults to
    % '~/Documents/dpxData' on Unix systems, and 'C:\temp\dpxData\' on
    % windows, so you can leave this commented out if your happy with the
    % default, or provide a valid path for your system.
    % E.outputFolder='C:\dpxData\';
    
    % 'window' is a property of the dpxExperiment class that contains a
    % dpxCoreWindow object. This object gets instantiated automatically
    % when dpxCoreExperiment object is made. The settings of window can be
    % viewed by typing get(E.window) and set by typing, for example,
    % set(E.window,'distMm',1000) or E.window.distMm=1000 to set the viewing
    % distance to a meter. Note that not all properties of E.window that are
    % displayed when calling get(E.window) can also be set using set, some
    % properties are read-only. A convenient way to set your window
    % properties, visualize, and test them is through the amazing GUI I
    % created. Evoke
    % this by typing:
    %   E.window.gui
    % The "disp" button in this GUI generates a set-string to your command
    % window that you can copy/paste into your experiment, as I've done for
    % this experiment here:
    E.window.set('rectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',   1    ,'verbosity0min5max',3);
    % Note (1) that i've manually cut the line using elipses (...) for
    % legibility; and (2) that an empty 'rectPx' (i.e., []), triggers
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
        
        % Create fixation-dot 'stimulus'. 
        FIX=dpxStimDot;
        FIX.name='fixdot';
        FIX.onSec=-1;
        FIX.wDeg=0.5;
 
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
        RDK.name='motionStim'; % no spaces allowed in name 
        
        % Add the stimuli to the condition
        C.addStimulus(FIX); % first added will be on top
        C.addStimulus(RDK);
        
        % Add a trial trigger. The experiment will be stuck in flip-0 until
        % a random start delay between .5 and 5 seconds has passed.
        TRIG=dpxTriggerDelay;
        TRIG.name='startdelay';
        TRIG.minSec=.5;
        TRIG.maxSec=5;
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
        C.addResponse(R);
        
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
end
