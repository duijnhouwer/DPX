function s=dpxGetSetables(obj)
    % Like get(obj) but only fields with get AND set access are returned
    % Jacob 20140528
    fields=dpxWhichSetFields(obj);
    for i=1:numel(fields)
        s.(fields{i})=obj.(fields{i});
    end 
end

% --- HELP FUNCTIONS ------------------------------------------------------

function setFields=dpxWhichSetFields(obj)
    % SETFIELDS=dpxWhichSetFields(OBJ) SETFIELDS contains the names of
    % fields in OBJ that can be set. Jacob 20140528 Major overhaul
    % 20161221. Before, i would try setting the property and conclude it
    % was not-settable in case an error was thrown. Now explicitily testing
    % if the property is public. This is obviously much more elegant, but
    % it is also different in that any set functions that may be defined
    % for a property no longer gets called this way.
    
    allFields=fieldnames(obj);
    okToSet=true(numel(allFields),1);
    for i=1:numel(allFields)
        prp=findprop(obj,allFields{i});
        okToSet(i)=strcmp(prp.SetAccess,'public');
    end
    setFields=allFields(okToSet);
end
