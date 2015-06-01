function dpxdToolRenameSubject(old,new)
    %
    % Rename subject in DPXD, change filename accordingly
    %
    % EXAMPLE: 
    %   dpxdToolRenameSubject({'M001','M002','M003','M004'},{'M005','M006','M007','M008'})
    %   -- will bring up a file selection dialog, then it will rename all the
    %   files that contain one of the subject names in old and replace the
    %   'exp_subjectId' fiels in the internal DPXD strcut. This will then be
    %   saved in the current working directory.
    %
    %   It is highly recommended to write to a new folder and only delete the
    %   old files when you're absolutely sure everything is correct.
    %
    % Jacob, 2015-05-24

    if ischar(old) 
        old={old};
    end
    if ischar(new)
        new={new};
    end
    if ~all(cellfun(@ischar,old))
        error('old subject names should all be strings');
    end
      if ~all(cellfun(@ischar,new))
        error('new subject names should all be strings');
    end
    if numel(old)~=numel(new)
        error('Number of old and new subject names should correspond');
    end
    files=dpxUIgetfiles;
    if numel(files)==0
        return;
    end
    for i=1:numel(files)
        [paradigm,subjectFromFilename,timestamp]=dpxdGetFilenameParts(files{i});
        if any(strcmpi(subjectFromFilename,old))
            idx=strcmpi(subjectFromFilename,old);
            try
                [dpxd,theRest]=dpxdLoad(files{i});
            catch me
                rethrow(me);
            end
            for ii=1:dpxd.N
                dpxd.exp_subjectId{ii}=new{idx};
            end
        end
        newFileName=[paradigm '-' new{idx} '-' timestamp '.mat'];
        if ~isempty(theRest)
            save(newFileName,'dpxd','theRest');
        else
            save(newFileName,'dpxd');
        end
    end
end
            