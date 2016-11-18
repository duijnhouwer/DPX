function F = dpxdMatchFieldnames(DPXD,PAT)
    
    %F = dpxdMatchFieldnames(DPXD,STR)
    %   Return the fieldnames of struct DPXD that match string PAT as in
    %   the regular expression regexp(fieldnames(DPXD),PAT,'match')
    %
    %   Examples:
    %       D = dpxdDummy;
    %       dpxdMatchFieldnames(D,'d') % A fieldnames containing "d"
    %       dpxdMatchFieldnames(D,'d\>') % A fieldnames ending with "d"
    %
    % Jacob 20160721
    
    F = fieldnames(DPXD);
    C = regexp(F,PAT,'match');
    ok = ~cellfun(@isempty,C);
    F = F(ok);
end