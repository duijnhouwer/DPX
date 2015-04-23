classdef (Abstract) dpxAbstractStim < hgsetget
    
    properties (Access=public)
        visible;
        onSec;
        durSec;
        xDeg;
        yDeg;
        zDeg;
        wDeg;
        hDeg;
        aDeg;
        name;
        fixWithinDeg;
        rndSeed;
    end
    properties (SetAccess=public,GetAccess=protected)
        initialPublicState=[];
    end
    properties (Access=protected)
        onFlip;
        offFlip;
        xPx;
        yPx;
        zPx;
        wPx;
        hPx;
        winCntrXYpx=[];
        scrGets=[];
        flipCounter;
        stepCounter;
        fixWithinPx=[];
        eyeUsed=-1;
        el;
        RND; % RandStream
    end
    methods (Access=public)
        function S=dpxAbstractStim
            % dpxAbstractStim - Abstract class for dpxStim classes.
            %
            % Abstract means no objects can be created from this class, it only serves
            % to be inherited. The names of all derived classes should be of the format
            % dpxStimXXX where XXX is a placeholder for the name of your stimulus.
            %
            % See also: dpxAbstractResp, dpxStimRdk
            %
            % Jacob Duijnhouwer, 2014-09-05
            S.visible=true; % Toggle visibility of the stimulus, true|false
            S.onSec=0; % Time since trial start that stimulus comes on
            S.durSec=Inf; % Duration of stim (relative to start)
            S.xDeg=0; % Horizontal position of stimulus relative to screen center
            S.yDeg=0; % Vertical position of stimulus relative to screen center
            S.zDeg=0; % Position on axis normal to screen. Currently (10/2014) only stereoscopic stimuli use this but could in the future be used for all stimuli to control mutual occlusion.
            S.wDeg=1; % Widht of the stimulus
            S.hDeg=1; % Height of the stimulus
            S.aDeg=0; % Rotation of stimuli around screen normal. Currently (10/2014) no stimuli use this, placeholder.
            S.name=''; % defaults to class-name when added to condition
            S.fixWithinDeg=-1; % if larger that >0, fixation on stim is required
            S.rndSeed=rand*(2^32); % the seed of the stim's internal randstream, setting this will automatically instantiate the RandStream
            S.flipCounter=0;
            S.stepCounter=0;
        end
        function lockInitialPublicState(S)
            % addStim of the condition class will call this function to store a copy of
            % all publicly settable parameters of this stimulus in initialPublicState.
            % Before a repeat of the condition is presented, this struct is used to
            % restore this stimulus to its starting state. So when, for example, the
            % property 'visible' was toggled it will be reset prior to the next trial
            % of this condition.
            if ~isempty(S.initialPublicState)
                error('lockInitialPublicState should be called only once on a stimulus, during addStim');
            end
            S.initialPublicState=dpxGetSetables(S);
        end
        function restoreInitialPublicState(S)
            if isempty(S.initialPublicState)
                error('lockInitialPublicState should have been called during addStim');
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
            S.stepCounter=0;
            S.onFlip = round(S.onSec * scrGets.measuredFrameRate);
            S.offFlip = round((max(S.onSec,0) + S.durSec) * scrGets.measuredFrameRate);
            S.winCntrXYpx = [scrGets.widPx/2 scrGets.heiPx/2];
            S.xPx = S.xDeg * scrGets.deg2px;
            S.yPx = S.yDeg * scrGets.deg2px;
            S.wPx = S.wDeg * scrGets.deg2px;
            S.hPx = S.hDeg * scrGets.deg2px;
            S.scrGets=scrGets;
            S.myInit; % stimulus class specific init
            if S.fixWithinDeg>0 && S.checkEyelinkIsConnected
                S.fixWithinPx=S.fixWithinDeg * scrGets.deg2px;
                S.el=EyelinkInitDefaults(scrGets.windowPtr);
                S.eyeUsed=-1;
            end
        end
        function stepAndDraw(S,flipCounter)
            S.flipCounter=flipCounter;
            if S.flipCounter>S.onFlip && S.flipCounter<=S.offFlip
                S.stepCounter=S.stepCounter+1;
                S.myStep;
                if S.visible
                    S.myDraw;
                end
            end
        end
        function clear(S)
            S.myClear;
        end
        function [ok,str]=fixationStatus(S)
            ok=true;
            str='thisShouldNotBePossibleLookIntoIt';
            if S.fixWithinDeg<=0
                str='NotRequired';
            else
                if Eyelink('NewFloatSampleAvailable') > 0
                    % get the sample in the form of an event structure
                    evt = Eyelink('NewestFloatSample');
                    if S.eyeUsed==-1
                        S.eyeUsed = Eyelink('EyeAvailable'); % get eye that's tracked
                        if S.eyeUsed == S.el.BINOCULAR; % if both eyes are tracked
                            S.eyeUsed = S.el.LEFT_EYE; % use left eye
                        end
                    end
                    x = evt.gx(S.eyeUsed+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(S.eyeUsed+1);
                    % do we have valid data and is the pupil visible?
                    if x~=S.el.MISSING_DATA && y~=S.el.MISSING_DATA && evt.pa(S.eyeUsed+1)>0
                        % The data is valid. Now check if it's within the maximum distance from the
                        % stimulus x,y;
                        x=x-S.winCntrXYpx(1);
                        y=y-S.winCntrXYpx(2);
                        distPx=hypot(S.xPx-x,S.yPx-y);
                        if distPx<S.fixWithinPx
                            str='InsideWindow';
                        else
                            str='BreakFixation';
                            ok=false;
                        end
                        return;
                    else
                        % The data is invalid (e.g. during a blink)
                        ok=false;
                        str='BreakFixation';
                        return;
                    end
                else
                    str='NoSampleAvailable';
                end
            end
        end
    end
    methods (Access=protected)
        % redefine these "my"-functions is your stimulus class
        function myInit(S), end %#ok<*MANU>
        function myDraw(S), end
        function myStep(S), end
        function myClear(S), end
        %
        function ok=checkEyelinkIsConnected(S)
            try
                Eyelink('EyeAvailable');
                ok=true;
            catch me
                error(['It seems that no conection with an Eyelink has been established, yet your script requires stimulus ' S.name ' to be foveated within ' num2str(S.fixWithinDeg) ' degrees. Please check dpxDocsEyelinkHowTo']);
            end
        end
    end
    methods
        function set.visible(S,value)
            if value=='?'
                disp('visible (logical): Toggle visibility of the stimulus.');
                return;
            end
            if ~islogical(value) && ~isnumeric(value)
                error('Enable should be numeric or (preferably) logical');
            end
            S.visible=logical(value);
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
        function set.xDeg(S,value)
            if value=='?'
                disp('xDeg (numeric): Horizontal position of stimulus relative to screen-center. In degrees provided the screen settings are correct.');
                return;
            end
            if ~isnumeric(value)
                error('xDeg must be a number');
            end
            S.xDeg=value;
        end
        function set.yDeg(S,value)
            if value=='?'
                disp('yDeg (numeric): Vertical position of stimulus relative to screen-center. In degrees provided the screen settings are correct.');
                return;
            end
            if ~isnumeric(value)
                error('yDeg must be a number');
            end
            S.yDeg=value;
        end
        function set.zDeg(S,value)
            if value=='?'
                disp('zDeg (numeric): Position on axis normal to screen. Currently (4/2015) only stereoscopic stimuli use this but could in the future be used for all stimuli to control occlusion.');
                return;
            end
            if ~isnumeric(value)
                error('zDeg must be a number');
            end
            S.zDeg=value;
        end
        function set.wDeg(S,value)
            if value=='?'
                disp('wDeg (numeric): Width of the stimulus. In degrees (provided the screen settings are correct).');
                return;
            end
            if ~isnumeric(value)
                error('wDeg must be a number');
            end
            S.wDeg=value;
        end
        function set.hDeg(S,value)
            if value=='?'
                disp('hDeg (numeric): Height of the stimulus. In degrees (provided the screen settings are correct).');
                return;
            end
            if ~isnumeric(value)
                error('hDeg must be a number');
            end
            S.hDeg=value;
        end
        function set.aDeg(S,value)
            if value=='?'
                disp('aDeg (numeric): Orientation of the stimulus in degrees. Not used by any stimulus as of writing 4-2015, placeholder.');
                return;
            end
            if ~isnumeric(value)
                error('aDeg must be a number');
            end
            S.aDeg=value;
        end
        function set.fixWithinDeg(S,value)
            if value=='?'
                disp('fixWithinDeg (numeric): the maximum allowable deviation of the eye (as determined with for instance eyelink) and this stimulus'' xDeg and yDeg. Ignored if <=0.');
                return;
            end
            if ~isnumeric(value)
                error('fixWithinDeg seed must be a number');
            end
            S.fixWithinDeg=value;
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
            % check first char not digit
            if any(isspace(value))
                error(['stimulus name ''' value ''' contains whitespace characters']);
            end
            S.name=value;
        end
    end
end

