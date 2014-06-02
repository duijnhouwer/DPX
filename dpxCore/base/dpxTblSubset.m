function f=jdTblStructSubset(r,indices)

% function F=jdTblStructSelectIndices(R,IDXS) 
% Of a pdxTbl R, return the subset F corresponding to R at the
% given indices IDXS. Note that if IDXS is [], F will not be
% empty but a complete pdxTbl with the same, but empty, fields as R
% and F.N=0.

%%% Handle varargin list%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('r', @jdTblStructIs);
p.addRequired('indices',@(x)isnumeric(x) | islogical(x));
p.parse(r,indices);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if all(islogical(indices))
    % this function works with whole number indexing, convert logical indexing to natural indexing now,
    % todo: would be better to do it the other way around becayuse logicla indexing is faster...
    indices=find(indices);
end


oldn=r.N;
if all(islogical(indices)), newn=sum(indices);
elseif all(dpxIsWholeNumber(indices)), newn=numel(indices);
else error('Indices should be whole numbers of logical');
end
if newn>oldn
    error(['Number of requested indices (' n ') cannot be larger than the available values in TblStruct (' oldn ').']);
end



% Remove the special N field. Will be put back (with an updated n
% value) at the end of this function
r=rmfield(r,'N');

% Select the subset of r, store in f
fn=fieldnames(r);
for i=1:length(fn)
	thisname=fn{i};
    if strcmp(thisname,'Cyclopean')
        vals=r.Cyclopean.pointers(indices);
        [uVals,~,IC]=klabLegacy('unique',vals); % klabLegacy 2013-09-27, jacob    
        uValsOrdinal=1:numel(uVals);
        for uu=1:numel(uVals)
            f.Cyclopean.data{uu}=r.Cyclopean.data{uVals(uu)};
        end
        f.Cyclopean.pointers=uValsOrdinal(IC);
    elseif iscell(r.(thisname))
        vals=cell(1,newn);
        for j=1:newn
            thisindex=indices(j);
            vals{j}=r.(thisname){thisindex};
        end
        f.(thisname)=vals;
    else
        vals=r.(thisname)(indices);
        f.(thisname)=vals;
    end
end

% Put the special N field back in place
f.N=newn;
