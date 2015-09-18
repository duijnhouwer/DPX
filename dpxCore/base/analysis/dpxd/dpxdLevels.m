function [n]=dpxdLevels(DPXD,fieldname)
    
    % Return the number of unique values in dpxd.(fieldname)
    % Used in dpxdSplit (2014-11-25)
    
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('r', @dpxdIs);
    p.addRequired('fieldname',@ischar);
    p.parse(DPXD,fieldname);
    if ~isfield(DPXD,fieldname)
        str=sprintf('Error: Passed fieldname "%s" is not an existing field in DPXD.\nValid fieldnames are:',fieldname);
        disp(str);
        disp(fieldnames(DPXD))
        error([str ' (see above) ']);
    end
    vals=eval(['DPXD.' fieldname]);
    n=length(unique(vals));
end
