function [ok,str]=dpxIsKbName(value)
    % Part of DPX framework
    % http://tinyurl.com/dpxlink
    % Jacob Duijnhouwer, 2014-11-13
    try
        if ~ischar(value)
            error;
        end
        KbName('UnifyKeyNames');
        KbName(value); % will error if value is not a valid key-name
        ok=true;
    catch
        ok=false;
    end
    str='a valid KbName string. Tip: type KbName in the command window, press Enter, then hit a key 1 second later to find that key''s name';
end
