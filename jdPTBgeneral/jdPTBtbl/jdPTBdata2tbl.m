function tbl=jdPTBdata2tbl(data)
    
    % tbl=jdPTBdata2tbl(data)
    % Convert standardized jdPTB data to jdPTBtbl format for further analysis
    %
    % See also: jdPTBdataIs, jdPTBtblIs
    
  
    N=numel(data.trials.condition);
    tbl=[];
    for t=1:N
        tbl=appendTrial(tbl,data,t);
    end
        
end


function tbl=appendTrial(tbl,data,trNr)
    if isempty(tbl) && trNr~=1 || trNr==1 && ~isempty(tbl)
        error('When trial number is one (first call), tbl should be []');
    end
    c=data.trials.condition(trNr);  
    fields=fieldnames(data.conditions);
    for f=1:numel(fields)
        % values outside of condition that are also useful
        tbl.trialNr(trNr)=trNr;
        tbl.subjectID{trNr}=data.subjectID;
        tbl.datenum(trNr)=datenum(data.date);
        newval=data.conditions(c).(fields{f});
        if numel(newval)==1 && (isnumeric(newval) || ischar(newval))
            tbl.(fields{f})(trNr)=newval;
        else
            tbl.(fields{f}){trNr}=newval;
        end
    end
    tbl.N=trNr;
    jdTblStructIs(tbl,'verbosity',1);
end
    
    
    
    