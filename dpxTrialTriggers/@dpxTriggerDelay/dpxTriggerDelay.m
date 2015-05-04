classdef dpxTriggerDelay < dpxAbstractTrigger
    properties (Access=public)
        minSec;
        maxSec;
    end
    properties (Access=protected)
        startSec;
        delaySec;
    end
    methods (Access=public)
        function T=dpxTriggerDelay
            % dpxTriggerDelay
            % Part of DPX: An experiment preparation system
            % http://duijnhouwer.github.io/DPX/
            % Jacob Duijnhouwer 2015-05-04
            %
            % Lock the trial in flip-0 until some random delay from a uniform
            % distribution between minSec and maxSec  
            
            T.minSec=0;
            T.maxSec=1;
        end
    end
    methods (Access=protected)
        function myInit(T)
            T.delaySec=T.minSec+T.RND.rand*(T.maxSec-T.minSec);    
        end 
        function bool=myGo(T)
            % flipZeroCounter is updated before myGo is called, so 1-based counting of
            % frames (consistend with flipCounter in dpxAbstractStim)
            if T.flipZeroCounter==1
                T.startSec=GetSecs;
            end
            bool=GetSecs>T.startSec+T.delaySec; % returns true if time exceeds random delay
        end
    end
    methods
        function set.minSec(T,value)
            if ~isnumeric(value) || value<0
                error('minSec must be a >=0 number');
            end
            T.minSec=value;
        end
        function set.maxSec(T,value)
            if ~isnumeric(value) || value<0
                error('maxSec must be a >=0 number');
            end
            T.maxSec=value;
        end
    end
end
         