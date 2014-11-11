function S=dpxStructMakeSingleValued(S)
    
    % make the values of the fields in structure S single valued (i.e., so
    % that numel(S.somefield)==1 is true;
    
    fn=fieldnames(S);
    for i=1:numel(fn)
        if numel(S.(fn{i}))~=1 || ischar(S.(fn{i}))
            S.(fn{i})={S.(fn{i})};
        end
    end
end