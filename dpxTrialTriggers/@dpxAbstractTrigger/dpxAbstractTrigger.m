classdef (Abstract) dpxAbstractTrigger < hgsetget
    properties (Access=public)
        name;
        rndSeed;
    end
    properties (Access=protected)
        triggered;
        flipZeroCounter;
        RND; % RandStream
    end
    methods (Access=public)
        function T=dpxAbstractTrigger
            % dpxAbstractTrigger
            % Part of DPX: An experiment preparation system
            % http://duijnhouwer.github.io/DPX/
            % Jacob Duijnhouwer 2015-05-04
            T.name=''; % Defaults to derived class name if left empty when added to condition using addTrigger
            T.triggered=false;
            T.rndSeed=rand*(2^32); % the seed of the stim's internal randstream, setting this will automatically instantiate the RandStream
        end
        function init(T)
            T.triggered=false;
            T.myInit; % stimulus class specific init
            T.flipZeroCounter=0; % how many frames have we been in flipZero by now
        end
        function bool=go(T)
            T.flipZeroCounter=T.flipZeroCounter+1;
            % Does this trigger allow the start of the trial?
            if ~T.triggered
                % Once it's triggered, it remains triggered
                T.triggered=T.myGo;
            end
            bool=T.triggered;
        end
    end
    methods (Access=protected)
        function myInit(T) %#ok<*MANU>
            % define a derived class specific override if need be. for example the
            % dpxTriggerDelay uses one of these to pick the random delay variable which
            % is different for each trial (and retries of failed trials)
        end
        function bool=myGo(T) %#ok<STOUT>
            % define a myGo in the derived class that returns true when the
            % start-condition for the trial has been met (for example a key press in
            % dpxTriggerKey or a random delay in dpxTriggerDelay)
        end
    end
    methods
        function set.name(T,value)
            if ~ischar(value)
                error('trigger name must be a string');
            end
            if any(isspace(value))
                error(['trigger name ''' value ''' contains whitespace characters']);
            end
            T.name=value;
        end
        function set.rndSeed(T,value)
            if value=='?'
                disp('rndSeed (numeric): the seed of the trigger''s internal random number generator. Can be used to reproduce stochastic triggers (e.g. variable start delay).');
                return;
            end
            if ~isnumeric(value)
                error('rndSeed must be a number');
            end
            T.rndSeed=value;
            T.RND=RandStream('mt19937ar','Seed',value);
        end
    end
end
         