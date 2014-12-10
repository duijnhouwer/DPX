function dirstr=dpxGetLastDirStr
    
        % see also: jdSetLastDirStr, jdUIgetfiles
    try
        load(fullfile(tempdir,'matlabDpxLastdirstr.mat'));
    catch
        dirstr=fullfile('./');
    end
    if ~ischar(dirstr) || exist(fullfile(dirstr),'file')~=7
        dirstr=fullfile('./');
    end
    
    if false
        try
            p=regexp(userpath,';','split');
            load(fullfile(p{1},'.matlabDpxLastdirstr.mat'));
        catch
            dirstr=pwd;
        end
        
        if ~ischar(dirstr)
            dirstr=pwd;
        end
    end
end