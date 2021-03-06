function dpxExample2afc(testscr)
    
    %dpxExample2afc     How-to create a simple 2AFC experiment in DPX
    %
    %   This example is a simple 2AFC experiment of left-right motion
    %   discrimination with different levels of coherence (fraction of
    %   motion-signal embedded in motion-noise).
    %
    %   The code additionally explains how to enable an Eyelink for
    %   fixation control.
    %
    %   Sections between [] explain some of the ideas and intended
    %   advantages of the object oriented design of DPX.
    %
    %   See also: dpxExample2afcAnalysis
    %
    %   Jacob Duijnhouwer, 2014-09-05
    
    % At the basis of each experiment is the Experiment class. This class,
    % called dpxCoreExperiment has functionality for most psychophysical and
    % 2-photon microscopy experiments. [However, it is possible to make a
    % derived class of dpxCoreExperiment. This class would inherit the
    % functionality of dpxCoreExperiment and allows a user to change that
    % functionality or add features without breaking the experiments of other
    % users. Inheritance is a powerful feature of object oriented programming.]
    
    if nargin==0
        testscr=[20 20 800 600];
    end
    
    % Make an object E of the class dpxCoreExperiment now ...
    E=dpxCoreExperiment;
    
    % Set the name, this will be used as the stem of the output filename. If no
    % name is provided, the experiment will take the name of the experiment
    % class (in this case 'dpxCoreExperiment').
    E.paradigm=mfilename;
    
    % Define the folder to which to save the output. This defaults to
    % '~/Documents/dpxData' on Unix systems, and 'C:\temp\dpxData\' on windows,
    % so you can leave this commented out if your happy with the default, or
    % provide a valid path for your system. E.outputFolder='C:\dpxData\';
    
    % 'window' is a property of the dpxExperiment class that contains a
    % dpxCoreWindow object. This object gets instantiated automatically when
    % dpxCoreExperiment object is made. The settings of window can be viewed by
    % typing get(E.window) and set by typing, for example,
    % set(E.window,'distMm',1000) or E.window.distMm=1000 to set the
    % viewing distance to a meter. Note that not all properties of E.window
    % that are displayed when calling get(E.window) can also be set using
    % set, some properties are read-only. An alternative convenient way to
    % set your window properties, visualize, and test them is through the
    % GUI that can be evoke by typing:
    %   E.window.gui
    % The "disp" button in this GUI generates a set-string to your command
    % window that you can copy/paste into your experiment, as I've done for
    % this experiment here:
    E.window.set('rectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'skipSyncTests',1,'verbosity0min5max',3);
    % Note (1) that i've manually cut the line using elipses (...) for
    % legibility; and (2) that an empty 'rectPx' (i.e., []), triggers full
    % screen display, regardless what resolution the screen is set to.
    
    % Add a plugin to use the eyelink, the eyelink software needs to be
    % installed for this and the eyelink hardware needs to be hooked up.
    % Further below you can designate one of the stimuli present in a condition
    % to require fixation (in this example, that will be the stimulus with name
    % 'fixdot'.
    %P=dpxPluginEyelink; E.addPlugin(P);
    
    % In this experiment, we vary coherence and motion direction. Define the
    % ranges of these properties here values of those here:
    cohFrac=-1:.5:1;
    
    for c=1:numel(cohFrac)
        
        % The experiment will have numel(cohFrac) condition. We will now create
        % these conditions one at a time in this loop. Tip: use nested for loop for
        % multiple stimulus dimensions.
        C=dpxCoreCondition;
        
        % Set the duration of the condition (trial). In this example, we make it
        % infinite and have the response finish the trial.
        C.durSec=Inf;
        
        % When using eyelink you might want to set a grace period for blinks, if
        % you use really long adaptation conditions for example:
        % C.breakFixGraceSec=0.1;
        
        % Create fixation-dot 'stimulus'.
        FIX=dpxStimDot;
        FIX.name='fixdot';
        FIX.onSec=-1;
        FIX.wDeg=0.5;
        % if you have an eyelink installed, you could add the following line to
        % require the fixation dot to be fixated within a 2 degree radius:
        % FIX.fixWithinDeg=2;

        
        % Add the random dot motion stimulus to this condition, and set the
        % properties. Remember, to get a list of all properties and their current
        % values of a stimulus object (or any object for that matter) use get with
        % the object as the argument (e.g. get(S)). You don't have to memorize the
        % properties. Moreover, all these properties and their value per trial will
        % be stored in the data-file.
        
        % [The RDK is one of the earliest stimuli I've programmed for DPX. The
        % design is that new stimuli can be added as modules, little files that
        % inherit from dpxAbstractStim like dpxStimRdk does, or that inherit from
        % an existing stimulus (say you want the RDK to have some additional exotic
        % behavior, don't tweak the dpxStimRdk file, but instead inherit from that
        % class into a new class, say dpxStimRdkExotic, and add the properties and
        % override the methods as required. This way the stimulus modules (classes)
        % stay clean and backward compatible.]
        RDK=dpxStimRdk;
        % Set the coherence. Note,  dpxStimRdk takes the sign of the coherence to
        % multiply the direction with. So if the property dirDeg is 0 (right) a
        % condition with negative coherence will move left.
        RDK.cohereFrac=cohFrac(c);
        % Set the diameter of the RDK
        RDK.wDeg=20;
        RDK.hDeg=20;
        RDK.onSec=1;
        RDK.durSec=1;
        % Provide a name for this stimulus, this is how the stimulus will be called
        % in the data-file. If no name is provided, the name will default to the
        % class-name (dpxStimRdk). In an experiment, no two stimuli can have the
        % same name, not even if they are in different conditions.
        RDK.name='motionStim'; % no spaces allowed in name
 
        % Add a semi-transparent mask for over the RDK
        MASK=dpxStimMaskGaussian;
        MASK.name='envelope';
        MASK.RGBAfrac=E.window.backRGBA;
        MASK.sigmaDeg=5;
        MASK.onSec=RDK.onSec;
        MASK.durSec=RDK.durSec;
        MASK.wDeg=RDK.wDeg+RDK.dotDiamDeg;      
        MASK.hDeg=RDK.hDeg+RDK.dotDiamDeg; 
        
        % Add a text stimulus with instructions
        TXT=dpxStimTextSimple;
        TXT.str='Indicate the motion direction with\nthe left and right arrow keys.\n(ESC to quit)';
        TXT.yDeg=-RDK.wDeg/2;
        
        % Add the stimuli to the condition
        C.addStimulus(FIX); % first added will be on top
        C.addStimulus(TXT);
        C.addStimulus(MASK);
        C.addStimulus(RDK);  
        
        % Create and add a response object to record the keyboard presses.
        R=dpxRespKeyboard;
        R.name='keyboard';
        % A comma separated list of keys-names that are valid responses To find out
        % the name of key press type 'KbName('UnifyKeyNames')' on the command line
        % and press Enter. Then, type 'KbName' followed by Enter and, after a
        % second, press the key you want to use.
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=RDK.onSec+RDK.durSec; % allow the response no sooner than the end of the RDK motion pulse
        R.correctEndsTrialAfterSec=0;
        C.addResponse(R);
        
        % Add this condition to the experiment
        E.addCondition(C);
    end
    % Set the number of repeats of each condition, aka blocks.
    E.nRepeats=5;
    % Start the experiment. It will run until all trials are finished, or until
    % Escape is pressed. If the program crashes for whatever reason and the
    % window remains visible (obscuring the matlab environment), type the
    % shorthand 'sca' and press Enter.
    E.run;
    %
    dpxDispFancy('TIP: use dpxExampleExperimentAnalysis to analyse this data');
end
