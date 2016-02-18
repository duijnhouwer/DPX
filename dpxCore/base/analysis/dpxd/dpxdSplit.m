function [C,N]=dpxdSplit(DPXD,fNames)
    
    % [C,N]=dpxdSplit(DXPD,fNames)
    %
    % Split a DXPD according to the list of fieldnames in 'fNames'. fNames can
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
    nargoutchk(0,2);
    C=cell(0);
    N=[];
    if iscell(fNames) && numel(fNames)==1
        fNames=fNames{1};
    end
    if ischar(fNames)
        % fNames is a single fieldname string
        if ~isfield(DPXD,fNames)
             error(['Can''t split along field ''' fNames ''' because no field with that name exists']);
        end
        sz=size(DPXD.(fNames));
        if numel(sz)>2 || sz(1)>1
            szStr=sprintf('%dx',sz); szStr(end)=[];
            error(['Can''t split along field ''' fNames ''' because it''s not a row vector (size: ' szStr ').']);
        end    
        try
            U=unique(DPXD.(fNames));
        catch
            error(['Can''t split along field ''' fNames ''' because ''unique'' can''t be called on it.']);
        end
        for i=1:numel(U)
            C{i}=dpxdSubset(DPXD,subFuncEquals(DPXD.(fNames),U(i)));
            N(i)=C{i}.N; %#ok<AGROW>
        end
    elseif iscell(fNames)
        % fNames is a cell array of one or more fieldname strings
        if ~all(cellfun(@ischar,fNames))
            error('All elements in the fieldnames cell-array must be strings.');
        end
        C{1}=DPXD;
        for i=1:numel(fNames)
            TMP=cell(1,numel(C));
            for ci=1:numel(C)
                TMP{ci}=dpxdSplit(C{ci},fNames{i}); % recursion
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
        error('fNames should be a fieldname (string), or a one-dimensional cell array of fieldnames (strings).');
    end
    
    function I=subFuncEquals(arr,thisval)
        % Index by numerical, logical, and char arrays, or by cell-arrays of strings
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
