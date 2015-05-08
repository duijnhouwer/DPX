function [ok,str]=dpxIsKbName(value)
    % [ok,str]=dpxIsKbName(value)
    % Part of DPX: An experiment preparation system
    % http://duijnhouwer.github.io/DPX/
    % Jacob Duijnhouwer, 2014-11-13
    
    if ~ischar(value)
        ok=false;
    else
        try
            KbName('UnifyKeyNames');
            KbName(value); % will error if value is not a valid key-name
            ok=true;
        catch
            ok=false;
        end
    end
    str='a valid KbName string. Tip: type KbName in the command window, press Enter, then hit a key 1 second later to find that key''s name';
end
