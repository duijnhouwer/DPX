classdef dpxConduitTest < hgsetget
    
    properties (Access=public)
        inFields;
        outFields;
    end
    properties (Access=protected)
        inputValues;
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
            inFields={}; % cell array of parameter names as they appear in the DPXD struct
            outFields={}; % cell array of parameter names as they appear in the DPXD struct
            inputValues={};
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
    methods
        function set.inFields(CNDT,value)
            [ok,str]=dpxIsCellArrayOfStrings;
            if ~ok, error(['inFields should be ' str]); end
            CBDT.inFields=value;
        end
        function set.outFields(CNDT,value)
            [ok,str]=dpxIsCellArrayOfStrings;
            if ~ok, error(['outFields should be ' str]); end
            CBDT.outFields=value;
        end
    end
end
          
        
