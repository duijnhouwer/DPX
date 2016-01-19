function F=dpxdSubset(DPXD,indices)
    
    % F=dpxdSubset(DPXD,indices)
    %
    % Of dpxd DPXD, return the subset F corresponding to DPXD at the
    % given indices. Note that when indices is [], F will not be
    % empty but a complete dpxd with the same, but empty, fields as DPXD
    % and F.N=0.
    %
    % EXAMPLE:
    %      F=dpxdSubset(D,strcmpi(D.subject,'MO'));
    %
    % See also: dpxdSplit, dpxdMerge, dpxdIs, dpxdMergeGUI ...
 
    %%% Handle varargin list%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('R', @dpxdIs);
    p.addRequired('indices',@(x)isnumeric(x) | islogical(x));
    p.parse(DPXD,indices);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if all(islogical(indices))
        % this function works with whole number indexing, convert logical indexing to natural
        % indexing now. TODO: might be better to do it the other way around because logical
        % indexing is faster...
        indices=find(indices);
    elseif ~all(dpxIsWholeNumber(indices))
        error('Indices should be whole numbers or logical');
    end
    if any(indices>DPXD.N)
        error('Requested indices out of range');
    end
    % Remove the special N field. Will be put back (with an updated value) at the end of this
    % function
    DPXD=rmfield(DPXD,'N');
    % Select the subset of DPXD, store in F
    fn=fieldnames(DPXD);
    for i=1:length(fn)
        F.(fn{i})=DPXD.(fn{i})(indices);
    end
    % Put the special N field back in place
    F.N=numel(indices);
end
