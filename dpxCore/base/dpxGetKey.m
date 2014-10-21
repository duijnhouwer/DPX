function idx=dpxGetKey(names)
    
    % IDX=dpxGetKey(NAMES)
    %
    % NAMES can be a keyname-string, e.g., 'Escape'. If Escape is pressed
    % IDX will be 1, otherwise idx is 0;
    %
    % Alternatively, NAMES is a cell array of strings, e.g.,
    % {'Escape','Pause'}. In that case IDX will be 1 if Escape is pressed,
    % 2 if Pause is pressed, i.e., the number of their respective
    % cell-element.
    %
    % Otherwise, IDX is 0.
    %
    % Part of DPX framework
    % http://tinyurl.com/dpxlink
    % Jacob Duijnhouwer, 2014-10-21
    
    idx=0;
    [keyIsDown,~,keyCode]=KbCheck(-1);
    if keyIsDown
        KbName('UnifyKeyNames');
        idx=0;
        if ischar(names)
            if keyCode(KbName(names))
                idx=1;
            end
        elseif iscell(names)
            for i=1:numel(names)
                if keyCode(KbName(names{i}))
                    idx=i;
                    break;
                end
            end
        else
            error('argument should be a string or a cell array of strings');
        end
    end           
end