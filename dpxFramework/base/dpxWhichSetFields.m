function setFields=dpxWhichSetFields(obj)
    % SETFIELDS=dpxWhichSetFields(OBJ)
    % SETFIELDS contains the names of fields in OBJ that can be set.
    % Jacob 20140528
    
    allFields=fieldnames(obj);
    okToSet=true(numel(allFields),1);
    for i=1:numel(allFields)
        try
            obj.(allFields{i})=obj.(allFields{i});
        catch me
            okToSet(i)=false;
        end  
    end
    setFields=allFields(okToSet);
end
    
    