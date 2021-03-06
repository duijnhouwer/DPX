function [F,R]=dpxdSubset(DPXD,indices)
    
    %dpxdSubset	Return a data-subset of a DPXD
    %
    % F = dpxdSubset(D,IDX) return the subset F corresponding to the DPXD D
    % at the given indices. Note that when indices is [], F will not be
    % empty but a complete dpxd with the same, but empty, fields as D and
    % F.N=0.
    %
    % [F,R] = dpxdSubset(...) also returns the remainder (2016-01-31)
    % 
    % EXAMPLES:
    %   D=dpxdDummy;
    %
    %   % Subset D according to cell of strings D.s that reads 'Hello'
    %   F=dpxdSubset(D,strcmpi(D.s,'Hello'));
    %
    %   % Same, but store the remainder too
    %   [F,S]=dpxdSubset(D,strcmpi(D.s,'Hello'));
    %
    %   % Sort D along field 'i'
    %   [~,idx] = sort(D.i);
    %   D = dpxdSubset(D,idx);
    %
    %   % Duplicate data
    %   D = dpxdDummy(3)
    %   D = dpxdSubset(D,[1 1 2 2 3 3])
    %   
    %
    % See also: dpxdSplit, dpxdMerge, dpxdIs, dpxdMergeGUI, dpxdDummy ...
 
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('DPXD', @dpxdIs);
    p.addRequired('indices',@(x)isnumeric(x) | islogical(x));
    p.parse(DPXD,indices);
    
    nargoutchk(0,2);

    if all(dpxIsWholeNumber(indices))
        if any(indices>DPXD.N)
            error('Requested integer indices out of range');
        end
        if numel(unique(indices))<numel(indices)
            % using subset to repeat data, this is kind of side a effect that
            % dpxdSubset can be used for. TODO 666 document better, in a rush now ...
            if nargout==2
                error('Can''t use remainder output (2nd output argument) when using dpxdSubset to expand the DPXD by repeating data');
            end
            % keep integer indices
        else
            if numel(unique(indices))==DPXD.N && any(diff(indices)~=1)
                % all indices are selected, might be used to sort the DPXD,
                % so don't convert to logicals. Unless monotonic increasing
                % with steps of one (any(diff(indices)~=1)
            else
                % convert subset to logical for speed
                tmp=false(1,DPXD.N);
                tmp(indices)=true;
                indices=tmp;
                clear tmp;
            end
        end
    elseif all(islogical(indices))
        if numel(indices)~=DPXD.N
            error('Requested logical indices out of range');
        end
        % keep logical indices
    else
        error('Indices should be whole numbers or logical');
    end

    % Remove the special N field. Will be put back (with an updated value) at the end of this
    % function
    DPXD=rmfield(DPXD,'N');
    if nargout==1 || nargout==0
        % Select the subset of DPXD, store in F
        fn=fieldnames(DPXD); % FieldNames
        for i=1:length(fn)
            if ~issparse(DPXD.(fn{i}))
                F.(fn{i})=DPXD.(fn{i})(:,indices,:, :,:,:, :,:,:); % Max 9 dimensions
            else
                F.(fn{i})=DPXD.(fn{i})(:,indices); % sparse only for 2D
            end
        end
        % Jaoob 20160329: I tried to optimize the above by replacing the
        % forloop with the following, but that turned out to be marginally
        % SLOWER, so keep the for loop (tested with Matlab 2015B). Maybe if
        % you'd get beyond a certain number of fieldnames the cellfun would
        % outperform the for loop, could test on that and choose the best
        % method depending on numel(fn) ... TODO 666
        % dv=struct2cell(DPXD); % DataValues
        % dv=cellfun(@(x)x(:,indices,:, :,:,:, :,:,:),dv,'UniformOutput',false);
        % F=cell2struct(dv,fn);
        if islogical(indices)
            F.N=sum(indices);
        else
            F.N=numel(indices);
        end
    elseif nargout==2
        % Select the subset of DPXD, store in F, store the remainder in R
        fn=fieldnames(DPXD);
        for i=1:length(fn)
            if ~issparse(DPXD.(fn{i}))
                F.(fn{i})=DPXD.(fn{i})(:,indices,:, :,:,:, :,:,:); % Max 9 dimensions
                R.(fn{i})=DPXD.(fn{i})(:,~indices,:, :,:,:, :,:,:); % Max 9 dimensions
            else
                F.(fn{i})=DPXD.(fn{i})(:,indices); % sparse only for 2D
                R.(fn{i})=DPXD.(fn{i})(:,~indices); % sparse only for 2D
            end
        end
        F.N=sum(indices);
        R.N=sum(~indices);
    end
end
