function foldernames=dpxGetFolders(folder,walktree)
    
    % dpxGetFolders(folder), returns all folders present in folder 'folder', excluding the
    % folders named . and ..
    % If no folder is provided, the current folder is used (pwd)
    % Jacob 20060929
    % updated 2015-07-21
    %       - added option to include subfolders (true or 'walktree') 
    %       - output is now a cell array of full-path folder names
    
    if nargin==0 || isempty(folder)
        folder=pwd;
    elseif nargin==1
        walktree=false;
    end
    
    if ischar(walktree)
        if strcmpi(walktree,'walktree')
            walktree=true;
        else
            error(['Unknown option '  walktree  ', should be true or ''walktree''']);
        end
    end
    
    global foldernames
    foldernames={};
    foldernames=getThisLevel(folder,walktree);
    foldernames=foldernames(:); % make a list
    
    function foldernames=getThisLevel(folder,walktree)
        global foldernames
        list=dir(folder);
        if ~isempty(list)
            list=list([list.isdir]);
        end
        % remove the  . and .. folders in a robust manner (folder starting with ' will
        % precede the . and .. folder, they are not necessarily the first!
        list(strcmp('.',{list.name}))=[];
        list(strcmp('..',{list.name}))=[];   

       % foldernames=cell(size(list));
        for i=1:numel(list)
            foldernames{end+1}=fullfile(folder,list(i).name);
            if walktree
                % include subdirectories by making this function recursive
                getThisLevel(foldernames{end},walktree);
            end
        end
    end
end

