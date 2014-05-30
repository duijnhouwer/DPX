function s=dpxGetSetables(obj)
    % Like get(obj) but only fields with get AND set access are returned
    % Jacob 20140528
    fields=dpxWhichSetFields(obj);
    for i=1:numel(fields)
        s.(fields{i})=obj.(fields{i});
    end
end