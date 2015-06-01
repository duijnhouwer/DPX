function dpxdToolRenameFields(old,new)
    
    % dpxdToolRenameFields(old,new)
    % 
    % Rename structure fields in DPXDs. A file selector will open. old and new
    % are string or a cell array of strings corresponding to the old and the
    % new fieldnames. old and new should be of equal length, it's a 1-to-1
    % mapping. The field names can end with a wildcard ('*'), the matching part
    % (only beginning at the time of writing) will be replaced with the
    % corresponding parts in new. 
    %
    % EXAMPLE:
    %   dpxdToolRenameFields('grating_*','test_*');
    %
    % Jacob, 2015-05-31
    
    [old,new]=checkInput(old,new);
    files=dpxUIgetfiles('filterspec','*.mat','dialogtitle','Select DPXD files to rename fields in');
    if numel(files)==0
        return;
    elseif ischar(files)
        files={files};
    end
    [old,new]=expandWildCardFields(files,old,new);
    [old,new]=checkInput(old,new);
    checkThatNoneOfTheNewNamesAreAlreadyInTheDPXD(new,files)
    askToMakeBackups(files);
    replaceTheFields(files,old,new);
    disp('Done.');
end


function [old,new]=checkInput(old,new)
    % make cell
    if ischar(old)
        old={old};
    end
    if ischar(new)
        new={new};
    end
    % check unique names per old and new
    n=numel(old);
    old=unique(old,'stable');
    if n~=numel(old)
        error('old field names should be unique');
    end
    n=numel(new);
    new=unique(new,'stable');
    if n~=numel(new)
        error('new field names should be unique');
    end
    % check all uniques names across old and new, this function can't be used
    % to swap fieldnames, at least not in one step. it can be achieved in
    % multiple steps with a temporary dummy field name
    if numel(old)+numel(new)~=numel(unique([old new]))
        error('field names can not occur in old and in new. if you want to swap fieldnames you''ll need an intermediate dummy-name in a two step process');
    end
    % check all are strings
    if ~all(cellfun(@ischar,old))
        error('old field names should all be strings');
    end
    if ~all(cellfun(@ischar,new))
        error('new field names should all be strings');
    end
    % check numbers match
    if numel(old)~=numel(new)
        error('Number of old and new field names should correspond');
    end
    % check that if there are wildcards they are at the end of the string
    for i=1:numel(old)
        if any(old{i}=='*')
            if old{i}(end)~='*'
                error(['Old field ''' old{i} ''' contains a wildcard, but they can only be used at the end of the string'])
            end
            if new{i}(end)~='*'
                error(['Old field ''' old{i} ''' ends with a wildcard, but the corresponding new field doesn''t'])
            end
        end
    end
    
end


function checkThatNoneOfTheNewNamesAreAlreadyInTheDPXD(new,files)
    err='';
    for idxf=1:numel(files)
        try
            dpxd=dpxdLoad(files{idxf});
        catch me
            rethrow(me);
        end
        F=fieldnames(dpxd);
        for in=1:numel(new)
            if any(strcmpi(new{in},F))
                fname=files{idxf};
                fname(fname=='\')='/';
                err=[err '\n Fieldname ''' new{in} ''' already exists in ''' fname '''']; %#ok<AGROW>
            end
        end
    end
    if ~isempty(err)
        error('a:b',err);
    end
end


function replaceTheFields(files,old,new)
    for idxf=1:numel(files)
        [~,fname,ext]=fileparts(files{idxf});
        disp(['Renaming fields in file ' num2str(idxf) '/' num2str(numel(files)) ': ''' [fname ext] '''.' ]);
        try
            [dpxd,theRest]=dpxdLoad(files{idxf});
        catch me
            rethrow(me);
        end
        % rename the old into the new
        for oi=1:numel(old)
            dpxd.(new{oi})=dpxd.(old{oi});
            dpxd=rmfield(dpxd,old{oi});
        end
        % save the updated datafile
        if ~isempty(theRest)
            save(files{idxf},'dpxd','theRest');
        else
            save(files{idxf},'dpxd');
        end
    end
end


function askToMakeBackups(files)
    qst='The files you select will be updated and overwritten. This cannot be undone.\nDo you want to make backup copies first?';
    f=questdlg(qst, 'dpxdToolRenameFields: Create backups first?', 'Select backup folder...','Continue without backup','Select backup folder...');
    if strcmpi(f,'Select backup folder...')
        foldername=uigetdir(pwd,'Select (or create) a folder to make backup copies of the selected DPXDs in');
        for i=1:numel(files)
            [~,fname,ext]=fileparts(files{i});
            disp(['Making backup of file ' num2str(i) '/' num2str(numel(files)) ': ''' [fname ext] '''.' ]);
            [~,fname,ext]=fileparts(files{i});
            copyfile(files{i},fullfile(foldername,[fname ext]));
        end
    else
        disp('User canceled');
        return;
    end
end


function [old,new]=expandWildCardFields(files,old,new)
    isWildCard=false(size(old));
    for i=1:numel(old)
        if old{i}(end)=='*';
            isWildCard(i)=true;
        end
    end
    wildcardfieldsOld=old(isWildCard);
    wildcardfieldsNew=new(isWildCard);
    oldExpandedFields={};
    newExpandedFields={};
    for i=1:numel(files)
       % try
            dpxd=dpxdLoad(files{i});
       % catch me
      %      rethrow(me);
       % end
        F=fieldnames(dpxd);
        for w=1:numel(wildcardfieldsOld)
            beginstrOld=wildcardfieldsOld{w}(1:end-1);
            beginstrNew=wildcardfieldsNew{w}(1:end-1);
            matchIdx=strncmp(F,beginstrOld,numel(beginstrOld));
            eOld=F(matchIdx);
            eNew=cell(size(eOld));
            for ee=1:numel(eOld)
                eNew{ee}=[beginstrNew eOld{ee}(numel(beginstrOld):end)];
            end
            oldExpandedFields={oldExpandedFields{:} eOld{:}}'; %#ok<CCAT>
            newExpandedFields={newExpandedFields{:} eNew{:}}'; %#ok<CCAT>
        end
    end  
    old(isWildCard)=[];
    new(isWildCard)=[];
 	old={old{:} oldExpandedFields{:}}';
    new={new{:} newExpandedFields{:}}';
end

