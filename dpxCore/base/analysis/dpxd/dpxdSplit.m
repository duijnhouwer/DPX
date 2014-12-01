function [outstructs,N]=dpxdSplit(dpxd,params)
    
    % outstructs=dpxdSplit(r,params)
    % Split the dpxd according to the list of fieldnames in cell array
    % params. Params can be a cell of multiple fieldnames, or a string
    % containing one fieldname. The sub-dpxds are returned in a cell array.
    % Optional second output argument N is an array of number of elemements
    % in the corresponding output cell-array of sub-DPXD's 
    % Jacob 2014-06-02
    
    if nargin~=2
        error('Needs two inputs: a dpxd-struct and a fieldname (string) accross which to split the struct. Fieldname can also be a cell array of fieldname-strings.');
    end
    outstructs=cell(0);
    N=[];
    if iscell(params) && numel(params)==1
        params=params{1};
    end
    if ischar(params)
        % params is a single fieldname string
        for i=1:dpxdLevels(dpxd,params);
            outstructs{i}=dpxdSelect(dpxd,params,'increasing',i);
            N(i)=outstructs{i}.N;
        end
    elseif iscell(params)
        % params is a cell array of one or more fieldname strings
        nParams=length(params);
        n=zeros(nParams-1,1);
        level=1;
        rsub{level}=dpxd;
        while 1
            n(level)=n(level)+1;
            rsub{level+1}=dpxdSelect(rsub{level},params{level},'increasing',n(level));
            if ~rsub{level+1}.N==0
                level=level+1;
                if level==nParams % highest level reached, split on final param (fieldname) and store results for output
                    for i=1:dpxdLevels(rsub{level},params{level});
                        thisout=dpxdSelect(rsub{level},params{level},'increasing',i);
                        outstructs{end+1}=thisout; %#ok<AGROW>
                        N(end+1)=thisout.N;
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