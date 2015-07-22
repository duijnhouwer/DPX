function b=dpxStrfindCell(str,strcell,casins)
    
    % Check if any of the strings in strcell occur in str, true or false
    % use option casins for case-insensitive search (default: case-sensitive)
    % jacob 2015-07-22
    
    if nargin==2 
        casins=false;
    end
    if casins
        str=upper(str);
        strcell=upper(strcell);
    end
    b=cellfun(@(x)strfind(str,x),strcell,'UniformOutput',false);
    b=any(~cellfun(@isempty,b));
end