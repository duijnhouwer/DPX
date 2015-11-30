function dpxExampleHelloWorld
    
    % function dpxExampleHelloWorld
    % Example Hello World experiment in a small window.
    % Jacob Duijnhouwer, 2015-10-19

    % Instantiate the experiment object E
    E=dpxCoreExperiment;
    % Define the expName property, this is typically the filename
    E.expName='dpxExampleHelloWorld'; % alternative E.expName=mfilename;
    % Set a few display properties of the dpxCoreWindow object within E.
    E.scr.winRectPx=[20 20 640 480]; % Set the display area.
    E.scr.skipSyncTests=true; % For this example, skip Psychtoolbox testing
    %
    % Make two conditions, one to say 'Hello,' the other to say 'World!'
    for conditionNumber=1:2
        % Instantiate a condition object
        C=dpxCoreCondition;
        C.durSec=1; % Make the condition last for this many seconds
        % Instantiate a text stimulus object
        T=dpxStimTextSimple;
        if conditionNumber==1
            % Set character string for condition 1
            T.str='Hello,';
        else
            % Set character string for condition 2
            T.str='World!';
        end
        % Add the stimulus to the condition
        C.addStim(T);
        % Add the condition to the experiment
        E.addCondition(C);
    end
    %
    % Repeat each condition once (that is, present one block)
    E.nRepeats=1;
    % Show in not-shuffled order
    E.conditionSequence='notShuffled'; % default: 'shufflePerBlock'
    % Run the experiment ...
    E.run;
end