function F=dpxdSubset(DXPD,indices)
    
    % F=dpxdSubset(D,IDXS
    %
    % Of a DPXD D, return the subset F corresponding to D at the
    % given indices. Note that if indices is [], F will not be
    % empty but a complete DPXD with the same, but empty, fields as D
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
    p.parse(DXPD,indices);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if all(islogical(indices))
        % this function works with whole number indexing, convert logical indexing to natural
        % indexing now. TODO: might be better to do it the other way around because logical
        % indexing is faster...
        indices=find(indices);
    end
    oldn=DXPD.N;
    if all(islogical(indices))
        newn=sum(indices);
    elseif all(dpxIsWholeNumber(indices))
        newn=numel(indices);
    else
        error('Indices should be whole numbers of logical');
    end
    if newn>oldn
        error(['Number of requested indices (' num2str(newn) ') cannot be larger than the available values in DPXD (' num2str(oldn) ').']);
    end
    % Remove the special N field. Will be put back (with an updated value) at the end of this
    % function
    DXPD=rmfield(DXPD,'N');
    % Select the subset of DXPD, store in F
    fn=fieldnames(DXPD);
    for i=1:length(fn)
        F.(fn{i})=DXPD.(fn{i})(indices);
    end
    % Put the special N field back in place
    F.N=newn;
end
