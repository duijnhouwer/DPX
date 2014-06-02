function b=pdxIsWholeNumber(A)

% Return true if A contains all whole numbers. 
% Return false if not numbers, not integer, or not positive.
% Note: this function returns a single locigal, not a logical per element!
% Jacob Duijnhouwer
if any(~isnumeric(A))
    b=false;
elseif any(A<0)
    b=false;
elseif any(mod(A,1)~=0)
    b=false;
else
    b=true;
end
