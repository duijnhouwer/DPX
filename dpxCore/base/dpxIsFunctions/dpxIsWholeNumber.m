function [b,str]=dpxIsWholeNumber(A)

% Return true if A contains all whole numbers. 
% Return false for elements that are not numbers, not integer, or not positive.
% Jacob Duijnhouwer

b=isnumeric(A) & A>=0 & mod(A,1)==0;
str='an integer greater than zero)';

%if any(~isnumeric(A))
%    b=false;
%elseif any(A<0)
%    b=false;
%elseif any(mod(A,1)~=0)
%    b=false;
%else
%    b=true;
%end
