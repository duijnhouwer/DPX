function [F,R]=dpxdSubset(DPXD,indices)
    
    % [F,R]=dpxdSubset(DPXD,indices)
    %
    % Of dpxd DPXD, return the subset F corresponding to DPXD at the
    % given indices. Note that when indices is [], F will not be
    % empty but a complete dpxd with the same, but empty, fields as DPXD
    % and F.N=0.
    %
    % R: Optional second output arguments receives remainder (2016-01-31)
    % 
    % EXAMPLE:
    %      F=dpxdSubset(D,strcmpi(D.subject,'MO'));
    %
    % See also: dpxdSplit, dpxdMerge, dpxdIs, dpxdMergeGUI ...
 
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('DPXD', @dpxdIs);
    p.addRequired('indices',@(x)isnumeric(x) | islogical(x));
    p.parse(DPXD,indices);
    
    nargoutchk(1,2);

    if all(dpxIsWholeNumber(indices))
        if numel(unique(indices))~=numel(indices)
            % using subset to repeat data, this is kind of side effect that
            % dpxdSubset can be used for. 666 document better, in a rush now ...
            if nargout==2
                error('Can''t use remainder output (2nd output argument) when using dpxdSubset to expand the DPXD by repeating data');
            end
            % keep integer indices
        else
            % convert to logical
            if any(indices>DPXD.N)
                error('Requested integer indices out of range');
            end
            tmp=false(1,DPXD.N);
            tmp(indices)=true;
            indices=tmp;
            clear tmp;
        end
    elseif ~all(islogical(indices))
        if numel(indices)~=DPXD.N
            error('Requested logical indices out of range');
        end
        error('Indices should be whole numbers or logical');
        % keep logical indices
    end

    % Remove the special N field. Will be put back (with an updated value) at the end of this
    % function
    DPXD=rmfield(DPXD,'N');
    if nargout==1
        % Select the subset of DPXD, store in F
        fn=fieldnames(DPXD);
        for i=1:length(fn)
            F.(fn{i})=DPXD.(fn{i})(indices);
        end
        if islogical(indices)
            F.N=sum(indices);
        else
            F.N=numel(indices);
        end
    elseif nargout==2
         % Select the subset of DPXD, store in F, store the remainder in R
        fn=fieldnames(DPXD);
        for i=1:length(fn)
            F.(fn{i})=DPXD.(fn{i})(indices);
            R.(fn{i})=DPXD.(fn{i})(~indices);
        end
        F.N=sum(indices);
        R.N=sum(~indices);
    end
end
