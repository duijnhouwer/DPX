function [v] = multiplex(counts)
% Given a vector with counts, return an index vector that can be used to get that many counts.
% EG: multiplex([2 3 1])
%returns: [ 1 1 2 2 2 3]
%
% INPUT
% counts = 	A vector with counts.
% OUTPUT
% v = An index vector.
%
% BK - 2/9/99 - last change $Date: 2001/08/23 19:16:05 $ by $Author: bart $
% $Revision: 1.1 $

totalNr = length(counts);
v = zeros(1,sum(counts));
done =1;
for nr = 1:totalNr
   v(done:done+counts(nr)-1) =  nr.*ones(1,counts(nr));
   done = done+counts(nr);
end
