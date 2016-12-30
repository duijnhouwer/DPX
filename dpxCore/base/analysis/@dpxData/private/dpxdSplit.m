function [C,N]=dpxdSplit(DPXD,params)
    
    % [C,N]=dpxdSplit(DXPD,params)
    %
    % Split a DXPD according to the list of fieldnames in 'params'. Params can
    % be a string containing one fieldname, or a cell of multiple fieldnames.
    % The sub-dpxds are returned in cell array C.
    %
    % Optional second output argument N is an array of number of elemements in
    % the corresponding output cell-array of sub-DPXD's
    %
    % Jacob 2014-06-02; major update 2015-09-17
    
    if nargin~=2
        error('Needs two inputs: a DPXD-struct and a fieldname (string) accross which to split the struct. Fieldname can also be a cell array of fieldname-strings.');
    end
    if ~dpxdIs(DPXD,'verbosity',1)
        error('First argument should be a DPXD-struct');
    end
    C=cell(0);
    N=[];
    if iscell(params) && numel(params)==1
        params=params{1};
    end
    if ischar(params)
        % params is a single fieldname string
        try
            U=unique(DPXD.(params));
        catch
            error(['Can''t split along field ' params ' because ''unique'' can''t be called on it. See also: unique']);
        end
        for i=1:numel(U)
            C{i}=dpxdSubset(DPXD,subFuncEquals(DPXD.(params),U(i)));
            N(i)=C{i}.N;
        end
    elseif iscell(params)
        % params is a cell array of one or more fieldname strings
        C{1}=DPXD;
        for i=1:numel(params)
            TMP={};
            for ci=1:numel(C)
                TMP{end+1}=dpxdSplit(C{ci},params{i}); %#ok<AGROW>
            end
            C=[TMP{:}];
        end
        if nargout>1
            N=nans(size(C));
            for i=1:numel(C)
                N(i)=C{i}.N;
            end
        end
    else
        error('Params should be a fieldname (string), or a one-dimensional cell array of fieldnames (strings).');
    end
    
    function I=subFuncEquals(arr,thisval)
        
        if isnumeric(thisval) || islogical(thisval)
            I=arr==thisval; % e.g. [123 123]==123;
        elseif ischar(thisval) && ischar(arr)
            I=arr==thisval; % e.g. 'abcabc'=='a'
        elseif iscell(arr) && all(cellfun(@ischar,arr))
            I=strcmp(arr,thisval); % e.g. {'abd','abc','abc'}=='abc'
        else
            error('dpxdSplit can only split by numerical, logical, and char arrays, or by cell-arrays of strings');
        end
    end
end