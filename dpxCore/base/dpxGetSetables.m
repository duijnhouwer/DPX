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
    % SETFIELDS=dpxWhichSetFields(OBJ)
    % SETFIELDS contains the names of fields in OBJ that can be set.
    % Jacob 20140528
    
    allFields=fieldnames(obj);
    okToSet=true(numel(allFields),1);
    for i=1:numel(allFields)
        try
            % Try setting this field, if it has protected setting, this
            % will cause an error that we will catch. This is actually an
            % ugly way to to this, depending on errors to happen always is.
            % Practically it's inconvenient because dbstop if all error
            % will stop here. Think of a better method someday ... 666
            obj.(allFields{i})=obj.(allFields{i});
         catch me
            if strcmpi(me.identifier,'MATLAB:class:SetProhibited')
                okToSet(i)=false;
            end
        end
    end
    setFields=allFields(okToSet);
end