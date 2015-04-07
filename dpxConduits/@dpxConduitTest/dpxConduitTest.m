classdef dpxConduitTest < dpxAbstractConduit
    
    properties (Access=public)
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function CNDT=dpxConduitTest
            % dpxConduitTest
            % Example of a dpxConduit class that does nothing particularly useful but
            % demonstrate the mechanism of the conduit concept. It takes as input the
            % motion direction of a random dot stimulus in the previous trial, and the
            % direction discrimination response given by the observer. If the response was
            % correct, reverse the motion on the next trial, otherwise keep the motion
            % unchanged.
            % dxpConduitQuest will be a more useful example but I haven't programmed that
            % yet.
        end
        function input(CNDT,stims,resps,trigs)
            CNDT.inputValues={};
            
            
            % TODO WORK IN PROGRESS
            
            
        end
        function condition=output(CNDT,condition)
            if isempty(CNDT.inputValues)
                % first trial, do nothing
                return;
            end
        end
    end
end
          
        
