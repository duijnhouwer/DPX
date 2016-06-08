function dpxExampleBench(testscr)
    
    %dpxExampleBench    Quick and dirty perfomance test
    %
    %   dpxExampleBench runs a simple full-screen experiment with PTB
    %   tests enabled. Use it to compare the performance of different
    %   set-ups. 
    %
    %   dpxExampleBench([10 10 640 480]) runs the test in a 640 x 480 pixel
    %   window
    %
    %   After the experiment, check the number of flips that were missed in
    %   the output on the command window.
    %
    %   See also: dpxExampleHelloWorld, dpxExampleExperiment
   
    if nargin==0
        testscr=[];
    end
    
    % Make an object E of the class dpxCoreExperiment now ...
    E=dpxCoreExperiment;
    E.paradigm=mfilename;
    E.window.set('rectPx',testscr,'widHeiMm',[508 318],'distMm',500, ... 
        'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1], ...
        'stereoMode','mono','skipSyncTests',0,'verbosity0min5max',5);
    cohFrac=-1:.5:1;
    for c=1:numel(cohFrac)
        C=dpxCoreCondition;
        C.durSec=2;
        %
        FIX=dpxStimDot;
        FIX.name='fixdot';
        FIX.onSec=-1;
        FIX.wDeg=0.5;
        %
        RDK=dpxStimRdk;
        RDK.dotsPerSqrDeg=60;
        RDK.cohereFrac=cohFrac(c);
        RDK.wDeg=26;
        RDK.hDeg=26;
        RDK.onSec=0;
        RDK.durSec=Inf;
        RDK.motStartSec=1;
        RDK.motDurSec=1;
        RDK.name='motionStim';
        % Add a semi-transparent mask for over the RDK
        MASK=dpxStimMaskGaussian;
        MASK.name='envelope';
        MASK.RGBAfrac=E.window.backRGBA;
        MASK.sigmaDeg=7;
        MASK.onSec=RDK.onSec;
        MASK.durSec=RDK.durSec;
        MASK.wDeg=RDK.wDeg+RDK.dotDiamDeg;      
        MASK.hDeg=RDK.hDeg+RDK.dotDiamDeg; 
        
        % Add the stimuli to the condition
        C.addStimulus(FIX); % first added will be on top
        C.addStimulus(MASK);
        C.addStimulus(RDK);  
          
        % Add this condition to the experiment
        E.addCondition(C);
    end
    % Set the number of repeats of each condition, aka blocks.
    E.nRepeats=2;
    E.run;
end
