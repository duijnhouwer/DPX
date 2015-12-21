function p = pFromCritical(stat,n,tableName)
% function pFromCritical(stat,n,tableName)
% Determine a p-value given a value of a statistic, the number of samples and
% the name of the table for this statistic. Note that the Table should have 
% sample numbers in its first column, p-values in its first row and corresponding
% critical values in all other entries. For an example, see ptable.m.  From left to righ
% the significance level should increase p = [1 0.5 0.01 0.001] for instance.
%
% INPUT
% stat	= The value of the statistic. Can be a vector or matrix: the test will be applied to each (in a loop)
% n		= The number of samples. Can be a vector or matrix.
% tableName  = The name of the table.
% OUTPUT
% p		= The p-value associated with this statistic (conservative)
%
% BK -  16.8.2001 - last change $Date: 2001/08/23 19:18:05 $ by $Author: bart $
% $Revision: 1.3 $

eval(['Table = ' tableName ';']);

[r,c]   = size(stat);
nr      = r*c;
stat    = stat(:);
n       = n(:);
if length(n) ~= nr
    if length(n) ==1
        n = n.*ones(r,c);
    else
        error('The number of samples should be given for each statistic!')
    end
end

for i = 1:nr
    diff = Table(:,1)-n(i);
    diff(diff>0 | isnan(diff)) =[]; % NaN is the topleft number in the table which isnt really an N.
    [val,row] = max(diff);
    if ~isempty(row)
        diff =  Table(row,2:end)-stat(i);
        diff(diff>0) =[];
        if ~isempty(diff)
            [val,index] = max(diff);
            p(i) = Table(1,1+index);
        else
            p(i) = 1;
        end
    else
        p(i) = NaN;
    end
end

% Put it back into the shape it was in.
p = reshape(p,r,c);