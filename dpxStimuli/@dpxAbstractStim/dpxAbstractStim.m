classdef (Abstract) dpxAbstractStim < hgsetget
    
    properties (Access=public)
        className;
        enabled;
        onSec;
        durSec;
        name;
        rndSeed;
    end
    properties (SetAccess=public,GetAccess=protected)
        initialPublicState=[];
    end
    properties (Access=protected)
        onFlip;
        offFlip;
        flipCounter; % flips since this stimulus was enabled
        flipsPriorEnable; % global flips preceding start of stimulus's flipCounter
      	scrGets=[]; % needed even though non-visual, because measuredFramerate is in here and is the global zeitgeber for all stimuli, visual or non
        stepCounter;
        RND; % RandStream
    end
    methods (Access=public)
        function S=dpxAbstractStim
            % dpxAbstractStim - Abstract class for dpxStim classes that present
            % NON-visual stimuli. Derive visual stimuli classes from
            % dpxAbstractVisualStim, an abstract class that inherits from dpxAbstractStim
            %
            % Abstract means no objects can be created from this class, it only serves
            % to be inherited. The names of all derived classes should be of the format
            % dpxStimXXX where XXX is a placeholder for the name of your stimulus.
            %
            % See also: dpxAbstractVisualStim, StimdpxAbstractResp, dpxStimRdk
            %
            % Jacob Duijnhouwer, 2014-09-05
            %
            S.className=class(S); % assumes name of derived class, not 'dpxAbstractStim'
            S.enabled=true; % Toggle stimulus enabled true|false. Internal flipcounter counts from the moment stimulus was enabled. 2015-06-29
            S.onSec=0; % Time since trial start that stimulus comes on
            S.durSec=Inf; % Duration of stim (relative to start)
            S.name=class(S); % can be overriden when added to condition
            S.rndSeed=rand*(2^32); % the seed of the stim's internal randstream, the set function of rndSeed instantiate the RandStream
            S.flipCounter=0;
            S.stepCounter=0;
        end
        function lockInitialPublicState(S)
            % addStimulus of the condition class will call this function to store a copy of
            % all publicly settable parameters of this stimulus in initialPublicState.
            % Before a repeat of the condition is presented, this struct is used to
            % restore this stimulus to its starting state. So when, for example, the
            % property 'visible' was toggled it will be reset prior to the next trial
            % that repeats this condition.
            
            % I removed the following check on 2015-12-05; it doesn't seem really necessary
            % because this happens behind the scenes. I remember putting this here as a
            % reminder to myself to not mess up the design of the program, as a
            % precaution. It caused problems though when i introduced the stim.demo
            % feature, because then the same object get initialized multiple times (if
            % you run the demo methods more than once on a stimulus object
            % if ~isempty(S.initialPublicState)
            %    error('lockInitialPublicState should be called only once on a stimulus, during addStimulus');
            % end
            S.initialPublicState=dpxGetSetables(S);
        end
        function restoreInitialPublicState(S)
            if isempty(S.initialPublicState)
                error('lockInitialPublicState should have been called during addStimulus');
            end
            fns=fieldnames(S.initialPublicState);
            for i=1:numel(fns)
                S.(fns{i})=S.initialPublicState.(fns{i});
            end
        end
        function init(S,scrGets)
            if nargin~=2 || ~isstruct(scrGets)
                error('Needs get(dpxCoreWindow-object) struct');
            end
            if isempty(scrGets.windowPtr)
                error('dpxCoreWindow object has not been initialized');
            end
            S.restoreInitialPublicState; % keep at top of init
            S.flipCounter=0;
            S.flipsPriorEnable=0;
            S.stepCounter=0;
            S.onFlip = round(S.onSec * scrGets.measuredFrameRate);
            S.offFlip = round((max(S.onSec,0) + S.durSec) * scrGets.measuredFrameRate);
            S.scrGets=scrGets;
            S.myInit; % stimulus class specific init
        end
        function stepAndDraw(S,globalFlipCounter)
            if S.enabled && S.flipsPriorEnable==0
                % Store the number of flips that this trial was already running before this
                % stimulus was enabled. This will usually be zero, as most stimuli are
                % always enabled. The main purpose of this extra counter is that stimuli
                % that are enabled after a response can count their onSec and durSec
                % relative that moment instead of from the beginning of the trial.
                S.flipsPriorEnable=globalFlipCounter; 
                % Prior to 2015-10-07 this was S.flipsPriorEnable=globalFlipCounter-1
                % but i discovered that broke stimulus drawing during
                % flip-0 (e.g. text in dpxExampleExperimentWithText). I
                % removed the -1, but I can't really test now how this
                % might effect other experiments. 666
            end
            if S.enabled
                S.flipCounter=globalFlipCounter-S.flipsPriorEnable; % stimulus's flipcounter is relative to first enable
                if S.flipCounter>S.onFlip && S.flipCounter<=S.offFlip
                    % flipCounter is updated before step and draw are called. Therefore, it's a
                    % one-based counter (starts at 0, so 1 during the first step);
                    S.stepCounter=S.stepCounter+1; % stepcounter is also effectively one-based
                    S.myStep;
                    S.myDraw;
                end
            end
        end
        function clear(S)
            S.myClear;
        end
        function demo(S,W)
            if ~exist('W','var') || isempty(W)
                W=dpxCoreWindow;
                W.skipSyncTests=true;
                W.verbosity0min5max=0;
            end
            if ~isa(W,'dpxCoreWindow')
                error('W is not a dpxCoreWindow object');
            end
            try
                W.open;
                C=dpxCoreCondition;
                C.addStimulus(S);
                C.durSec=S.onSec+S.durSec;
                C.init(get(W));
                dpxDispFancy([ 'Running ' class(S) ' demo. Press ESCAPE to quit'],[],[],[],'*Comment')
                C.show; % until C.durSec or ESCAPE
                W.close;
            catch me 
                sca;
                rethrow(me);  
            end
        end
    end
    methods (Access=protected)
        % redefine these "my"-functions is your stimulus class
        function myInit(S), end %#ok<*MANU>
        function myDraw(S), end
        function myStep(S), end
        function myClear(S), end
    end
    methods
        function set.enabled(S,value)
            if value=='?'
                disp('enabled (logical): Only enabled stimuli (default) accumulate flip counts.');
                return;
            end
            if ~islogical(value) && ~isnumeric(value)
                error('enabled should be numeric or (preferably) logical');
            end
            S.enabled=logical(value);
        end
        function set.onSec(S,value)
            if value=='?'
                disp('onSec (numeric): Time in seconds since trial start that stimulus comes on.');
                return;
            end
            if ~isnumeric(value)
                error('onSec must be a number');
            end
            S.onSec=value;
        end
        function set.durSec(S,value)
            if value=='?'
                disp('durSec (numeric): Time in seconds since onSec that the stimulus stays on.');
                return;
            end
            if ~isnumeric(value)
                error('durSec must be a number');
            end
            S.durSec=value;
        end
        function set.rndSeed(S,value)
            if value=='?'
                disp('rndSeed (numeric): the seed of the stim''s internal random number generator. Can be used to reproduce stochastic stimuli.');
                return;
            end
            if ~isnumeric(value)
                error('rndSeed must be a number');
            end
            S.rndSeed=value;
            S.RND=RandStream('mt19937ar','Seed',S.rndSeed); %#ok<MCSUP>
        end
        function set.name(S,value)
            if value=='?'
                disp('name (char): how the stimulus will show up in the datafile. Also used for mutual referencing between interactive stimuli and responses classes.');
                return;
            end
            if ~ischar(value)
                error('stimulus name must be a string');
            end
            if isempty(value)
                error('stimulus name must be a non-empty string');
            end
            if isempty(regexp(value(1),'[a-z-A-Z]','ONCE'))
                error(['Stimulus name ''' value ''' does not start with a letter']);
            end
            if numel(regexp(value,'[a-z-A-Z-0-9]'))~=numel(value)
                error(['The stimulus name should consist exclusively of alphanumeric characters, but ''' value ''' was provided.']);
            end
            if any(isspace(value))
                error(['Stimulus name ''' value ''' contains whitespace characters']);
            end
            S.name=value;
        end
    end
end

