function p = pFromP(stat,n,tableName)
% function pFromP(stat,n,tableName)
% Determine a p-value given a value of a statistic, the number of samples and
% the name of the table for this statistic. Note that the Table should have 
% values for the statistic in its first column and it is assumed that the higher the
% statistic the beter. The first row should contain the number of samles and the
% p-values fill all other other entries of the table. For an example, see htable.m
% INPUT
% stat	= The value of the statistic.
% n		= The number of samples
% tableName  = The name of the table.
% OUTPUT
% p		= The p-value associated with this statistic (conservative)
%
% BK -  16.8.2001 - last change $Date: 2001/08/23 19:18:05 $ by $Author: bart $
% $Revision: 1.2 $

eval(['Table = ' tableName ';']);

diff = Table(1,:)-n;
diff(diff>0) =[];
[val,col] = max(diff);
  
diff = Table(:,1)-stat;
diff(diff>0 |isnan(diff)) =[];
if ~isempty(diff)
    [val,row] = max(diff);
    p = Table(row,col);
else
    p =1;
end

