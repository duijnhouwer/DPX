function str=dpxCamelCase(varargin)
    
    % str=dpxCamelCase(varargin)
    %
    % EXAMPLE
    %   >> str=dpxCamelCase('the','final','straw')
    %   str =
    %   theFinalStraw
    %
    % Jacob, 2015-06-26
    
    % check the input
    for i=1:nargin
        if ~ischar(varargin{i})
            error('Inputs must all be strings');
        end
    end
    %
    str='';
    for i=1:nargin
        a=varargin{i};
        if ~isempty(a) && i>1
            a(1)=upper(a(1));
        end
        str=[str a];
    end
end