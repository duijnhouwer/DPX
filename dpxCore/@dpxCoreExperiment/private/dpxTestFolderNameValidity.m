function errstr = dpxTestFolderNameValidity(foldername)
    
    % errstr = dpxTestFolderNameValidity(foldername)
    % EXAMPLE:
    %   foldername='C:\TESTDIR';
    %   error(dpxTestFolderNameValidity(foldername)); % error([]) is ignored
    
    errstr=[];
    if ~ischar(foldername) || isempty(foldername)
        errstr='foldername should be a string (char)';
    elseif exist(foldername,'file')~=7
        try
            mkdir(foldername);
        catch % me
            errstr=(['Could not create folder ''' foldername '''.']);
        end
        if exist(foldername,'file')==7
            rmdir(foldername);
        end
    end
end

