function [B,str]=dpxIsBoolean(A)
    
    % function [B,str]=dpxIsBoolean(A)
    %
    % INPUT:
    %   A: A vector of any type except cell
    % OUTPUT:
    %   B: Indicates which elements of A are true, false, 0 or 1
    %   str: Defines in English what are considered dpxBooleans
    %
    % EXAMPLES:
    %   >> B=dpxIsBoolean([1 0 true false 2])
    %   B = 
    %        1     1     1     1     0
    %
    %   Check if entire array is DPX-style boolean
    % 	>> all(dpxIsBoolean([1 0 true false]))
    %   ans =
    %        1
    %
    % Jacob Duijnhouwer 2015-10-19

    if nargin==0
        A=[];
    end
    B=double(A)==1 | double(A)==0;
    str='dpxBooleans are: true, false, 0, and 1';
end