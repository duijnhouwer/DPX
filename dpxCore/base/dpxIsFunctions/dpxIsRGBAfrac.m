function [ok,str]=dpxIsRGBAfrac(value)
    % [ok,str]=dpxIsRGBAfrac(value)
    % Part of DPX: An experiment preparation system
    % http://duijnhouwer.github.io/DPX/
    % Jacob Duijnhouwer, 2014
    ok=isnumeric(value) && numel(value)==4 && all(value<=1) && all(value>=0);
    str='four-element numerical array with values between 0 and 1 inclusive, representing red-green-blue-opacity values.';
end
