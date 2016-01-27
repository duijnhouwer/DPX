function M=dpxdMerge(T,varargin)
    
    % Merge the DPXDs in cell array T into one DPXD M. All DPXDs in T
    % must be compatible, i.e., have the same fields.
    % 2012-10-12: T can also be a regular array of DPXDs, does not need
    % to be a cell (only works for DPXD-structs with identical fields)
    % 2016-01-18: DPXDs that share NO fields but have the same number of N are
    % now spliced
    %
    % EXAMPLE:
    %   a1=struct('a',1,'aa',2,'N',1)
    %   a2=struct('a',[1 1 1],'aa',[2 2 2],'N',3)
    %   M=dpxdMerge({a1,a2});
    %   M =
    %        a: [1 1 1 1]
    %       aa: [2 2 2 2]
    %        N: 4
    %
    %   a1=struct('a',1,'aa',2,'N',1)
    %   a2=struct('a',[1 1 1],'d',[2 2 2],'N',3)
    %   M=dpxdMerge({a1,a2},'intersectwarn')
    %   Warning: Ignoring non-intersecting fields of DPXD-input array element #2.
    %   M =
    %        a: [1 1 1 1]
    %        N: 4
    %
    %   % Merge entirely dissimilar parts of DPXDs. The DPXDs need
    %   % the same Ns for this to be possible. There is no concatenation of
    %   % values in this use, only of fieldnames.
    %   a=struct('a',1,'aa',2,'c',0,'N',1)
    %   b=struct('b',1,'bb',2,'c',1,'N',1)
    %   M=dpxdMerge({a,b},'mode','setxor') 
    %   M =
    %      a: 1
    %      aa: 2
    %      b: 1
    %      bb: 2
    %      N: 1
    %
    % See also: dpxdLoad, dpxdSplit, dpxdSubset

    
    narginchk(1,3);
    p=inputParser;
    p.addOptional('mode','intersect',@(x)any(strcmpi(x,{'concat','intersect','intersectwarn','setxor'})));
    p.parse(varargin{:});
    
    if isempty(T)
        M=T;
        return;
    elseif ~iscell(T) && numel(T)==1
        M=T;
        return;
    elseif iscell(T) && numel(T)==1
        M=T{1};
        return;
    elseif ~iscell(T) && numel(T)>1
        T=num2cell(T); % convert to cell array (num is a minsnomer, works for structs too).
    end
    
    bad=[];
    for f=1:length(T)
        if ~dpxdIs(T{f}, 'verbosity', 1)
            bad(end+1)=f;
        end
    end
    if ~isempty(bad)
        error(['Elements ' num2str(bad) ' of input array are not DPXDs.']);
    end
    
    if strcmpi(p.Results.mode,'intersect')
        M=doIntersection(T,'silentskip');
    elseif strcmpi(p.Results.mode,'intersectWarn')
        M=doIntersection(T,'warnskip');
    elseif strcmpi(p.Results.mode,'concat')
        M=doIntersection(T,'error');
    elseif strcmpi(p.Results.mode,'setxor')
        M=doSetXOr(T);
    else
        error(['Unknown setfunc ''' p.Results.setfunc '''.']);
    end
end


function M=doIntersection(T,missingfields)
    F=fieldnames(T{1});
    for t=1:numel(T)
        newfields=fieldnames(T{t});
        E=intersect(F,newfields,'stable');
        if numel(F)~=numel(E)
            if strcmpi(missingfields,'error')
                error(['DPXD number' num2str(t) '''s fields are inconsistent with earlier elements.']);
            elseif strcmpi(missingfields,'warnskip')
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
            else
                if iscell(thistab.(thisname))
                    try
                        M.(thisname)=[M.(thisname) thistab.(thisname)];
                    catch me
                        sca;
                        disp('An error occured in dpxdMerge, please contact Jacob with the following information:');
                        disp('- - -   C U T   H E R E   - - - ');
                        disp(['Date = ' datestr(now)]);
                        SystemInfo = dpxSystemInfo %#ok<NOPRT,NASGU>
                        disp(['thisname = ' thisname]);
                        disp(['error message = ' me.message]);
                        disp(' - - -   C U T   H E R E   - - - ');
                        disp('Cut the above and paste in an email to : j.duijnhouwer@gmail.com');
                        disp('Please also provide a copy of the experiment file you were running.');
                        disp('Sorry for the inconvenience!');
                        % keyboard%
                        error(' ');
                    end;
                elseif isnumeric(thistab.(thisname)) || islogical(thistab.(thisname)) || isstruct(thistab.(thisname)) || ischar(thistab.(thisname))
                    M.(thisname)=[ M.(thisname) thistab.(thisname) ];
                    % HINT: if you want to have dissimilar structs in a field per
                    % datum in the DPXD, use a cell-array instead of a
                    % struct-array
                else
                    error('DPXD fields should be of type numeric, logical, char, struct, cell');
                end
            end
        end
    end
end

function  M=doSetXOr(T)
    if std(cellfun(@(x)getfield(x,'N'),T))>0 %#ok<GFLD>
        error('Mode ''setxor'' only works on DPXDs with identical Ns');
    end
    N=T{1}.N;
    fields=fieldnames(T{1});
    for i=2:numel(T)
        fields=setxor(fields,fieldnames(T{i}));
    end
    M=struct;
    for i=1:numel(T)
        for f=1:numel(fields)
            if isfield(T{i},fields{f})
                M.(fields{f})=T{i}.(fields{f});
            end
        end
    end
    M.N=N;
    if ~dpxdIs(M,'verbosity',1)
        error('Not a DPXD, must be a bug in doSetXOr');
    end
end
