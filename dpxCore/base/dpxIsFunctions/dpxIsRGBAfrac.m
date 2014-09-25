function [ok,str]=dpxIsRGBAfrac(value)
    ok=isnumeric(value) && numel(value)~=4 && all(value<=1) && all(value>=0);
    str='four-element numerical array with values between 0 and 1 inclusive, representing red-green-blue-opacity fractions';
end
