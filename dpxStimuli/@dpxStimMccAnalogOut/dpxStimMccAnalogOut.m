classdef dpxStimMccAnalogOut < dpxAbstractStim
         
    properties (Access=public)
        Voff;
        Von;
        channelOnSec;
        channelDurSec;
        channelNr;
        daqNr;
    end
    properties (Access=protected)
        channelOnFlip;
        channelOffFlip;
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
            S.daqNr=DaqDeviceIndex([],0);
            DaqAOut(S.daqNr,0,0);
            DaqAOut(S.daqNr,1,0);
            S.channelNr=0; % can be a single 0 or 1 or any other pattern that will be repeated         
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.channelOnFlip=round(S.channelOnSec*S.scrGets.measuredFrameRate+S.onFlip);
            S.channelOffFlip=S.channelOnFlip+round(S.channelDurSec*S.scrGets.measuredFrameRate);
            DaqAOut(S.daqNr,0,S.Voff/4.095);
            DaqAOut(S.daqNr,1,S.Voff/4.095);
        end
        function myDraw(S)
            ons=find(S.flipCounter==S.channelOnFlip);
            offs=find(S.flipCounter==S.channelOffFlip);
            for i=ons(:)'
                idx=mod(i-1,numel(S.channelNr))+1;
                DaqAOut(S.daqNr,S.channelNr(idx),S.Von/4.095);  
            end
            for i=offs(:)'
                idx=mod(i-1,numel(S.channelNr))+1;
                DaqAOut(S.daqNr,S.channelNr(idx),S.Voff/4.095);  
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
         function set.channelNr(S,value)
            if ~all(value==1 | value==0)
                error('channel should be a vector of zeros and ones');
            end
            S.channelNr=value;
         end
    end
end