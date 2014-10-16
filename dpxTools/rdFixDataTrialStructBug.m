function rdFixDataTrialStructBug
    
    files=dpxUIgetfiles;
    wb=jdWaitBar(0,'max',numel(files),'Please wait ...','Name','Progress - rdFixDataTrialStructBug');
    for i=1:numel(files)
        load(files{i});
        [didfix,newdata]=fix(data);
        if didfix
            save([files{i} 'BACKUP'],'data');
            data=newdata;
            save(files{i},'data');
        else
            disp(['[rdFixDataTrialStructBug] No DataTrialStructBug detected in file: ''' files{i} ''', not changed.']);
        end
        wb=wb.update;
        if strcmpi(wb.status,'User pressed cancel');
            return;
        end
    end
    wb.close;
    clear('wb');
end

function [didfix,D]=fix(D)
    if ~isfield(D,'trial') || ~isfield(D,'exp')
        didfix=false;
        return;
    end
    D.idx=1:D.N;
    D=dpxdSplit(D,'idx');
    for i=1:numel(D)
        E=dpxFlattenStruct(D{i}.exp);
        S=dpxFlattenStruct(D{i}.stimwin);
        T=dpxFlattenStruct(D{i}.trial);
        D{i}=rmfield(D{i},{'exp','stimwin','trial'});
        D{i}=dpxMergeStructs({E,S,T,D{i}},{'exp_','stimwin_','',''});
        D{i}=dpxStructMakeSingleValued(D{i});
    end
    D=dpxdMerge(D);
    D=rmfield(D,'idx');
    didfix=true;
end