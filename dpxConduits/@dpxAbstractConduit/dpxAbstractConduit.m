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
        function U=dpxAbstractConduit
            U.inFields={}; % cell array of parameter names as they appear in the DPXD struct
            U.outFields={}; % cell array of parameter names as they appear in the DPXD struct
            U.inputValues={};
            U.firstTrial=true;
        end
        function input(U,stims,resps,trigs)
            U.inputValues={};
            for i=1:numel(U.inFields)
                try
                    subfields=regexp(U.inFields{i},'_','split');
                    if strcmp(subfields{1},'resp')
                        if numel(subfields)==2 % this is possible, but unlikely
                            U.inputValues{end+1}=resps.(subfields{2});
                        elseif numel(subfields)==3 % this is the expected number
                            U.inputValues{end+1}=resps.(subfields{2}).(subfields{3});
                        elseif numel(subfields)==4 % this is here for just in case
                            U.inputValues{end+1}=resps.(subfields{2}).(subfields{3}).(subfields{4});
                        elseif numel(subfields)==5 % this is here for just in case in case
                            U.inputValues{end+1}=resps.(subfields{2}).(subfields{3}).(subfields{4}).(subfields{5});
                        else
                            error(['I did not design more than 3 levels in resp struct. the code will have to be trivially expanded to include up to at least ' num2str(numel(subfields) ' (!) levels ...']);
                        end
                    elseif strcmp(subfields{1},'trialtrigger')
                        if numel(subfields)==2 % this is possible, but unlikely
                            U.inputValues{end+1}=trigs.(subfields{2});
                        elseif numel(subfields)==3 % this is the expected number
                            U.inputValues{end+1}=trigs.(subfields{2}).(subfields{3});
                        elseif numel(subfields)==4 % this is here for just in case
                            U.inputValues{end+1}=trigs.(subfields{2}).(subfields{3}).(subfields{4});
                        elseif numel(subfields)==5 % this is here for just in case in case
                            U.inputValues{end+1}=trigs.(subfields{2}).(subfields{3}).(subfields{4}).(subfields{5});
                        else
                            error(['I did not design more than 3 levels in trigs struct. the code will have to be trivially expanded to include up to at least ' num2str(numel(subfields) ' (!) levels ...']);
                        end
                    else % it must be stim
                        if numel(subfields)==2 % this is the expected number
                            U.inputValues{end+1}=stims.(subfields{2});
                        elseif numel(subfields)==3 % this is here for just in case
                            U.inputValues{end+1}=stims.(subfields{2}).(subfields{3});
                        elseif numel(subfields)==4 % this is here for just in case in case
                            U.inputValues{end+1}=stims.(subfields{2}).(subfields{3}).(subfields{4});
                        else
                            error(['I did not design more than 2 levels in the stimuli subfields. the code will have to be trivially expanded to include up to at least ' num2str(numel(subfields) ' (!) levels ...']);
                        end
                    end
                catch me
                    disp(['[dpxAbstractConduit] Problem resolving conduit input field ''' U.inFields{i} '''. Does it exist?']);
                    rethrow(me);
                end
            end
        end
    end
    function condition=output(U,condition)
        if U.firstTrial
            U.firstTrial=false;
            return;
        end
        outputValues=myFunction(U.inputValues);
        if numel(outputValues)~=numel(U.outFields)
            error('Output of myFunction does not match number of outFields!');
        end
        
    end
end
methods (Access=protected)
    % overwrite myFunction in your conduit class to do something useful
    function varargout=myFunction(U,varargin), end
end
methods
    function set.inFields(U,value)
        if isempty(value)
            return;
            if ischar(value)
                value={value};
            end
            [ok,str]=dpxIsCellArrayOfStrings(value);
            if ~ok, error(['inFields should be a string or ' str ' containing fields as they appear in the DPXD-struct of this experiment']); end
            U.inFields=unique(value);
        end
        function set.outFields(U,value)
            if ischar(value)
                value={value};
            end
            [ok,str]=dpxIsCellArrayOfStrings(value);
            if ~ok, error(['outFields should be a string or ' str ' containing fields as they appear in the DPXD-struct of this experiment']); end
            U.outFields=unique(value);
        end
    end
end


