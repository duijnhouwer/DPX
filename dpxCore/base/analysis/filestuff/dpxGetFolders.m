function foldernames=dpxGetFolders(varargin)
    
    % dpxGetFolders(folder), returns all folders present in folder 'folder', excluding the
    % folders named . and ..
    %
    %   EXAMPLES
    %   dpxGetFolders(pwd)
    %   dpxGetFolders(___,'recursive') optional flag to include all
    %       subfolders recursively
    %   dpxGetFolders(___,'includeroot') optional flag to include the
    %       rootfolder in the output list
    
    
    % Parse the input arguments, they can be in any given order
    idx=cellfun(@(x)exist(x,'file')==7,varargin);
    if ~any(idx)
        error('No or no existing folder name provided');
    end
    startfolder=varargin{idx};
    varargin(idx)=[];
    
    idx=cellfun(@(x)strcmpi(x,'recursive'),varargin);
    doRecurse=any(idx);
    varargin(idx)=[];
    
    idx=cellfun(@(x)strcmpi(x,'includeroot'),varargin);
    doIncludeRoot=any(idx);
    varargin(idx)=[];
    
    % all known options are now exhausted
    if numel(varargin)>0
        error('There were unknown inputs to dpxGetFolders');
    end
    
    % use dir to get all files and folders below startfolder
    if doRecurse
        FF=dir(fullfile(startfolder,'**'));
    else
        FF=dir(startfolder);
    end
    
    % keep only folders
    FF=FF([FF.isdir]);
    
    % remove . and .. folders
    FF=FF(~strcmp('.',{FF.name}) & ~strcmp('..',{FF.name}));
    
    % convert to list of full-path names
    foldernames=fullfile({FF.folder},{FF.name});
    
    % make it a column vector
    foldernames=foldernames(:);
    
    % stick the startfolder at the top of the list if so desired
    if doIncludeRoot
        foldernames=[{startfolder}; foldernames];
    end
end
   

