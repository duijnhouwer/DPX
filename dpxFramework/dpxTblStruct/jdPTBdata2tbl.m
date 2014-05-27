function tbl=jdPTBdata2tbl(E)
    
    % TBL=jdPTBdata2tbl(DATA)
    % Convert standardized jdPTB data to jdPTBtbl format for further analysis
    % DATA can be an struct array with each element representing 1 experiment. 
    %
    % See also: jdPTBdataIs, jdPTBtblIs
   
    for i=1:numel(E)
        N=numel(E(i).trials);
        tbl{i}=[];
        for t=1:N
            tbl{i}=appendTrial(tbl{i},E(1),t);
        end
    end
    tbl=jdTblStructMerge(tbl); % make one big TBL for all data 
end


function tbl=appendTrial(tbl,E,trNr)
    if isempty(tbl) && trNr~=1 || trNr==1 && ~isempty(tbl)
        error('When trial number is one (first call), tbl should be []');
    end
    % values outside of conditions and trials structures that are also useful
    tbl.trialNr(trNr)=trNr;
    tbl.subjectID{trNr}=E.subjectID;
    tbl.datenum(trNr)=datenum(E.date);
    % condition structure
    c=E.trials(trNr).condition;  
    fields=fieldnames(E.conditions);
    for f=1:numel(fields)
        newval=E.conditions(c).(fields{f});
        if numel(newval)==1 && (isnumeric(newval) || ischar(newval) || islogical(newval))
            tbl.(fields{f})(trNr)=newval;
        else
            tbl.(fields{f}){trNr}=newval;
        end
    end
    % trials structure
    fields=fieldnames(E.trials);
    for f=1:numel(fields)
        newval=E.trials(trNr).(fields{f});
        if numel(newval)==1 && (isnumeric(newval) || ischar(newval) || islogical(newval))
            tbl.(['trial' fields{f}])(trNr)=newval;
        else
            tbl.(['trial' fields{f}]){trNr}=newval;
        end
    end
    % make it a jdTblStruct and test
    tbl.N=trNr;
    jdTblStructIs(tbl,'verbosity',1);
end
    
    
    
    