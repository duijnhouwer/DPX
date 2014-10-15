function outstructs=dpxTblSplit(r,params)
    
    % outstructs=dpxTblSplit(r,params)
    % Split the dpxTbl according to the list of fieldnames in cell array
    % params. Params can be a cell of multiple fieldnames, or a string
    % containing one fieldname. The sub-dpxTbls are returned in a cell array.
    % Jacob 2014-06-02
    
    if nargin~=2
        error('Needs two inputs: a dpxTbl-struct and a fieldname (string) accross which to split the struct. Fieldname can also be a cell array of fieldname-strings.');
    end
    outstructs=cell(0);
    if iscell(params) && numel(params)==1
        params=params{1};
    end
    if ischar(params)
        % params is a single fieldname string
        for i=1:dpxTblLevels(r,params);
            outstructs{i}=dpxTblSelect(r,params,'increasing',i);
        end
    elseif iscell(params)
        % params is a cell array of one or more fieldname strings
        nParams=length(params);
        n=zeros(nParams-1,1);
        level=1;
        rsub{level}=r;
        while 1
            n(level)=n(level)+1;
            rsub{level+1}=dpxTblSelect(rsub{level},params{level},'increasing',n(level));
            if ~rsub{level+1}.N==0
                level=level+1;
                if level==nParams % highest level reached, split on final param (fieldname) and store results for output
                    for i=1:dpxTblLevels(rsub{level},params{level});
                        thisout=dpxTblSelect(rsub{level},params{level},'increasing',i);
                        outstructs{end+1}=thisout; %#ok<AGROW>
                    end
                    level=level-1;
                end
            else
                n(level)=0;
                level=level-1;
                if level<=0
                    break % the while loop
                end
            end
        end
    else
        error('Params should be a fieldname (string), or a one-dimensional cell array of fieldnames (strings).');
    end
end