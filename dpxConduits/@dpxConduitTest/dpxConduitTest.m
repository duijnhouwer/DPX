classdef dpxConduitTest < dpxAbstractConduit
    
    properties (Access=public)
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function U=dpxConduitTest
            % dpxConduitTest
            % Example of a dpxConduit class that does nothing particularly useful but
            % demonstrate the mechanism of the conduit concept. It takes as input the
            % motion direction of a random dot stimulus in the previous trial, and the
            % direction discrimination response given by the observer. If the response was
            % correct, reverse the motion on the next trial, otherwise keep the motion
            % unchanged.
            % dxpConduitQuest will be a more useful example but I haven't programmed that
            % yet.
            
            U.name='dpxConduitTest';
        end
    end
    methods (Access=protected)
        function nextDir=myFunction(U,prevDir,key)
            
            keyboard
            
            if prevDir>0 && strcmpi(key,'LeftArrow') || prevDir<0 && strcmpi(key,'RightArrow')
                disp('incorrect response was given')
                nextDir=prevDir; % repeat the same direction
            else
                disp('correct response was given')
                nextDir=[]; % empty means leave condition untoucjed
            end
        end
    end
end


