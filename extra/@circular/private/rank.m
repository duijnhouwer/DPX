function rank = rank(m);
% Return the rank of each entry in a column vector (or for each column when 
% a matrix is specified). 
% The number 1 represents the entry with the SMALLEST value in the input matrix.
% INPUT 
% m =  A matrix
% OUTPUT 
% rank = The ranks for the numbers in the matrix.
%
% BK 22.5.2000 - last change $Date: 2001/08/23 19:16:05 $ by $Author: bart $
% $Revision: 1.1 $


nan = isnan(m);
[sorted,index] = sort(m);
[sorted,rank] = sort(index);
rank(nan) = NaN;