classdef dpxStimMccAnalogOut < dpxAbstractStim
         
    properties (Access=public)
        Voff;
        Von;
        channelOnSec; % can be a single on time or a pattern ...
        channelDurSec; ... with a corresponding array of durations
        channelNr;
        daqNr; % set to -666 manually for debugging without an MCC
    end
    properties (Access=protected)
        channelOnFlip;
        channelOffFlip;
    end
    methods (Access=public)
        function S=dpxStimMccAnalogOut
            % S=dpxStimMccAnalogOut
            % Output a Voltage on Measurement Computer USB-1208FS.
            % Channel 0: between pin 13 and a ground pin (9, 12, and 15 are ground pins)
            % Channel 1: between pin 14 and a ground pin
            %
            % Voltage will be Von during the stimulus interval from onSec
            % to onSec+durSec, and Voff outside this interval.
            %
            % See also: DaqPins, DaqDeviceIndex, DaqAOut
            S.Voff=0;
            S.Von=4;
            S.channelNr=0; % typically a single 0 or 1, but can be any other pattern that will be repeated
            S.daqNr=DaqDeviceIndex([],0);
            if isempty(S.daqNr)
                warning('No Measurement Computer USB-1208FS detected.');
            else
                DaqAOut(S.daqNr,0,0);
                DaqAOut(S.daqNr,1,0);
            end
        end
    end
    methods (Access=protected)
        function myInit(S)
            if isempty(S.daqNr)
                error('No Measurement Computer USB-1208FS detected.');
            end
            S.channelOnFlip=round(S.channelOnSec*S.scrGets.measuredFrameRate+S.onFlip);
            S.channelOffFlip=S.channelOnFlip+round(S.channelDurSec*S.scrGets.measuredFrameRate);
            if S.daqNr~=-666
                DaqAOut(S.daqNr,0,S.Voff/4.095);
                DaqAOut(S.daqNr,1,S.Voff/4.095);
            end
        end
        function myDraw(S)
            if S.daqNr==-666
                return;
            end
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
         function set.daqNr(S,value)
             if value==-666
                 disp(['[' mfilename '] debugging is enabled because daqNr is -666, MCC will not set any voltages']);
             end
             S.daqNr=value;
         end
    end
end