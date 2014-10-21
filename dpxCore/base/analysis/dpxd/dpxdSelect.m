function [f,thisval]=dpxdSelect(r,fieldname,varargin)

% Get a subset of the dpxd
% see also dpxdSubset (a far simpler alternative)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Handle varargin list
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('r', @dpxdIs);
p.addRequired('fieldname',@ischar);
p.addParamValue('eq',[],@(x)isnumeric(x) || ischar(x));
p.addParamValue('ne',[],@(x)isnumeric(x) || ischar(x));
p.addParamValue('lt',[],@(x)isnumeric(x));
p.addParamValue('ge',[],@(x)isnumeric(x));
p.addParamValue('le',[],@(x)isnumeric(x));
p.addParamValue('gt',[],@(x)isnumeric(x));
p.addParamValue('subindex',[],@(x)jdIsWholeNumber(x) && numel(x)==1);
p.addParamValue('numel_ge',[],@jdIsWholeNumber);
p.addParamValue('numel_gt',[],@jdIsWholeNumber);
p.addParamValue('numel_lt',[],@jdIsWholeNumber);
p.addParamValue('numel_le',[],@jdIsWholeNumber);
p.addParamValue('warn0left',false,@(x)islogical(x) || x==1 || x==0);
%p.addOptional('min',[],@isnumeric);
%p.addOptional('max',[],@isnumeric);
p.addParamValue('increasing',[],@isnumeric);
p.parse(r,fieldname,varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(r,fieldname)
	str=sprintf('Error: Passed fieldname "%s" is not an existing field in essence-struct.\nValid fieldnames are:',fieldname);
	disp(str);
	disp(fieldnames(r))
	error('(see above)');
end

% Only one criterion can be selected at one time, check that that is the case now
ncrits=0;
ncrits=ncrits+~isempty(p.Results.eq);
ncrits=ncrits+~isempty(p.Results.ne);
ncrits=ncrits+~isempty(p.Results.lt);
ncrits=ncrits+~isempty(p.Results.gt);
ncrits=ncrits+~isempty(p.Results.le);
ncrits=ncrits+~isempty(p.Results.ge);
ncrits=ncrits+~isempty(p.Results.numel_ge);
ncrits=ncrits+~isempty(p.Results.numel_gt);
ncrits=ncrits+~isempty(p.Results.numel_lt);
ncrits=ncrits+~isempty(p.Results.numel_le);
ncrits=ncrits+~isempty(p.Results.increasing);
if ncrits==0
	error('No criterion for selection given.');
elseif ncrits>1
	error('Only one criterion can be given per call.');
end

vals=eval(['r.' fieldname]);
thisval=[];
f=[];
I=GetIndicesOfMatchingValues(r.(fieldname),p);
f=dpxdSubset(r,I);
if p.Results.warn0left && f.N==0
    warning(['No trials left after applying selection critiria on fieldname "' fieldname '".']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Main functions                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I=GetIndicesOfMatchingValues(arr,p)
% returns of the indices of the values that match the criteria in I
EQUAL=p.Results.eq;
NOTEQUAL=p.Results.ne;
LSTHEN=p.Results.lt;
LSTHENOREQ=p.Results.le;
GRTHEN=p.Results.gt;
GRTHENOREQ=p.Results.ge;
SUBINDEX=p.Results.subindex;
N=numel(arr);
% EQUAL
if ~isempty(EQUAL) && isempty(SUBINDEX)
	if isnumeric(EQUAL)
		I=find(arr==EQUAL);
	elseif ischar(EQUAL)
		I=zeros(1,N); % allocate max needed size
		n=0;
		for i=1:N
			if strcmp(arr(i),EQUAL)
				n=n+1;
				I(n)=i;
			end
		end
		I=I(1:n); % trim to actually used size
	else
		error('Option "eq" can only compare numerical and string values');
	end
	elseif ~isempty(EQUAL) && ~isempty(SUBINDEX)
	I=zeros(1,N); % prealloc in max size possible
	n=0;
	for i=1:N
		if isnumeric(EQUAL)
			if arr{i}(SUBINDEX)==EQUAL
				n=n+1;
				I(n)=i;
			end
		elseif ischar(EQUAL)
			if strcmp(arr{i}(SUBINDEX),EQUAL)
				n=n+1;
				I(n)=i;
			end
		else
			error('Option "ne" with option "subindex" can only compare numerical and string values');
		end
		I=I(1:n); % trim to actually needed size
	end	
% NOT EQUAL
elseif ~isempty(NOTEQUAL) && isempty(SUBINDEX)
	if isnumeric(NOTEQUAL)
		I=find(arr~=NOTEQUAL);
	elseif ischar(NOTEQUAL)
		I=zeros(1,N);
		n=0;
		for i=1:N
			if ~strcmp(arr(i),NOTEQUAL)
				n=n+1;
				I(n)=i;
			end
		end
		I=I(1:n);
	else
		error('Option "eq" can only compare numerical and string values');
	end
elseif ~isempty(NOTEQUAL) && ~isempty(SUBINDEX)
	I=zeros(1,N);
	n=0;
	for i=1:N
		if isnumeric(NOTEQUAL)
			if arr{i}(SUBINDEX)~=NOTEQUAL
				n=n+1;
				I(n)=i;
			end
		elseif ischar(NOTEQUAL)
			if ~strcmp(arr{i}(SUBINDEX),NOTEQUAL)
				n=n+1;
				I(n)=i;
			end
		else
			error('Option "ne" with option "subindex" can only compare numerical and string values');
		end
		I=I(1:n);
	end
% LESS THAN	
elseif ~isempty(LSTHEN) && isempty(SUBINDEX)
	if isnumeric(LSTHEN)
		I=find(arr<LSTHEN);
	else
		error('Option "lt" can only compare numerical values');
	end
elseif ~isempty(LSTHEN) && ~isempty(SUBINDEX)
	error('Not implemented');
% LESS THAN OR EQUAL	
elseif ~isempty(LSTHENOREQ) && isempty(SUBINDEX)
	if isnumeric(LSTHENOREQ)
		I=find(arr<=LSTHENOREQ);
	else
		error('Option "le" can only compare numerical values');
	end
elseif ~isempty(LSTHENOREQ) && ~isempty(SUBINDEX)
	error('Not implemented');
% GREATER THAN
elseif ~isempty(GRTHEN) && isempty(SUBINDEX)
	if isnumeric(GRTHEN)
		I=find(arr>GRTHEN);
	else
		error('Option "gt" can only compare numerical values');
	end
elseif ~isempty(GRTHEN) && ~isempty(SUBINDEX)
	error('Not implemented');
% GREATER THAN OR EQUAL		
elseif ~isempty(GRTHENOREQ) && isempty(SUBINDEX)
	if isnumeric(GRTHENOREQ)
		I=find(arr>=GRTHENOREQ);
	else
		error('Option "ge" can only compare numerical values');
	end
elseif ~isempty(GRTHENOREQ) && ~isempty(SUBINDEX)
	error('Not implemented');
% NUMBER OF ELEMENT FUNTIONS	
elseif ~isempty(p.Results.numel_ge)
	I=zeros(1,N);
	n=0;
	for i=1:N
		if numel(arr{i})>=p.Results.numel_ge
			n=n+1;
			I(n)=i;
		end
	end
	I=I(1:n);
	
elseif ~isempty(p.Results.numel_gt)
	I=zeros(1,N);
	n=0;
	for i=1:N
		if numel(arr{i})>p.Results.numel_gt
			n=n+1;
			I(n)=i;
		end
	end
	I=I(1:n);
elseif ~isempty(p.Results.numel_le)
	I=zeros(1,N);
	n=0;
	for i=1:N
		if numel(arr{i})<=p.Results.numel_le
			n=n+1;
			I(n)=i;
		end
	end
	I=I(1:n);
elseif ~isempty(p.Results.numel_lt)
	I=zeros(1,N);
	n=0;
	for i=1:N
		if numel(arr{i})<p.Results.numel_lt
			n=n+1;
			I(n)=i;
		end
	end
	I=I(1:n);
elseif ~isempty(p.Results.increasing)
	incr=p.Results.increasing;
	if incr<=0
		error(['Index to increment list cannot be smaller or equal to zero, but ' incr ' was passed.']);
	end
	U=unique(arr);
	if incr>length(U)
		% end of increment list reached (which is normal operation), return empty array
		I=[];
		return; 
	end % 
	if iscell(U)
		thisval=U{incr};
		%sprintf('%s = %s\n',fieldname,thisval)
	else
		thisval=U(incr);
		%sprintf('%s = %d\n',fieldname,thisval)
	end
	if isnumeric(thisval) || islogical(thisval)
		I=find(arr==thisval);
	elseif ischar(thisval)
		I=find(strcmp(arr,thisval));
	else
		error('Option "increasing" can only compare numerical, logical, or string values');
	end
else
	error(['No or invalid condition-requirement passed.']);
end




