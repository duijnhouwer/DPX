classdef dpxRespKeyboard < dpxAbstractResp
    
    properties (Access=public)
        kbNames;
        correctKbNames;
        redoTrialIfWrong;
    end
    methods (Access=public)
        function R=dpxRespKeyboard
            % dpxRespKeyboard Part of the DPX toolkit
            % http://duijnhouwer.github.io/DPX/
            % Jacob Duijnhouwer, updated 2015-05-04
            %
            % Properties:
            %   kbNames: a comma separated list of keys-names that are valid responses. To
            %       find out the name of key press type 'KbName('UnifyKeyNames')' on
            %       the command line and press Enter. Then, type 'KbName' followed by
            %       Enter and, after a second, press the key you want to use.
            %   correctKbNames:  A similar list of key-names that are the correct response,
            %       typically N=1 if feedback is used, or N=0 if no feedback is
            %       given. Alternatively, enter a number in string format (e.g. '.9')
            %       that represents the probability that the response is counted as
            %       correct regardless of the response. This is usefull for
            %       non-feedback trials (i.e., set it '1') or trials in which no
            %       wrong or right answer exists (e.g., set it to 1 or .5)
            %   redoTrialIfWrong: repeat the trial in case of a wrong answer ['never'],
            %       'immediately', or 'sometime' (sometime=randomly inserted into list
            %       of future trials)
            %
            % See also: dpxContiRespKeyboard
            R.kbNames='LeftArrow,RightArrow';
            R.correctKbNames='1';
            R.redoTrialIfWrong='never';
        end
    end
    methods (Access=protected)
        function myInit(R)
            R.resp=struct('keyNr',-1,'keyName','none','keySec',-1);
            KbName('UnifyKeyNames');
            R.kbNamesCell=strtrim(regexp(R.kbNames,',','split'));
            R.correctKbNamesCell=strtrim(regexp(R.correctKbNames,',','split'));
            ListenChar(2);
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
                            R.redoTrial='never';
                        else
                            R.nameOfFeedBackStim=R.wrongStimName;
                            R.endsTrialAfterFlips=round(R.wrongEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                            R.redoTrial=R.redoTrialIfWrong; % flags 
                        end
                        break;
                    end
                end
            end
        end
        function myClear(R) %#ok<MANU>
            ListenChar(0);
        end
    end
    methods
        function set.redoTrialIfWrong(S,value)
            if ~any(strcmpi(value,{'never','immediately','sometime'}))
                error('redoTrialIfWrong should be ''never'', ''immediately'', or ''sometime''');
            end
            S.redoTrialIfWrong=value;
        end
        function set.kbNames(S,value)
            if ~ischar(value)
                error('kbNames should be string (e.g., ''LeftArrow,RightArrow'')');
            end
            value(isspace(value))=[];% remove any whitespace;
            S.kbNames=value;
        end  
        function set.correctKbNames(S,value)
            if ~ischar(value)
                error('correctKbNames should be string (e.g., ''LeftArrow'')');
            end
            value(isspace(value))=[];% remove any whitespace;
            S.correctKbNames=value;
        end  
        
    end
end