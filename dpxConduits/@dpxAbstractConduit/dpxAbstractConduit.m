classdef (Abstract) dpxAbstractConduit < hgsetget
    
    properties (Access=public)
        inFields;
        outFields;
    end
    properties (Access=protected)
        firstTrial;
        inputValues;
    end
    methods (Access=public)
        function CNDT=dpxAbstractConduit
            inFields={}; % cell array of parameter names as they appear in the DPXD struct
            outFields={}; % cell array of parameter names as they appear in the DPXD struct
            inputValues={};
            firstTrial=true;
        end
        function input(CNDT,stims,resps,trigs)
            CNDT.inputValues={};
            
            
            % TODO WORK IN PROGRESS
            
            
        end
        function condition=output(CNDT,condition)
            if CNDT.firstTrial
                CNDT.firstTrial=false;
                return;
            end
        end
    end
    methods
        function set.inFields(CNDT,value)
            if ischar(value)
                value={value};
            end
            [ok,str]=dpxIsCellArrayOfStrings;
            if ~ok, error(['inFields should be a string or ' str ' containing fields as they appear in the DPXD of this experiment']); end
            CNDT.inFields=value;
        end
        function set.outFields(CNDT,value)
            if ischar(value)
                value={value};
            end
            [ok,str]=dpxIsCellArrayOfStrings;
            if ~ok, error(['outFields should be a string or ' str ' containing fields as they appear in the DPXD of this experiment']); end
            CNDT.outFields=value;
        end
    end
end
          
        
