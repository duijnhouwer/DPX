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
    isDpxd=dpxdIsFile(files);
    if sum(~isDpxd)>0
        warning([num2str(sum(~isDpxd)) ' of the ' num2str(numel(isDpxd)) ' files you selected were not DPXD files. They will be ignored']);
        files=files(isDpxd);
    end
    [old,new]=expandWildCardFields(files,old,new);
    [old,new]=checkInput(old,new);
    checkThatNoneOfTheNewNamesAreAlreadyInTheDPXD(new,files)
    askToMakeBackups(files);
    replaceTheFieldsAndSave(files,old,new);
    disp('Done.');
end


function checkThatNoneOfTheNewNamesAreAlreadyInTheDPXD(new,files)
    err='';
    for idxf=1:numel(files)
        try
            [dpxd,theRest]=dpxdLoad(files{idxf});
        catch me
            disp(me.message); % probably not a DPXD file
            continue; % with next file
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


function replaceTheFieldsAndSave(files,old,new)
    for i=1:numel(files)
        [~,fname,ext]=fileparts(files{i});
        disp(['Renaming fields in file ' num2str(i) '/' num2str(numel(files)) ': ''' [fname ext] '''.' ]);
        try
            [dpxd,theRest]=dpxdLoad(files{i});
        catch me
            disp(me.message); % probably not a DPXD file
            continue; % with next file
        end
        % rename the old into the new
        for oi=1:numel(old)
            dpxd.(new{oi})=dpxd.(old{oi});
            dpxd=rmfield(dpxd,old{oi});
        end
        % save the updated datafile
        if ~isempty(theRest)
            save(files{i},'dpxd','theRest');
        else
            save(files{i},'dpxd');
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
    end
end


function [old,new]=expandWildCardFields(files,old,new)
    isWildCard=false(size(old));
    for i=1:numel(old)
        if old{i}(end)=='*' && new{i}(end)=='*'
            isWildCard(i)=true;
        elseif old{i}(end)=='*' && new{i}(end)~='*' || old{i}(end)~='*' && new{i}(end)=='*'
            error('When using wildcards, both corresponding old and new fields need to end with a asterisk (*)');
        end
    end
    wildcardfieldsOld=old(isWildCard);
    wildcardfieldsNew=new(isWildCard);
    oldExpandedFields={};
    newExpandedFields={};
    for i=1:numel(files)
        try
            dpxd=dpxdLoad(files{i});
        catch me
            disp(me.message); % probably not a DPXD file 
            continue; % with next file 
        end
        F=fieldnames(dpxd);
        for w=1:numel(wildcardfieldsOld)
            beginstrOld=wildcardfieldsOld{w}(1:end-1);
            beginstrNew=wildcardfieldsNew{w}(1:end-1);
            matchIdx=strncmp(F,beginstrOld,numel(beginstrOld));
            eOld=F(matchIdx);
            eNew=cell(size(eOld));
            for ee=1:numel(eOld)
                eNew{ee}=[beginstrNew eOld{ee}(numel(beginstrOld)+1:end)];
            end
            oldExpandedFields={oldExpandedFields{:} eOld{:}}'; %#ok<CCAT>
            newExpandedFields={newExpandedFields{:} eNew{:}}'; %#ok<CCAT>
        end
    end
    old(isWildCard)=[];
    new(isWildCard)=[];
    old={old{:} oldExpandedFields{:}}';
    new={new{:} newExpandedFields{:}}';
    old=unique(old);
    new=unique(new);
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
    % check if number of old and new fields match
    if numel(old)~=numel(new)
        error('Number of old and new field names should correspond');
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
    % check all strings have non zeros length
    if any(cellfun(@numel,old)==0)
        error('old field names should have non-zero length, no empty strings allowed');
    end
    if any(cellfun(@numel,new)==0)
        error('new field names should have non-zero length, no empty strings allowed');
    end
    % check all strings are free of whitespaces
    if any(cellfun(@(x)any(isspace(x)),old))
        error('old field names may not contain whitespace');
    end
    if any(cellfun(@(x)any(isspace(x)),new))
        error('new field names may not contain whitespace');
    end
    % check all strings are free of periods
    if any(cellfun(@(x)any(strfind(x,'.')),old))
        error('old field names may not contain periods (.)');
    end
    if any(cellfun(@(x)any(strfind(x,'.')),new))
        error('new field names may not contain periods (.)');
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


