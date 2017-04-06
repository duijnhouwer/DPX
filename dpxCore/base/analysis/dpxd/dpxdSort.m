function DPXD=dpxdSort(DPXD,fieldName,mode)
    
    %dpxdSort	Sort the columns of a DPXD 
    %
    % D = dpxdSort(D,fieldName), where D is a DPXD and fieldName a string
    % corresponding to a field in D, sorts the columns of D along the
    % second dimension of D.fieldName. This dimension is the column
    % dimension of the DPXD. Because sorting of MxN or higher dimensional
    % matrix data does not make sense in the context of DPXD data, this
    % function only allows sorting of 1xN array data.
    %
    % dpxdSort(DPXD,fieldName,MODE) Optional parameter MODE selects the
    % direction of the sort
    %   'ascend' results in ascending order (default)
    %   'descend' results in descending order
    % 
    % See also dpxdSubset, dpxdDummy, sort

    if ~exist('DPXD','var') || ~dpxdIs(DPXD)
        [~,why]=dpxdIs(DPXD);
        error('a:b',['First argument must be a DPXD\n(' why ')']);
    end
    if ~exist('fieldName','var') || ~ischar(fieldName) || ~any(strcmp(fieldName,fieldnames(DPXD)))
        error('Second argument must be a fieldname of DPXD');
    end
    if ~exist('mode','var') || isempty(mode)
        mode='ascend';
    elseif exist('mode','var') && ~any(strcmpi(mode,{'ascend','descend'}))
        error('Third argument (mode) must be one of: ''ascend'', ''descend''.');
    end

    nargoutchk(0,1);
    sz=size(DPXD.(fieldName));
    if sz(2)~=DPXD.N || ~all(sz([1 3:numel(sz)])==1)
        error(['The data in field ''' fieldName ''' is not a 1xN vector']);
    end
    [~,idx]=sort(DPXD.(fieldName),2,mode);
    DPXD=dpxdSubset(DPXD,idx);

end
