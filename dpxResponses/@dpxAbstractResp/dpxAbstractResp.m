classdef (Abstract) dpxAbstractResp < hgsetget
    
    properties (Access=public)
        className;
        name; % The object name.
        % The names of the stimuli that will be displayed as positive or negative
        % feedback. The stimulus in the dpxCoreCondition class or derived class
        % will use this cell-array of string to look up the feedback stimulus by
        % its 'name' field. Set to {''} when no feedback is desired.
        correctStimName={''};
        wrongStimName={''};
        % Time that the trial continues after the answer has been given. Can be
        % different for correct and incorrect trials.
        correctEndsTrialAfterSec=0.05;
        wrongEndsTrialAfterSec=0.05;
        % Time window in which the response can be given relative to trial onset.
        allowAfterSec=0;
        allowUntilSec=3600;

    end
    properties (GetAccess=public,SetAccess=protected,Hidden=true)
        % A logical (true/false) indicating that a valid response has been received
        given;
        % A structure representing the respones, this is defined in myInit, and can
        % be changed in derived classes for different response measures, such as
        % key-names or mouse-click positions. The fields of resp will automatically
        % be output in the DPXD output file.
        resp;
        % The name of a stimulus that will be enabled after a response is given,
        % this may receive different names depending on whether the response was
        % correct or incorrect.
        nameOfFeedBackStim='';
        % The window in which the response can be given in flips since the start of
        % the trial.
        allowAfterNrFlips=[];
        allowUntilNrFlips=[];
        % The time that will be added after a response. If Inf, the regular trial
        % end time will be observed (dpxCoreCondition.durSec)
        endsTrialAfterFlips=Inf;
        % Option to make a trial with a wrong answer (typically an animal that
        % answered too early) be repeated at some later point in the experiment. The
        % response class should be programmed to set this depending on the logic of
        % the experiment. dpxCoreCondition checks this and signals
        % dpxCoreExperiment to redo the trial if necessary.
        redoTrial='never'; % not set by user, but needs getacces to be visible to dpxCoreCondition
    end
    properties (Access=protected)
        scrGets=[];
        kbNamesCell={};
        correctKbNamesCell={};
        flipCounter=[];
    end
    methods (Access=public)
        function R=dpxAbstractResp
            % dpxAbstractResp - Abstract class for dpxResp classes.
            %
            % Classes for registering participant-responses, e.g. dpxRespKeyboard,
            % inherit basic properties and methods from this abstract class. Abstract
            % means no objects can be created from this class, it only serves to be
            % inherited. The names of all derived classes should be of the format
            % dpxRespXXXXX.
            %
            % Until 20140905 only a keyboard response functionality was present in the
            % form of class 'dpxCoreResponse'. That class has since been split into
            % this abstract class and the derived class dpxRespKeyboard.
            %
            % See also: dpxAbstractStim, dpxRespKeyboard
            %
            % Jacob Duijnhouwer, 20140905
            R.className=class(R); % class(R) returns name of derived class, not 'dpxAbstractResp'
            R.name=class(R); % can be overwritten (always recommended, and necessary when multiple objects of same class are added to condition)
        end
        function init(R,scrGets)
            % This is called before every trial
            R.given=false;
            R.allowAfterNrFlips=round(R.allowAfterSec*scrGets.measuredFrameRate);
            R.allowUntilNrFlips=round(R.allowUntilSec*scrGets.measuredFrameRate);
            R.scrGets=scrGets;
            R.redoTrial='never';
            myInit(R);
        end
        function getResponse(R,flipCounter)
            R.flipCounter=flipCounter;
            if R.flipCounter>R.allowAfterNrFlips && R.flipCounter<=R.allowUntilNrFlips;
                myGetResponse(R);
            end
        end
        function clear(R)
            myClear(R);
        end
    end
    methods (Access=protected)
        function myInit(R) %#ok<*MANU>
        end
        function myGetResponse(R)
        end
        function myClear(R)
        end
    end
    methods
        function set.name(S,value)
            if ~ischar(value)
                error('response name must be a string');
            end
            if any(isspace(value))
                error(['response name ''' value ''' contains whitespace characters']);
            end
            S.name=value;
        end
        function set.redoTrial(S,value)
            % This has SetAccess protected and can't be set by the user, interesting to
            % learn that the internal setting runs over this function as well, extra
            % way of making sure no bugs are introduced by for example typo's
            if ~any(strcmpi(value,{'never','immediately','sometime'}))
                error('redoTrial should be ''never'', ''immediately'', or ''sometime''');
            end
            S.redoTrial=value;
        end
        function set.correctStimName(S,value)
            if ischar(value)
                value={value};
            end
            if ~dpxIsCellArrayOfStrings(value);
                error('''correctStimName'' must be a string or a cell array of strings');
            end
            S.correctStimName=value;
        end
        function set.wrongStimName(S,value)
            if ischar(value)
                value={value};
            end
            if ~dpxIsCellArrayOfStrings(value);
                error('''wrongStimName'' must be a string or a cell array of strings');
            end
            S.wrongStimName=value;
        end
        function set.correctEndsTrialAfterSec(S,value)
            if ~isnumeric(value) 
                error('correctEndsTrialAfterSec must be a positive number or Inf. Inf means observe regular trial end (durSec).');
            end
            S.correctEndsTrialAfterSec=value;
        end
        function set.wrongEndsTrialAfterSec(S,value)
            if ~isnumeric(value) || value<0
                error('wrongEndsTrialAfterSec must be a positive number or Inf. Inf means observe regular trial end (durSec).');
            end
            S.wrongEndsTrialAfterSec=value;
        end
    end
end
