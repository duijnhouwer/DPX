function dpxExampleTrialTrigger(testscr)
    
    %dpxExampleTrialTrigger    Trial trigger example
    %
    %   Similar to dpxExample2afc but demonstrates a simple use of the
    %   trial-trigger funtionality, in this case providing a random start
    %   delay.
    %   
    %   Other examples of trial-triggers could also be use, to hold the
    %   trial until the subject fixates a fixation point using for example
    %   an Eyelink.
    %
    %   See also: dpxExample2afc
    %
    %   Jacob Duijnhouwer, 2015-04-25

    
    if nargin==0
        testscr=[20 20 640 480];
    end
    
    E=dpxCoreExperiment;
    E.paradigm=mfilename;
    E.window.set('rectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'skipSyncTests',1,'verbosity0min5max',3);

    cohFrac=-1:.5:1;
    conditionCounter=0;
    for c=1:numel(cohFrac)
        conditionCounter=conditionCounter+1;
        C=dpxCoreCondition;
        C.durSec=Inf;
        
        % Create fixation-dot stimulus 
        FIX=dpxStimDot;
        FIX.name='fixdot';
        FIX.onSec=-1;
        FIX.wDeg=0.5;
 
        % Create moving random dot stimulus
        RDK=dpxStimRdk;
        RDK.cohereFrac=cohFrac(c);
        RDK.wDeg=20;
        RDK.hDeg=20;
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
        R.kbNames='LeftArrow,RightArrow';
        R.allowAfterSec=RDK.onSec+RDK.durSec; % allow the response no sooner than the end of the RDK stim
        R.correctEndsTrialAfterSec=0;
        C.addResponse(R);
        
        % Add this condition to the experiment
        E.addCondition(C);
    end
    E.nRepeats=2;
    E.run;
end
