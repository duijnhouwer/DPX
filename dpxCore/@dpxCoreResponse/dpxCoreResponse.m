classdef (CaseInsensitiveProperties=true ...
        ,Description='a' ...
        ,DetailedDescription='ab') ...
        dpxCoreResponse < hgsetget
    
    properties (Access=public)
        % A comma separated list of keys-names that are valid responses
        % To find out the name of key press KbName on the command and press
        % enter, and after a second, press the key you want to use.
        kbNames='LeftArrow,RightArrow'; % comma separated list of keys
        % A similar list of key-names that are the correct response,
        % typically N=1 if feedback is used, or N=0 if no feedback is
        % given. Alternatively, enter a number in string format (e.g. '.9')
        % that represents the probability that the response is counted as
        % correct regardless of the response. This is usefull for
        % non-feedback trials (i.e., set it '1') or trials in which no
        % wrong or right answer exists (e.g., set it to 1 or .5)
        correctKbNames='1';
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
        allowUntilSec=Inf;
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
        % measures, including analog readouts (e.g. mouse click). The
        % fields of resp will be output in the output file (dpxTbl format)
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
        function R=dpxCoreResponse
        end
        function init(R,physScrVals)
            KbName('UnifyKeyNames');
            R.given=false;
            R.allowAfterNrFlips=R.allowAfterSec*physScrVals.measuredFrameRate;
            R.allowUntilNrFlips=R.allowUntilSec*physScrVals.measuredFrameRate;
            R.flipCounter=0;
            R.kbNamesCell=strtrim(regexp(R.kbNames,',','split'));
            R.correctKbNamesCell=strtrim(regexp(R.correctKbNames,',','split'));
            R.physScrVals=physScrVals;
            R.name='';
            myInit(R);
        end
        function getResponse(R)
            R.flipCounter=R.flipCounter+1;
            if R.flipCounter>=R.allowAfterNrFlips && R.flipCounter<R.allowUntilSec;
                myGetResponse(R);
            end
        end
        function clear(R)
            myClear(R);
        end
    end
    methods (Access=protected)
        function myInit(R)
            R.resp=struct('keyNr',-1,'keyName','none','keySec',-1);
        end
        function myGetResponse(R)
            [keyIsDown,keyTime,keyCode]=KbCheck;
            if keyIsDown
                % A key has been pressed, see if it is one of the defined
                % KbNames for this condition.
                for i=1:numel(R.kbNamesCell)
                    if keyCode(KbName(R.kbNamesCell{i}));
                        % A defined key was pressed, parcel it in the resp
                        % structure for output to the caller function
                        R.resp.keyNr=i;
                        R.resp.keyName=R.kbNamesCell{i};
                        R.resp.keySec=keyTime;
                        R.given=true;
                        % Check if the key is the correct key or not. Set
                        % the stimToShow name from 'none' to the
                        % appropriate stimulus name (which can also be
                        % 'none' in case no feedback is desired). The
                        % dpxCoreCondition class or its derivatives will
                        % use this field to enable the visibility of the
                        % feedback stimulus. Also set the number of flips
                        % that will remain in the trial after the response
                        % was given. This can be different for wrong and
                        % correct responses. If less than
                        % R.endsTrialAfterFlips remain in the trial, the
                        % trial will end at its internal trialOff time.
                        if ~isnan(str2double(R.correctKbNamesCell{1}))
                            correct=rand<=str2double(R.correctKbNamesCell{1});
                        else
                            correct=any(strcmpi(R.resp.keyName,R.correctKbNamesCell));
                        end
                        if correct
                            R.nameOfFeedBackStim=R.correctStimName;
                            R.endsTrialAfterFlips=round(R.correctEndsTrialAfterSec*R.physScrVals.measuredFrameRate);
                        else
                            R.nameOfFeedBackStim=R.wrongStimName;
                            R.endsTrialAfterFlips=round(R.wrongEndsTrialAfterSec*R.physScrVals.measuredFrameRate);
                        end
                        break;
                    end
                end
            end
        end
        function myClear(R)
        end
    end
end
