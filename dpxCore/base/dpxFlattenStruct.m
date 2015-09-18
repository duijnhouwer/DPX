function f=dpxFlattenStruct(s)   
    
    % f=dpxFlattenStruct(s)   
    %
    % Flatten a nested structure ('.' levels replaced by '_')
    % Jacob, 2014-05-26
    %
    % EXAMPLE
    %    s.a=1;
    %    s.b.a=2;
    %    s.b.b=3;
    %    s.c.a.a=4;
    %    s.cheese='yummie';
    %    f=dpxFlattenStruct(s)
    %   >> 
    %    f = 
    %          a: 1
    %        b_a: 2
    %        b_b: 3
    %      c_a_a: 4
    %     cheese: 'yummie'

    
    if nargin==0 || ~isstruct(s)
        error('input should be struct');
    end
    f=flatten(s);
end

function f=flatten(s)
    fn=fieldnames(s);
    f=struct;
    for i=1:numel(fn)
        if ~isstruct(s.(fn{i}))
            f.(fn{i})=s.(fn{i});
        else
            tmp=flatten(s.(fn{i})); % recursion
            f=dpxMergeStructs({f,tmp},{'',[fn{i} '_']});
        end
    end
end