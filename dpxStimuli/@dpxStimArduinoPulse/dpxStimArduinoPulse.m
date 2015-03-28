classdef dpxStimArduinoPulse < dpxAbstractStim
    
    properties (Access=public)
        serialPortTag;
        pinNr;
    end
    properties (Access=protected)
        ser; % the serial port connection to the arduino, to be setup by dpxPluginArduino
        onChar;
        offChar;
    end
    methods (Access=public)
        function S=dpxStimArduinoPulse
            % Set the defaults in the constructor (i.e., here)
            S.serialPortTag='dpxArduinoTag';
            S.pinNr=13;
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.ser = instrfind('Tag',S.serialPortTag);
            if isempty(S.ser)
                error('dpx:stim',['[dpxStimArduinoPulse] Could not connect to serial-port with tag ' S.serialPortTag '\n\tTIP: dpxPluginArduino must be added to the experiment']);
            end
        end
        function myDraw(S)
            % Only called when S.visible is true (unlike myStep)
            fprintf(S.ser,'%c',S.onChar); % Turn on the stimulus
            if S.flipCounter==S.offFlip
                % Turn off on the last flip of myDraw is reached, see
                % dpxAbstractStim.draw for the logical underpinning of this.
                fprintf(S.ser,'%c',S.offChar);
            end
        end
        function myClear(S)
            fprintf(S.ser,'%c',S.offChar);
        end
    end
    methods
        function set.pinNr(S,value)
            if ~any(value==[10 11 12 13])
                error('dpxStimArduinoPulse output should be on pin 10, 11, 12, or 13');
            end
            S.pinNr=value;
            S.onChar=char(64+value); % J K L or M
            S.offChar=char(64+32+value); % j k l or m
        end
    end
end
