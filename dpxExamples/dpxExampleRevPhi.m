function dpxExampleRevPhi(testscr)
    
    %dpxExampleRevPhi   Phi and reverse phi random dot motion
    %
    %   This function demonstrates the use of the dpxStimRdk class to
    %   present single step random dot motion in regular phi mode, and in
    %   reverse-phi mode, similar to the stimuli used in Duijnhouwer and
    %   Krekelberg (Cer Ctx, 2016)
    %
    %   dpxExampleRevPhi without an argument, or dpxExampleRevPhi([20 20
    %   640 480]) runs the test in the default 640 x 480 pixel window.
    %
    %   Use dpxExampleRevPhi([]) to run the demo in full screen mode.
    %
    %   See also: dpxExample2afc, dpxExampleHelloWorld, dpxExample...
    %
    %   Jacob Duijnhouwer, 2017-02-06
    
    if nargin==0
        testscr=[20 20 640 480];
    end
    
    % Create an experiment object
    E=dpxCoreExperiment();
    E.paradigm=mfilename; % give it a name
    % Set the parameters of the display
    E.window.set('rectPx',testscr,'widHeiMm',[508 318],'distMm',600 ...
        ,'gamma',1,'backRGBA',[0.5 0.5 0.5 1] ...
        ,'skipSyncTests',0,'verbosity0min5max',3);
    
    % Create two conditions, a phi and a reverse phi one
    for i=1:2
        % Create a random dot kinematogram (RDK) stim adjust some settings
        RDK=dpxStimRdk; % tip: type RDK=dpxStimRdk (without a semicolon) in the command window to get a list of all settings 
        RDK.name='rdk'; % give it a name
        RDK.onSec=0.2; % stim comes on 200 ms after trial start
        RDK.wDeg=15; % diameter of the stimulus
        RDK.speedDps=32; % speed in degrees per second
        RDK.dotsPerSqrDeg=4; % dot density in dots per square degree
        RDK.dotDiamDeg=.1; % dot diameter in degrees
        if i==1
            RDK.motType='shuffle,phi'; % shuffle step motion, phi
        else
            RDK.motType='shuffle,ihp'; % shuffle step motion, reverse phi
        end
        RDK.nSteps=2; % dots make 2 steps. Because of the 'shuffle' option, only the 1st and 3rd instance of the dot are visible
        %
        TIP=dpxStimTextSimple();
        TIP.str='(Press ESC to quit)';
        TIP.xDeg=0;
        TIP.yDeg=-10;
        TIP.fontsize=16;
        %
        LBL=dpxStimTextSimple();
        LBL.name='phiLabel';
        if i==1
            LBL.str='Phi';
        else
            LBL.str='Reverse phi';
        end
        LBL.yDeg=RDK.yDeg;
        LBL.fontsize=128;
        
        C=dpxCoreCondition; % Create a condition
        C.durSec=2; % condition stays on for 2 seconds
        C.addStimulus(LBL); % add the text stimulus
        C.addStimulus(TIP); % add the text stimulus
        C.addStimulus(RDK); % add the motion stim to the condition
        E.addCondition(C); % Add the one condition to the experiment
    end
    
    E.nRepeats=100;
    disp('TIP: You can leave the Subject and Experimenter IDs blank, just press Enter');
    E.run(); % run the experiment
    
end
