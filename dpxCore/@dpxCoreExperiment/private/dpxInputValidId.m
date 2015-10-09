function id=dpxInputValidId(qstr)
    % Get a valid subject or experimenter ID (e.g. JD)
    while true
        id=strtrim(upper(input(qstr,'s')));
        [~,illegal]=dpxSanitizeFileName(id);
        if illegal
            disp(' --- ID contains illegal character(s) ---')
        else
            if isempty(id)
                id='0';
            end
            break;
        end
    end
end