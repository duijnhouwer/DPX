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
    E.paradigm='dpxExampleExperimentArduinoOut';
    E.scr.set('winRectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',1,'verbosity0min5max',3);
    
    % Add the dpxArduino plugin This opens and closes the Serial port connection to the
    % Arduino. It is necessary to first upload this sketch
    % ".\DPX\dpxPlugins\@dpxPluginArduino\private\dpxArduinoDigiIO\dpxArduinoDigiIO.ino"
    % to the flash memory of the Arduino! See ".\DPX\dpxDocs\Arduino In Out.docx" for
    % information on how to do that. That document also describes how to lookup the string
    % that indicates the USB port to which your Arduino is connected. It can be found in
    % the Arduino GUI.
    ARD=dpxPluginArduino;
    set(ARD,'comPortStr','COM3'); % IMPORTANT, UPDATE 'COM3' TO YOUR ACTUAL PORT (SEE ABOVE)
    E.addPlugin(ARD);
    
    % In this experiment, we vary coherence and motion direction. Define
    % the ranges of these properties here values of those here:
    cohFrac=[-1 -.5 .5 1];
    for c=1:numel(cohFrac)
        C=dpxCoreCondition;
        C.durSec=Inf;
        % Create the Random Dot stimulus
        RDK=dpxStimRdk;
        RDK.cohereFrac=cohFrac(c);
        RDK.wDeg=20;
        RDK.hDeg=20;
        RDK.onSec=.5;
        RDK.durSec=2;
        RDK.name='motionStim';
        %
        % Create the Arduino output pulse stimulus This Stimulus modules sends the
        % letters 'R' and 'r' over the serial link to the Arduino. The
        % "dpxArduino24in13out.ino" sketch listens for these and turns pin 13 on or
        % off, respectively. This stimulus starts as "enabled" which means it's
        % step-and-draw funtion won't be reached, and it's local flipCounter not
        % incremented, until the response-module turns it on. See below, where we
        % give the response stimulus the name of this stimulus "pin13". Note that
        % this name could be anything, e.g., "liquidReward". It's just a tag for
        % the response-module to know which stimulus to turn on when the correct
        % answer is given. It does in no way instruct the Arduino to use pin13 for
        % the output.
        REW=dpxStimArduinoPulse;
        REW.pinNr=13;
        REW.name='pin13';
        REW.enabled=false; % dpxRespArduinoPulse can turn this on
        %
        % Make a punishment (main aspect of this that adds a delay between this
        % trial and the next by means of the 'wrongEndsTrialAfterSec' property of
        % the dpxRespArduinoPulse object.). I also make the background a bit
        % brighter so that there is a visual consequence to the behavior (to make
        % clear that the response is in fact registered, plus the increased
        % brightness will add additional unpleasantness for the rodent subject. but
        % don't overdo it, the animal should not suffer and punishment should not
        % interfere with the visual processing of subsequent stimuli.
        PUN=dpxStimRect;
        PUN.RGBAfrac=[.8 .8 .8 1];
        PUN.wDeg=100; % entire ...
        PUN.hDeg=100;  ... screen
        PUN.name='punishment';
        PUN.enabled=false; % dpxRespArduinoPulse can turn this on
        %
        % Add the stimuli to the condition
        C.addStim(PUN); % reward, must be top of the list because it should block out the rest
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
        A.name='timelylick'; % this is how will show up in the datafile
        A.allowAfterSec=RDK.onSec+RDK.durSec; % only allow after stim is finished
        A.pins=[2 4]; % Listen for letters '2' and '4' on serial port. Note, numerical array, not characters!
        if RDK.cohereFrac<0 % If motion goes to the left ...
            A.rewardProb=[1 0];  ... the lickdetector connected to Pin 2 will give certain reward
        elseif RDK.cohereFrac>0
            A.rewardProb=[0 1]; ... otherwise the one to Pin 4 will give certain reward
        else
            A.rewardProb=[.7 .7]; % there is no correct answer. hence give randomly at rate of rat's mean performance
        end    
        A.correctStimName='pin13'; % After correct response, turn on the stim with this name (see above)
        A.correctEndsTrialAfterSec=.5; % Make that "pin13" stimulus last for .5 seconds, then end the trial
        A.wrongStimName='punishment';
        A.wrongEndsTrialAfterSec=3;
        C.addResp(A);
 
        % Add a second lickdetector object that listens to the same lickdetector,
        % but that is listening from the very beginning until the response should
        % be given. Any response detected by this object will lead to punishment
        % (bright screen and time out) 
        A=dpxRespArduinoPulse;
        A.name='earlylick';
        A.allowAfterSec=-1;
        A.allowUntilSec=RDK.onSec+RDK.durSec-.25; % just before the 'timelick' object starts listening
        A.pins=[2 4];
        A.rewardProb=[0 0]; % response is never correct
        A.wrongStimName='punishment';
        A.wrongEndsTrialAfterSec=3;
        A.redoTrialIfWrong='sometime'; % a prematurely ended trial need to be re-tried later
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
end
