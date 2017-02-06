function dpxExampleBadRespRepeat(testscr)
    
    %dpxExampleBadRespRepeat    Trial repeat example
    %
    %   Similar to dpxExample2afc but demonstrates how to repeat a trial
    %   that was incorrect. (In this case, answered outside the allowed
    %   time interval.)
    %
    %   See also: dpxExample2afc
    %
    %   Jacob Duijnhouwer, 2015-05-02
    
    if nargin==0
        testscr=[20 20 640 480];
    end
    E=dpxCoreExperiment;
    E.paradigm=mfilename;
    E.window.set('rectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',1,'verbosity0min5max',3);
    
    cohFrac=[-1 1];
    conditionCounter=0;
    for c=1:numel(cohFrac)
        conditionCounter=conditionCounter+1;
        C=dpxCoreCondition;
        % Set the duration of the condition (trial). In this example,
        % we make it infinite and have the response finish the trial.
        C.durSec=Inf;
        FIX=dpxStimDot;
        FIX.name='fixdot';
        FIX.onSec=-1;
        FIX.wDeg=0.5;
        
        RDK=dpxStimRdk;
        RDK.cohereFrac=cohFrac(c);
        RDK.wDeg=20;
        RDK.hDeg=20;
        RDK.onSec=.5;
        RDK.durSec=2;
        RDK.name='motionStim';

        % Add the stimuli to the condition
        C.addStimulus(FIX); % first added will be on top
        C.addStimulus(RDK);
        
        
        % Create and add a response object to record the keyboard
        % presses.
        R=dpxRespKeyboard;
        R.name='keyboard';
        % A comma separated list of keys-names that are valid responses To
        % find out the name of key press type 'KbName('UnifyKeyNames')' on
        % the command line and press Enter. Then, type 'KbName' followed by
        % Enter and, after a second, press the key you want to use.
        R.kbNames='LeftArrow,RightArrow';
        if RDK.cohereFrac*RDK.speedDps<0
            R.correctKbNames='LeftArrow';
        elseif RDK.cohereFrac*RDK.speedDps>0
            R.correctKbNames='RightArrow';
        else
            R.correctKbNames='1'; % always considered correct
        end
        R.allowAfterSec=RDK.onSec+RDK.durSec; % allow the response no sooner than the end of the RDK stim
        R.correctEndsTrialAfterSec=0;
        R.redoTrialIfWrong='sometime';
        C.addResponse(R);
       
        % Add this condition to the experiment
        E.addCondition(C);
    end
    %
    % Set the number of repeats of each condition, aka blocks.
    E.nRepeats=100;
    % Start the experiment. It will run until all trials are finished, or
    % until Escape is pressed. If the program crashes for whatever reason
    % and the window remains visible (obscuring the matlab environment),
    % type  he shorthand 'cf' for and press Enter.
    E.run;
end
