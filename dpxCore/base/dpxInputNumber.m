function num=dpxInputNumber(qstr,default)

    % function num=dpxInputNumber(qstr,default)
    %
    % Ask for a number on the command line. Keeps asking until
    % valid or empty answer (that is: use default) is provided.
    %
    % EXAMPLE
    %   num=dpxInputNumber('Enter a number',0)
    %   Enter a number [0] >> 1:5
    %       
    %   num = 
    %       1   2   3   4   5
    %
    % see also: input
    %
    % Jacob 2015-10-09
    
    if ~isnumeric(default)
        error('default should be a number');
    end
    num=default;
    while true
        str=strtrim(input([qstr ' [' num2str(default) '] >> '],'s'));
        if isempty(str)
            break; % use the default;
        elseif ~isempty(str2num(str)) % can the str be converted to a number (e.g. str2num('asd') returns empty vector [])
            num=str2num(str); 
            break;
        else
            disp(['   ''' str ''' can not be converted to a number.']);
        end
    end  
end