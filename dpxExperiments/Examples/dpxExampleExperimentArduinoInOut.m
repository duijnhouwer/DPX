function dpxExampleExperimentArduinoInOut(testscr)
    
    % dpxExampleExperimentArduinoInOut
    %
    % Example experiment that uses input and output pulses from the Arduino
    % It can be used to have a rat do a discrimination task with liquid
    % reward (now set-up for 2AFC, but can be simplified to go-nogo if
    % desired)
    %
    % TODO: Make a time-out punishment (brighter screen?) for when
    % incorrect response is given.
    %
    % See also: dpxExampleExperiment, dpxExampleExperimentArduinoOut
    %
    % Jacob Duijnhouwer, 2015-03-16, update 2014-03-24
    
  
    if nargin==0
        testscr=[20 20 800 600];
    end
    E=dpxCoreExperiment;
    E.expName='dpxExampleExperimentArduinoOut';
    E.scr.set('winRectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',   1    ,'verbosity0min5max',3);
    
    % Add the dpxArduino plugin
    % THis starts and stops the Serial port connection to the Arduino.
    % It is necessary to first upload this sketch
    % ".\DPX\dpxPlugins\@dpxPluginArduino\private\dpxArduino24in13out\dpxArduino24in13out.ino"
    % to the flash memory of the Arduino!
    % See ".\DPX\dpxDocs\Arduino In Out.docx" for information on how to do
    % that. Also see in that document how to lookup the string that
    % indicates the USB port to which your Arduino is connected. It can be
    % found in the Arduino interface.
    %
    ARD=dpxPluginArduino;
    set(ARD,'comPortStr','COM3'); % IMPORTANT, UPDATE 'COM3' TO YOUR ACTUAL PORT (SEE ABOVE)
    E.addPlugin(ARD);
    
    % In this experiment, we vary coherence and motion direction. Define
    % the ranges of these properties here values of those here:
    cohFrac=[-1 -.5 .5 1];
    for c=1:numel(cohFrac)
        
        % The experiment will have numel(cohFrac) condition. We will now
        % create these conditions one at a time in this loop. Tip: use
        % nested for loop for multiple stimulus dimensions.
        C=dpxCoreCondition;
        
        % Set the duration of the condition (trial). In this example,
        % we make it infinite and have the response finish the trial.
        C.durSec=Inf;
        
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
        % trial and last for 2 seconds
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
        % This Stimulus modules sends the letters 'R' and 'r' over the
        % serial link to the Arduino. The "dpxArduino24in13out.ino" sketch
        % listens for these and turns pin 13 on or off, respectively.
        % This stimulus starts as "invisible" which means it's "myDraw"
        % funtion won't be reached until the response-module turns it on.
        % See below, where we give the response stimulus the name of this
        % stimulus "pin13". Note that this name could be anything, e.g.,
        % "liquidReward". It's just a tag for the response-module to know
        % which stimulus to turn on when the correct answer is given. It
        % does in no way instruct the Arduino to use pin13 for the output.
        REW=dpxStimArduinoPulse;
        REW.pinNr=13;
        REW.name='pin13';
        REW.visible=false;
        %
        % Add the stimuli to the condition
        C.addStim(RDK); % random dot kinematogram
        C.addStim(REW); % reward
        
        % Create and add a response object to record the lick detector
        %
        % This is the input side of the Arduino. The sketch
        % "dpxArduino24in13out.ino" makes it output the letters '2' or '4'
        % over the serial-link to matlab whenever a HIGH voltage is
        % detector on the digital ports 2 or 4, respectively. These ports
        % are hardcoded in "dpxArduino24in13out.ino" but not in
        % "dpxRespArduinoPulse.m" so we set those ports here.
        %
        A=dpxRespArduinoPulse;
        A.name='lick'; % this is how it will show up in the datafile
        A.allowAfterSec=RDK.onSec+RDK.durSec; % only allow after stim is finished
        A.pins=[2 4]; % Listen for letters '2' and '4' on serial port. Note, numerical array, not characters!
        if RDK.cohereFrac<0 % If motion goes to the left ...
            A.correctPins=2;  ... the lickdetector connected to Pin 2 should be used
        elseif RDK.cohereFrac>0
            A.correctPins=4; ... otherwhise the one to Pin 4
        else
            A.correctPins=3;
        end    
        A.correctStimName='pin13'; % After correct response, turn on the stim with this name (see above)
        A.correctEndsTrialAfterSec=.5; % Make that "pin13" stimulus last for .5 seconds, then end the trial
        C.addResp(A);

        % Add this condition to the experiment
        E.addCondition(C);
    end
    % Set the number of repeats of each condition, aka blocks.
    E.nRepeats=5;
    % Start the experiment. It will run until all trials are finished, or
    % until Escape is pressed. If the program crashes for whatever reason
    % and the window remains visible (obscuring the matlab environment),
    % type the shorthand 'cf' and press Enter.
    E.run;
    %
    
end
