function dpxExampleExperimentArduinoOut(testscr)
    
    % dpxExampleExperimentArduinoOut
    %
    % Same as dpxExampleExperiment but with Arduino giving "rewards", e.g.,
    % pulses that could be connected to a reward system (water) or LED for
    % debugging. This works through the stimulus class dpxStimArduinoPulse
    % that interacts with the script dpxArduinoEngine that should be
    % running in a separate Matlab session. The programs interact by means
    % of empty files that they write into matlab's tempdir. The matlab
    % arduino calls are very slow (~30 ms to read a pin) so I can't do it
    % in the frame rate loop (everything in DPX is yoked to the refresh
    % rate of the monitor).  It's a bit of a hack but it seems to work
    % quite well.
    %
    % This experiment uses keyboard input, and gives a pulse on Digital Pin
    % 13 on the arduino. See dpxExampleExperimentArduinoInAndOut for and
    % experiment that uses Arduino input instead of the keyboard.
    %
    % See also: dpxExampleExperiment, dpxExampleExperimentArduinoInAndOut
    %
    % Jacob Duijnhouwer, 2015-3-16
    
  
    if nargin==0
        testscr=[20 20 800 600];
    end
    E=dpxCoreExperiment;
    E.expName='dpxExampleExperimentArduinoOut';
    E.scr.set('winRectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',   1    ,'verbosity0min5max',3);
    
    % In this experiment, we vary coherence and motion direction. Define
    % the ranges of these properties here values of those here:
    cohFrac=-1:.5:1;
    
    for c=1:numel(cohFrac)
        
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
        %
        % Create the Random Dot stimulus
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
        %
        % Create the Arduino output pulse stimulus
        PULSE=dpxStimArduinoPulse;
        PULSE.name='rewardpulse13';
        PULSE.visible=false;
        PULSE.outDigiPins=13;


        % Add the stimuli to the condition
        C.addStim(FIX); % first added will be on top
        C.addStim(RDK);
        C.addStim(PULSE);
        
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
        if RDK.cohereFrac>0
            R.correctKbNames='RightArrow';
        elseif RDK.cohereFrac<0
            R.correctKbNames='LeftArrow';
        else
            R.correctKbNames='.5'; % probability of 50% correct (there is no real correct and wrong in this condition)
        end
        R.correctStimName='rewardpulse13';
        R.correctEndsTrialAfterSec=.5;
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
    
end
