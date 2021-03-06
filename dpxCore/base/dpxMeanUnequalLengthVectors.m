function [m,n,s,md]=dpxMeanUnequalLengthVectors(c,varargin)
    
    % function [m,n,s,md]=dpxMeanUnequalLengthVectors(c,weights) get the
    % mean 1D vector of a bunch of 1D numerical vectors in cell array c.
    % They can be of unequal length (that's the purpose of this function).
    % Another useful feature over normal mean and std is that of parts in
    % the vectors filled with NaN are ignored.
    %
    % As of 20090818, the standard deviation is also calculated. is pretty
    % time consuming so only done when the output argument list requires
    % this (>=four output arguments)
    %
    % outputs: m, the vector of means; n, the number of non-nan
    % observations per element in m; md, the vector of medians; s, the
    % standard deviation vector m and n and s will have the same length as
    % the longest vector in c
    %
    % Use the prioritize switch ([memory],speed) to be efficient with
    % either RAM or the CPU.
    %
    % Adapted from jdMeanUnequalLengthVectors and added to DPX on
    % 2014-12-09. Jacob
    %
    % 2015-02-03: added calculation of median
      
    p = inputParser;   % Create an instance of the inputParser class.
    p.addOptional('align','begin',@(x)any(strcmpi(x,{'begin','end'})));
    p.addOptional('prioritize','memory',@(x)any(strcmpi(x,{'memory','speed'})));
    p.parse(varargin{:});
    
    if ~iscell(c)
        error('first argument must be a cell array');
    end
    for i=1:numel(c)
        if ~isnumeric(c{i}) || ~isvector(c{i})
            error('each element of cell array c must be a 1d numerical vector.');
        end
        if size(c{i},1)>size(c{i},2), c{i}=c{i}'; end % make row format
    end
     
    if nargout>2
        if strcmpi(p.Results.prioritize,'memory')
            [m,n,s,md]=doitlean(c,p);
        elseif strcmpi(p.Results.prioritize,'speed')
            [m,n,s,md]=doitfast(c,p);
        else
            error('wtf?');
        end
    else
        if strcmpi(p.Results.prioritize,'memory')
            [m,n]=doitlean(c,p);
        elseif strcmpi(p.Results.prioritize,'speed')
            [m,n]=doitfast(c,p);
        else
            error('wtf?');
        end
    end
end

function [m,n,s,md]=doitlean(c,p)
    % Which is the longest vector in c?
    mx=0;
    for i=1:numel(c)
        if length(c{i})>mx
            mx=length(c{i});
        end
    end
    if nargout<3
        % Standard deviation is not requested, so we can do the quick method
        m=zeros(1,mx);
        n=zeros(1,mx);
        if strcmpi(p.Results.align,'begin')
            for i=1:numel(c)
                idx=find(isnan(c{i})==0);
                m(idx)=m(idx)+double(c{i}(idx));
                n(idx)=n(idx)+1;
            end
        elseif strcmpi(p.Results.align,'end')
            for i=1:numel(c)
                idx=find(isnan(c{i})==0);
                endidx=mx-max(idx)+idx;
                m(endidx)=m(endidx)+double(c{i}(idx));
                n(endidx)=n(endidx)+1;
            end
        else
            error('wtf?');
        end
        % put nan's in m where the number of observations is zero
        m(n==0)=nan;
        % calculate the mean
        m=m./n;
    elseif nargout>2
        % Standard deviation is requested, so use the slower method
        m=zeros(1,mx);
        n=zeros(1,mx);
        s=zeros(1,mx);
        md=zeros(1,mx);
        if strcmpi(p.Results.align,'begin')
            for i=1:mx
                % From every row vector in c, get the value V at pos i
                COLUMN=nan(numel(c),1);
                for j=1:numel(c)
                    if i<=numel(c{j}) % does this row vector in C have a value at this position?
                        COLUMN(j)=double(c{j}(i)); % ... include it in the TEMP list
                    end
                end
                m(i)=nanmean(COLUMN);
                n(i)=sum(~isnan(COLUMN));
                md(i)=nanmedian(COLUMN);
                s(i)=nanstd(COLUMN);
            end
        elseif strcmpi(p.Results.align,'end')
            tel=0;
            for i=mx:-1:1
                % From every row vector in c, get the value V at pos i
                COLUMN=nan(numel(c),1);
                for j=1:numel(COLUMN)
                    if numel(c{j})-tel>0 % does this row vector in C have a value at this position?
                        COLUMN(j)=double(c{j}(end-tel)); % ... include it in the TEMP list
                    end
                end
                m(i)=nanmean(COLUMN);
                n(i)=sum(~isnan(COLUMN));
                md(i)=nanmedian(COLUMN);
                s(i)=nanstd(COLUMN);
                tel=tel+1;
            end
        else
            error('wtf?');
        end
    end
end

function [m,n,s,md]=doitfast(c,p)
    warning('speed optimized jdMeanUnequalLengthVectors not implemented, running default memory-lean version.');
    if nargout>2
        [m,n,s,md]=doitlean(c,p);
    else
        [m,n]=doitlean(c,p);
    end
end
