classdef dpxStimMccAnalogOut < dpxAbstractStim
    
    properties (Access=public)
        initVolt;
        stepSec;
        stepVolt;
        pinNr;
        daqNr; % set to -666 manually for debugging without an MCC
    end
    properties (Access=protected)
        channelNr;
        stepFlip;
    end
    methods (Access=public)
        function S=dpxStimMccAnalogOut
            % S=dpxStimMccAnalogOut
            % Output a Voltage on Measurement Computer USB-1208FS.
            % pin 13 and a ground pin (9, 12, and 15 are ground pins)
            % pin 14 and a ground pin
            %
            % Voltage will be Von during the stimulus interval from onSec
            % to onSec+durSec, and Voff outside this interval.
            %
            % See also: DaqPins, DaqDeviceIndex, DaqAOut
            S.initVolt=0;
            S.stepSec=[.5 1];
            S.stepVolt=[2 0];
            S.pinNr=13;
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
            S.checkSettings;
            S.stepFlip=round(S.stepSec{:}*S.scrGets.measuredFrameRate+S.onFlip);
            if S.daqNr~=-666
                DaqAOut(S.daqNr,S.channelNr,S.initVolt/4.095);
            end
        end
        function myDraw(S)
            stepidx=find(S.flipCounter==S.stepFlip,1);
            if ~isempty(stepidx)
                if S.daqNr~=-666
                    DaqAOut(S.daqNr,S.channelNr,S.stepVolt{:}(stepidx)/4.095);
                else
                    disp(['Volt on channel ' num2str(S.channelNr) ' is now ' num2str(S.stepVolt{:}(stepidx))]);
                end
            end
        end
        function myClear(S)
            if S.daqNr~=-666
                DaqAOut(S.daqNr,S.channelNr,0);
            end
        end
        function checkSettings(S)
            if numel(S.stepSec{:})~=numel(S.stepVolt{:})
                error('The ''stepSec'' ''stepVolt'' arrays need the same number of elements!]');
            end
        end
    end
    % set methods
    methods
        function set.stepSec(S,value)
            if iscell(value)
                value=value{:};
            end
            if ~isnumeric(value)
                error('stepSec should be numbers (seconds since start of stimulus)');
            end
            S.stepSec={value};
        end
        function set.stepVolt(S,value)
            if iscell(value)
                value=value{:};
            end
            if ~isnumeric(value) || any(value<0) || any(value>4.095)
                error('Voff should be number(s) between 0 and 4.095');
            end
            S.stepVolt={value};
        end
        function set.pinNr(S,value)
            if ~dpxIsWholeNumber(value) || numel(value)>1 || ~any(value==[13 14])
                error('Channel should be 0 or 1');
            end
            S.pinNr=value;
            S.channelNr=value-13; %#ok<MCSUP> % 0 or 1
        end
        function set.daqNr(S,value)
            if value==-666
                disp('Debugging is enabled because daqNr is -666, MCC will not set any voltages');
            end
            S.daqNr=value;
        end
    end
end