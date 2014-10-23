classdef dpxStimMccAnalogOut < dpxAbstractStim
         
    properties (Access=public)
        Voff;
        Von;
        channel=0;
    end
    properties (Access=protected)
        daqNr;
    end
    methods (Access=public)
        function S=dpxStimMccAnalogOut
            % S=dpxStimMccAnalogOut
            % Output a Voltage on Measurement Computer USB-1208FS.
            % Channel 0: between pin 13 and a ground pin, e.g., 9, 12, or 15
            % Channel 1: between pin 14 and a ground pin, e.g., 9, 12, or 15
            %
            % Voltage will be Von during the stimulus interval from onSec
            % to onSec+durSec, and Voff outside this interval.
            %
            % See also: DaqPins, DaqDeviceIndex, DaqAOut
            S.Voff=0;
            S.Von=4;
            S.daqNr=[];
            S.channel=0;
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.daqNr=DaqDeviceIndex([],0);
            DaqAOut(S.daqNr,0,S.Voff/4.095);
        end
        function myDraw(S)
             if S.flipCounter>S.onFlip && S.flipCounter<S.offFlip
                 DaqAOut(S.daqNr,0,S.Voff/4.095);
             elseif S.flipCounter==S.offFlip
                 DaqAOut(S.daqNr,0,S.Von/4.095);
             else
                 warning('This should not be possible! If you see this something must have changed in the design somewhere which affects dpxStimMccAnalogOut.m. Please check');
             end
        end
    end
    % set methods
    methods
        function set.Voff(S,value)
            if ~isnumeric(value) || value<0 || value>4.095
                error('Voff should be a number between 0 and 4.095');
            end
            S.Voff=value;
        end
         function set.Von(S,value)
            if ~isnumeric(value) || value<0 || value>4.095
                error('Von should be a number between 0 and 4.095');
            end
            S.Von=value;
         end
         function set.channel(S,value)
            if value~=0 && value~=1
                error('channel should be 0 or 1');
            end
            S.Voff=value;
         end
    end
end