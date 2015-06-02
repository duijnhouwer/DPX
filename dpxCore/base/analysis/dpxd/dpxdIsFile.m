function isDpxd=dpxdIsFile(filenames)
    
    % isDpxd=ddpxdIsFile(filenames)
    % Check if the filename or the filenames in cell array filenames are valid DPXD files
    %
    % isDpxd will be an array of booleans indicating that the files are a DPXD files or
    % not.
    %
    % Jacob 2015-06-02
    
    if ischar(filenames)
        filenames={filenames};
    elseif ~iscell(filenames)
        error('Input should be a filename (string) or a cell array of filenames');
    end
    if ~all(cellfun(@ischar,filenames))
        error('All elements in cell array filenames should be strings!');
    end
    isDpxd=false(size(filenames));
    for i=1:numel(filenames)
        try
            dpxdLoad(filenames{i});
            isDpxd(i)=true;
        catch
            isDpxd(i)=false;
        end
    end
end
    