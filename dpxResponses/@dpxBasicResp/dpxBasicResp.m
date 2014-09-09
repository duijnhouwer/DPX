classdef dpxBasicResp < hgsetget
    
    properties (Access=public)
        % The names of the stimuli that will be displayed as positive or
        % negative feedback. The stimulus in the dpxCoreCondition class or
        % derived class will use this string to look up the feedback
        % stimulus by its 'name' field. Set to 'none' when no feedback is
        % desired.
        correctStimName='none';
        wrongStimName='none';
        % Time that the trial continues after the answer has been given.
        % Can be different for correct and incorrect trials.
        correctEndsTrialAfterSec=0.05;
        wrongEndsTrialAfterSec=0.05;
        % Time window in which the response can be given relative to trial
        % onset.
        allowAfterSec=1;
        allowUntilSec=120;
        % The object name, when left empty, this will default to the
        % class-name when added to condition
        name='';
    end
    properties (GetAccess=public,SetAccess=protected)
        % A logical (true/false) indicating that a valid response has been
        % received
        given;
        % A structure representing the respones, this is defined in myInit,
        % and can be changed in derived classes for different response
        % measures, such as key-names or mouse-click positions. The fields
        % of resp will automatically be output in the dpxTbl output file.
        resp;
        nameOfFeedBackStim='none';
        allowAfterNrFlips;
        allowUntilNrFlips;
        endsTrialAfterFlips;
    end
    properties (Access=protected)
        physScrVals;
        flipCounter;
        kbNamesCell={};
        correctKbNamesCell={};
    end
    methods (Access=public)
        function R=dpxBasicResp
            % dpxBasicResp - Abstract class for dpxResp classes.
            %
            % Classes for registering participant-responses, e.g.
            % dpxRespKeyboard, inherit basic properties and methods from
            % this abstract class. Abstract means no objects can be created
            % from this class, it only serves to be inherited. The names of
            % all derived classes should be of the format dpxRespXXXXX.
            %
            % Until 20140905 only a keyboard response functionality was
            % present in the form of class 'dpxCoreResponse'. That class
            % has since been split into this abstract class and the derived
            % class dpxRespKeyboard.
            %
            % See also: dpxBasicStim, dpxRespKeyboard
            %
            % Jacob Duijnhouwer, 20140905
        end
        function init(R,physScrVals)
            R.given=false;
            R.allowAfterNrFlips=round(R.allowAfterSec*physScrVals.measuredFrameRate);
            R.allowUntilNrFlips=round(R.allowUntilSec*physScrVals.measuredFrameRate);
            R.flipCounter=0;
            R.physScrVals=physScrVals;
            myInit(R);
        end
        function getResponse(R)
            R.flipCounter=R.flipCounter+1;
            if R.flipCounter>=R.allowAfterNrFlips && R.flipCounter<R.allowUntilNrFlips;
                myGetResponse(R);
            end
        end
        function clear(R)
            myClear(R);
        end
    end
    methods (Access=protected)
        function myInit(R)
        end
        function myGetResponse(R)
        end
        function myClear(R)
        end
    end
end
