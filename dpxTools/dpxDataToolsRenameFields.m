function dpxDataToolsRenameFields(oldNameCell,newNameCell)
    
    if ischar(oldNameCell)
        oldNameCell={oldNameCell};
    end
    if ischar(newNameCell) || isempty(newNameCell)
        newNameCell={newNameCell};
    end
    if numel(oldNameCell)~=numel(newNameCell)
        error('number of fieldnames doesn''t match');
    end
    
    % get a list of files to process
    files=dpxUIgetfiles;
    
    % do a dry run first (no saving) 
    toReallyDo=[];
    try
        for i=1:numel(files)
            disp(['[rdFixDataTrialStructBug] Checking ''' files{i} '''.']);
            load(files{i});
            [didfix,newdata]=fix(data,oldNameCell,newNameCell);
            if didfix
                toReallyDo(end+1)=i;
            end
        end
    catch me
        disp(['[rdFixDataTrialStructBug] ' me.message]);
        disp('[rdFixDataTrialStructBug] No file was changed.');
        return
    end
    
    % now do for reals
    if numel(toReallyDo)>0
        for i=toReallyDo(:)'
            disp(['[rdFixDataTrialStructBug] Fixing ''' files{i} '''.']);
            load(files{i});
            [didfix,newdata]=fix(data,oldNameCell,newNameCell);
            if didfix
                save([files{i} 'BACKUP'],'data');
                disp(['[rdFixDataTrialStructBug] Saved ''' [files{i} 'BACKUP'] '''.']);
                data=newdata;
                save(files{i},'data');
                disp(['[rdFixDataTrialStructBug] Saved ''' files{i} '''.']);
            else
                disp(['[rdFixDataTrialStructBug] No DataTrialStructBug detected in file: ''' files{i} ''', not changed.']);
            end
        end
    end
end


function [didfix,D]=fix(D,oldNameCell,newNameCell)
    for i=1:numel(oldNameCell)
        if ~isempty(newNameCell{i})
            D.(newNameCell{i})=D.(oldNameCell{i});
        end
        D=rmfield(D,oldNameCell{i});
    end
    didfix=true;
end
        