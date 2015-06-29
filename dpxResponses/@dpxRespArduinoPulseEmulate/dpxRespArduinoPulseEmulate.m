classdef dpxRespArduinoPulseEmulate < dpxRespArduinoPulse
    
    properties (Access=public)
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function R=dpxRespArduinoPulseEmulate
            % Set the defaults in the constructor (i.e., here)
            R.pins=[2 4];
            R.rewardProb=[1 0];
            R.redoTrialIfWrong='never'; % if 'immediate' or 'sometime', a trial with an incorrect answer 
              % will be re-tried immediately or at some random future moment in the experiment (see
              % dpxCoreExperiment, dpxCoreCondition, look for 'REDOTRIAL')
            KbName('UnifyKeyNames');
        end
    end
    methods (Access=protected)
        function myInit(R)
            dpxDispFancy('USING dpxRespArduinoPulseEmulate NOT dpxRespArduinoPulse');
            disp('* USE KEYS 1--9 TO EMULATE ARDUINO INPUT PULSES');
            if numel(R.pins)~=numel(R.rewardProb)
                error('pins and rewardProb arrays don''t correspond');
            end
            % Initialize the empty response structure
            R.resp.pinNr=-1;
            R.resp.sec=-Inf;
        end
        function myGetResponse(R)
            [keyIsDown,~,keyCode]=KbCheck(-1);
            if keyIsDown
                key=nan;
                if keyCode(KbName('1!'))
                    key=1;
                elseif keyCode(KbName('2@'))
                    key=2;
                elseif keyCode(KbName('3#'))
                    key=3;
                elseif keyCode(KbName('4$'))
                    key=4;
                elseif keyCode(KbName('5%'))
                    key=5;
                elseif keyCode(KbName('6^'))
                    key=6;
                elseif keyCode(KbName('7&'))
                    key=7;
                elseif keyCode(KbName('8*'))
                    key=8;
                elseif keyCode(KbName('9('))
                    key=9;
                end
                disp(['DETECTED KEYPRESS ' num2str(key)']);
                if any(num2str(key)==R.pinsChar)
                    R.resp.pinNr=key; % one response per trial
                    R.resp.sec=GetSecs; % one response per trial
                    R.given=true;
                    if rand<R.rewardProb(num2str(key)==R.pinsChar)
                        disp('REWARD');
                        R.nameOfFeedBackStim=R.correctStimName;
                        R.endsTrialAfterFlips=round(R.correctEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                        R.redoTrial='never';
                    else
                        disp('PUNISH');
                        R.nameOfFeedBackStim=R.wrongStimName;
                        R.endsTrialAfterFlips=round(R.wrongEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                        R.redoTrial=R.redoTrialIfWrong;
                    end
                end
            end
        end
    end
end