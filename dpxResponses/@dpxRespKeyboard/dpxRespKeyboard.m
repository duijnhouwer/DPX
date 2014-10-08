classdef dpxRespKeyboard < dpxAbstractResp
    
    properties (Access=public)
        % A comma separated list of keys-names that are valid responses To
        % find out the name of key press type 'KbName('UnifyKeyNames')' on
        % the command line and press Enter. Then, type 'KbName' followed by
        % Enter and, after a second, press the key you want to use.
        kbNames='LeftArrow,RightArrow'; % comma separated list of keys
        % A similar list of key-names that are the correct response,
        % typically N=1 if feedback is used, or N=0 if no feedback is
        % given. Alternatively, enter a number in string format (e.g. '.9')
        % that represents the probability that the response is counted as
        % correct regardless of the response. This is usefull for
        % non-feedback trials (i.e., set it '1') or trials in which no
        % wrong or right answer exists (e.g., set it to 1 or .5)
        correctKbNames='1';
    end
    properties (Access=protected)
        figHandle;
    end
    methods (Access=protected)
        function myInit(R)
            R.resp=struct('keyNr',-1,'keyName','none','keySec',-1);
            KbName('UnifyKeyNames');
            R.kbNamesCell=strtrim(regexp(R.kbNames,',','split'));
            R.correctKbNamesCell=strtrim(regexp(R.correctKbNames,',','split'));
            R.figHandle=dpxCreateInvisibleEditBoxToInterceptKeypresses;
        end
        function myGetResponse(R)
            [keyIsDown,keyTime,keyCode]=KbCheck(-1);
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
                            R.endsTrialAfterFlips=round(R.correctEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                        else
                            R.nameOfFeedBackStim=R.wrongStimName;
                            R.endsTrialAfterFlips=round(R.wrongEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                        end
                        break;
                    end
                end
            end
        end
        function myClear(R)
            close(R.figHandle);
        end
    end
end