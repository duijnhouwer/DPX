classdef dpxRespArduinoPulse < dpxAbstractResp
    
    properties (Access=public)
        serialPortTag; % a string set in dpxPluginArduino to help find the port
        pins;
        correctPins;
    end
    properties (Access=protected)
        ser; % the serial port connection to the arduino, to be setup by dpxPluginArduino
        pinsChar;
        correctPinsChar;
    end
    methods (Access=public)
        function R=dpxRespArduinoPulse
            % Set the defaults in the constructor (i.e., here)
            R.serialPortTag='dpxArduinoTag';
            R.pins=[2 4];
            R.correctPins=2;
        end
    end
    methods (Access=protected)
        function myInit(R)
            R.ser = instrfind('Tag',R.serialPortTag);
            if isempty(R.ser)
                error('dpx:stim',['[dpxStimArduinoPulse] Could not connect to serial-port with tag ' S.serialPortTag '\n\tTIP: dpxPluginArduino must be added to the experiment']);
            end
        end
        function myGetResponse(R)
            if IsWin
                newlinechars=2;
            else
                warning('Check how many newline char on non-win platforms, fix, remove this warning');
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
                    if any(fromarduino==R.correctPinsChar)
                        disp('CORRECT RESPONSE!');
                        R.nameOfFeedBackStim=R.correctStimName;
                        R.endsTrialAfterFlips=round(R.correctEndsTrialAfterSec*R.scrGets.measuredFrameRate);
                    else 
                        disp('inCORRECT RESPONSE!');
                        R.nameOfFeedBackStim=R.wrongStimName;
                        R.endsTrialAfterFlips=round(R.wrongEndsTrialAfterSec*R.scrGets.measuredFrameRate);
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
                error('Response pins need to be numbers between 2 and 9 inclusive');
            end
            S.pins=value;
            S.pinsChar=char(48+value); %#ok<MCSUP> % char(48) equals '0'
        end
        function set.correctPins(S,value)
            if any(value>9 | value<2)
                error('Response pins need to be numbers between 2 and 9 inclusive');
            end
            S.correctPins=value;
            S.correctPinsChar=char(48+value); %#ok<MCSUP>  % char(48) equals '0' 
        end
    end 
end