function F=dpxdSubset(R,indices)

% function F=dpxdSubset(R,IDXS) 
% Of a DPXD R, return the subset F corresponding to R at the
% given indices. Note that if indices is [], F will not be
% empty but a complete DPXD with the same, but empty, fields as R
% and F.N=0.

%%% Handle varargin list%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('R', @dpxdIs);
p.addRequired('indices',@(x)isnumeric(x) | islogical(x));
p.parse(R,indices);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if all(islogical(indices))
    % this function works with whole number indexing, convert logical indexing to natural
    % indexing now. TODO: might be better to do it the other way around because logical
    % indexing is faster...
    indices=find(indices);
end
oldn=R.N;
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
R=rmfield(R,'N');
% Select the subset of r, store in f
fn=fieldnames(R);
for i=1:length(fn)
    F.(fn{i})=R.(fn{i})(indices);
end
% Put the special N field back in place
F.N=newn;
