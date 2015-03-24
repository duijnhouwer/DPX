classdef dpxStimArduinoPulse < dpxAbstractStim
    
    properties (Access=public)
        serialPortTag;
        onChar;
        offChar;
    end
    properties (Access=protected)
        ser; % the serial port connection to the arduino, to be setup by dpxPluginArduino
    end
    methods (Access=public)
        function S=dpxStimArduinoPulse
            % Set the defaults in the constructor (i.e., here)
            S.serialPortTag='dpxArduinoTag';
            S.onChar='R';
            S.offChar='r';
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
end
