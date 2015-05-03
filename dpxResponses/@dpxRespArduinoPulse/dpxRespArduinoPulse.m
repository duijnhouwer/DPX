classdef dpxRespArduinoPulse < dpxAbstractResp
    
    properties (Access=public)
        serialPortTag; % a string set in dpxPluginArduino to help find the port
        pins;
        rewardProb;
        redoTrialIfWrong;
    end
    properties (Access=protected)
        ser; % the serial port connection to the arduino, to be setup by dpxPluginArduino
        pinsChar;
    end
    methods (Access=public)
        function R=dpxRespArduinoPulse
            % Set the defaults in the constructor (i.e., here)
            R.serialPortTag='dpxArduinoTag';
            R.pins=[2 4];
            R.rewardProb=[1 0];
            R.redoTrialIfWrong='never'; % if 'immediate' or 'sometime', a trial with an incorrect answer 
              % will be re-tried immediately or at some random future moment in the experiment (see
              % dpxCoreExperiment, dpxCoreCondition, look for 'REDOTRIAL')
        end
    end
    methods (Access=protected)
        function myInit(R)
            R.ser = instrfind('Tag',R.serialPortTag);
            if isempty(R.ser)
                error('dpx:stim',['[dpxStimArduinoPulse] Could not connect to serial-port with tag ' S.serialPortTag '\n\tTIP: dpxPluginArduino must be added to the experiment']);
            end
            if numel(R.pins)~=numel(R.rewardProb)
                error('pins and rewardProb arrays don''t correspond');
            end
        end
        function myGetResponse(R)
            if IsWin
                newlinechars=2;
            else
                warning('Check how many newline char on non-win platforms (i expect 1), fix code, remove this warning');
                newlinechars=1;
            end
            nBytes=R.ser.BytesAvailable;
            if nBytes>=1+newlinechars
                % new bytes were written to the serial port buffer
                % We are using Serial.println on the Arduino to write a
                % single unsigned char per event (e.g., lick on, lick off),
                % This results in 3 bytes transferred over the serial
                % connection, the byte + Carriage return and Newline
                % characters. On Linux and Mac this is probably
                % different, i expect only one extra char there
                fromarduino=fread(R.ser,nBytes,'uchar');    
                fromarduino=char(fromarduino(end-newlinechars));
                if any(fromarduino==R.pinsChar)
                    R.resp.char=fromarduino;
                    R.resp.sec=GetSecs;
                    R.given=true;
                    if rand<R.rewardProb(fromarduino==R.pinsChar)
                        %disp('REWARD');
                        R.nameOfFeedBackStim=R.correctStimName;
                        R.endsTrialAfterFlips=round(R.correctEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                        R.redoTrial='never';
                    else
                        %disp('PUNISH');
                        R.nameOfFeedBackStim=R.wrongStimName;
                        R.endsTrialAfterFlips=round(R.wrongEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                        R.redoTrial=R.redoTrialIfWrong;
                    end
                end
            end
        end
        function myClear(R)
            R; %#ok<VUNUS>
        end
    end
    methods
        function set.pins(S,value)
            if any(value>9 | value<2)
                error('Response pins need to be whole numbers between 2 and 9 inclusive');
            end
            S.pins=value;
            S.pinsChar=char(48+value); %#ok<MCSUP> % char(48) equals '0'
        end     
        function set.rewardProb(S,value)
            if any(value<0 | value>1)
                error('rewardProb need to be values between 0 and 1 (probablity of reward for corresponding pin)'); 
            end
            S.rewardProb=value;        
        end
        function set.redoTrialIfWrong(S,value)
            if ~any(strcmpi(value,{'never','immediately','sometime'}))
                error('redoTrialIfWrong should be ''never'', ''immediately'', or ''sometime''');
            end
            S.redoTrialIfWrong=value;
        end       
    end 
end