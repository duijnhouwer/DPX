function M=dpxdMerge(T,varargin)

% Merge the DPXDs in cell array T into one DPXD M. All DPXDs in T
% must be compatible, i.e., have the same fields.
% 2012-10-12: T can also be a regular array of DPXDs, does not need
% to be a cell.

p=inputParser;
p.addOptional('missingfields','warnskip',@(x)any(strcmpi(x,{'warnskip','silentskip','error'})));
p.parse(varargin{:});

if ~iscell(T) && numel(T)==1
    M=T;
    return;
end
if ~iscell(T) && numel(T)>1
    TT=cell(1,numel(T));
    for f=1:numel(T)
        TT{f}=T(f);
    end
    T=TT;
    clear('TT');
end

bad=[];
for f=1:length(T)
    if ~dpxdIs(T{f}, 'verbosity', 1)
        bad(end+1)=f;
    end
end
if ~isempty(bad)
    error(['Elements ' num2str(bad) ' of input cell array are not DPXDs.']);
end


F=fieldnames(T{1});
for t=1:numel(T)
    newfields=fieldnames(T{t});
    E=intersect(F,newfields,'stable');
    if numel(F)~=numel(E)
        if strcmpi(p.Results.missingfields,'error')
            error(['In the input array DPXDs number ' num2str(t) ' was inconsistent with earlier elements.']);
        elseif strcmpi(p.Results.missingfields,'warnskip')
            warning(['Ignoring non-intersecting fields of DPXD-input array element #' num2str(t) '.']);
        end
    end
    F=E;
end

% Copy the output fields of the first DPXD to the output M
for f=1:numel(F)
    M.(F{f})=T{1}.(F{f});
end
% Merge the remaining DPXDs in the input array with the output M
for t=2:numel(T)
    thistab=T{t};
    for f=1:numel(F)
        thisname=F{f};
        if strcmp(thisname,'N')
            M.N=M.N+thistab.N;
        elseif strcmp(thisname,'Cyclopean')
            % not sure this works anymore .... jd 2014-06-13
            nCyclopeansCurrent=numel(M.Cyclopean.data);
            M.Cyclopean.pointers=[ M.Cyclopean.pointers(:)' T{t}.Cyclopean.pointers(:)'+nCyclopeansCurrent ];
            for cf=1:numel(T{t}.Cyclopean.data)
                M.Cyclopean.data{end+1}=T{t}.Cyclopean.data{cf};
            end
        else
            if iscell(thistab.(thisname))
                try
                    M.(thisname)={ M.(thisname){:} thistab.(thisname){:} }; %#ok<CCAT> tested this CCAT warning and current method is actually faster!
                catch me
                    caf;
                    disp('An error occured in dpxdMerge, please contact Jacob with the following information:');
                    disp('- - -   C U T   H E R E   - - - ');
                    disp(['Date = ' datestr(now)]);
                    disp(['dpxVersion = ' num2str(dpxVersion('checkonline',false,'offerupdate',false))]);
                    disp(['thisname = ' thisname]);
                    disp(['error message = ' me.message]);
                    disp(' - - -   C U T   H E R E   - - - ');
                    disp('Please also provide a copy of the experiment file you were running.');
                    disp('Sorry for the inconvenience!');
                    disp('Jacob: j.duijnhouwer@gmail.com');
                    error(' ');
                end;
            elseif isnumeric(thistab.(thisname)) || islogical(thistab.(thisname))
                M.(thisname)=[ M.(thisname) thistab.(thisname) ];
            elseif isstruct(thistab.(thisname))
                % if you want to have dissimilar structs in a field per
                % datum in the dpxd, make it a cell, not a
                % struct-array
                M.(thisname)=[ M.(thisname) thistab.(thisname) ];
            else
                error('dpxd field should be cell or numeric.');
            end
        end
    end
end
