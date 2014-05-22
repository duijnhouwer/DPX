function str=jdPTBunknown(valname,val)
    % str=jdPTBunknown(valname,val)
    % Jacob 2014-05-20
    %
    % Typical usage:
    %   if strcmpi(option,'option1')
    %       % doSomething
    %   elseif strcmpi(option,'option2')
    %       % doSomethingElse
    %   else
    %      jdPTBunknown('option',option)
    %   end
    %
    if ~ischar(valname)
         jdPTBerror(['First argument should be a string (name of variable).']);
    end
    if ~ischar(val)
        if isnumeric(val) || islogical(val)
            val=num2str(val);
        elseif iscell(val)
            val=num2str(val{:});
        else
            k=whos('val');
            jdPTBerror(['jdPTBunknown does not work for object ' valname ' because it''s of class ' k.class '.']);
        end
    end
    str=['Unknown ' valname ' option: ''' val '''.'];
    builtin('error',str);
end