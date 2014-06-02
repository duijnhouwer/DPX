function M=dpxTblMerge(T)

% Merge the dpxTbls in cell array T into one dpxTbl M. All TblStructs in T
% must be compatible, i.e., have the same fields.
% 2012-10-12: T can also be a regular array of dpxTbls, does not need
% to be a cell.

if ~iscell(T) && numel(T)==1
    M=T;
    return;
end
if ~iscell(T) && numel(T)>1
    % convert to cell array (other way around, if cell convert to regular
    % array makes more sense, but the code below had already been written
    % to deal with cell arrays
    TT=cell(1,numel(T));
    for i=1:numel(T)
        TT{i}=T(i);
    end
    T=TT;
    clear('TT');
end

bad=[];
for i=1:length(T)
    if ~dpxTblIs(T{i}, 'verbosity', 1)
        bad(end+1)=i;
    end
end
if ~isempty(bad)
    error(['Elements ' num2str(bad) ' of input cell array are not dpxTbls.']);
end

M=T{1};
F=fieldnames(T{1});
for t=2:length(T)
    thistab=T{t};
    for f=1:length(F)
        thisname=F{f};
        if strcmp(thisname,'N')
            M.N=M.N+thistab.N;
        elseif strcmp(thisname,'Cyclopean')
            nCyclopeansCurrent=numel(M.Cyclopean.data);
            M.Cyclopean.pointers=[ M.Cyclopean.pointers(:)' T{t}.Cyclopean.pointers(:)'+nCyclopeansCurrent ];
            for i=1:numel(T{t}.Cyclopean.data)
                M.Cyclopean.data{end+1}=T{t}.Cyclopean.data{i};
            end
        else
            if iscell(thistab.(thisname))
                M.(thisname)={ M.(thisname){:} thistab.(thisname){:} };
            elseif isnumeric(thistab.(thisname)) || islogical(thistab.(thisname))
                M.(thisname)=[ M.(thisname) thistab.(thisname) ];
            elseif isstruct(thistab.(thisname))
                % if you want to have dissimilar structs in a field per
                % datum in the dpxTbl, make it a cell, not a
                % struct-array
                M.(thisname)=[ M.(thisname) thistab.(thisname) ];
            else
                error('dpxTbl field should be cell or numeric.');
            end
        end
    end
end
