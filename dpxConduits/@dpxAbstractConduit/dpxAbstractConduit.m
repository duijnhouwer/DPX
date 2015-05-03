classdef (Abstract) dpxAbstractConduit < hgsetget
    
    properties (Access=public)
        name;
        inFields;
        outFields;
    end
    properties (Access=protected)
        firstTrial;
        inputValues;
    end
    methods (Access=public)
        function U=dpxAbstractConduit
            U.name='dpxAbstractConduit';
            U.inFields={}; % cell array of parameter names as they appear in the DPXD struct
            U.outFields={}; % cell array of parameter names as they appear in the DPXD struct
            U.inputValues={};
            U.firstTrial=true;
        end
        function toNextTrail(U,stims,trialInfo)
            U.inputValues={};
            for i=1:numel(U.inFields)
                try
                    subfields=regexp(U.inFields{i},'_','split');
                    if strcmp(subfields{1},'resp')
                        if numel(subfields)==2 % this is possible, but unlikely
                            U.inputValues{end+1}=trialInfo.resp.(subfields{2});
                        elseif numel(subfields)==3 % this is the expected number
                            U.inputValues{end+1}=trialInfo.resp.(subfields{2}).(subfields{3});
                        elseif numel(subfields)==4 % this is here for just in case
                            U.inputValues{end+1}=trialInfo.resp.(subfields{2}).(subfields{3}).(subfields{4});
                        elseif numel(subfields)==5 % this is here for just in case in case
                            U.inputValues{end+1}=trialInfo.resp.(subfields{2}).(subfields{3}).(subfields{4}).(subfields{5});
                        else
                            error(['I did not design more than 3 levels in resp struct. the code will have to be trivially expanded to include up to at least ' num2str(numel(subfields)) ' levels ...']);
                        end
                    elseif strcmp(subfields{1},'trialtrigger')
                        error('trialtriggers not implemented in conduit mechanism yet');
                    else % it must be stim
                        for s=1:numel(stims)
                            if strcmpi(stims{s}.name,subfields{1})
                                if numel(subfields)==2 % this is the expected number
                                    U.inputValues{end+1}=stims{s}.(subfields{2});
                                elseif numel(subfields)==3
                                    U.inputValues{end+1}=stims{s}.(subfields{2}).(subfields{3});
                                elseif numel(subfields)==4
                                    U.inputValues{end+1}=stims{s}.(subfields{2}).(subfields{3}).(subfields{4});
                                elseif numel(subfields)==5
                                    U.inputValues{end+1}=stims{s}.(subfields{2}).(subfields{3}).(subfields{4}).(subfields{5});
                                else
                                    error('did not expect so many subfields, DPX need adjustment to allow more subfields');
                                end
                            end
                        end
                    end
                catch me
                    disp(['[dpxAbstractConduit] Problem occured resolving conduit input field ''' U.inFields{i} '''. Does it exist?']);
                    rethrow(me);
                end
            end
        end
        function condition=fromPreviousTrial(U,condition)
            if U.firstTrial
                U.firstTrial=false;
                return;
            end
            outputValues=U.myFunction(U.inputValues{:});
            if ~iscell(outputValues)
                outputValues={outputValues};
            end
            % apply the new values to the fields of the next condition
            if numel(outputValues)~=numel(U.outFields)
                error('Output of myFunction does not match number of outFields!');
            end
            for i=1:numel(U.outFields)
                if isempty(outputValues{i})
                    continue; % empty output means leave this field for new condition untouced
                end
                subfields=regexp(U.outFields{i},'_','split');
                for s=1:numel(condition.stims)
                    if strcmpi(condition.stims{s}.name,subfields{1})
                        break;
                    end
                end
                % s now is the number of the stim that needs update
                if numel(subfields)==2 % this is the expected number
                    condition.stims{s}.(subfields{2})=outputValues{i};
                elseif numel(subfields)==3
                    condition.stims{s}.(subfields{2}).(subfields{3})=outputValues{i};
                elseif numel(subfields)==4
                    condition.stims{s}.(subfields{2}).(subfields{3}).(subfields{4})=outputValues{i};
                elseif numel(subfields)==5
                    condition.stims{s}.(subfields{2}).(subfields{3}).(subfields{4}).(subfields{5})=outputValues{i};
                else
                    error('did not expect so many subfields, DPX need adjustment to allow more subfields');
                end
            end
        end
    end
    methods (Access=protected)
        function varargout=myFunction(U,varargin)
            varargout={};
            warning('redefine myFunction in your conduit class to do something useful');
        end
    end
    methods
        function set.inFields(U,value)
            if isempty(value)
                return;
            else
                if ischar(value)
                    value={value}; % convert to cell is argument was string
                end
                [ok,str]=dpxIsCellArrayOfStrings(value);
                if ~ok, error(['inFields should be a string or ' str ' containing fields as they appear in the DPXD-struct of this experiment']); end
                U.inFields=unique(value);
            end
        end
        function set.outFields(U,value)
            if ischar(value)
                value={value}; % convert to cell is argument was string
            end
            [ok,str]=dpxIsCellArrayOfStrings(value);
            if ~ok, error(['outFields should be a string or ' str ' containing fields as they appear in the DPXD-struct of this experiment']); end
            U.outFields=unique(value);
        end
    end
end

