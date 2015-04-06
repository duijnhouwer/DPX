function [ok,str]=dpxIsCellArrayOfStrings(value)
    % [ok,str]=dpxIsRGBAfrac(value)
    % Part of DPX: An experiment preparation system
    % http://duijnhouwer.github.io/DPX/
    % Jacob Duijnhouwer, 2014
    %
    % EXAMPLE
    % a=123;
    % [ok,str]=dpxIsCellArrayOfStrings(a)
    % if ~ok, error('a should be ' str); end

    str='a cell array of strings'; 
    if ~iscell(value)
        ok=false;
    elseif iscell(value)
        for i=1:numel(value)
            if ~ischar(value{i})
                ok=false;
                return;
            end
        end
    else
        ok=true;
    end
end