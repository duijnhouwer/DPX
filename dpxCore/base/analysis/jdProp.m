function out=jdProp(b,optStr)
    
    % out=jdProp(b,optStr)
    %
    % Calcute proportion of true (1) in logical (0,1-numerical) arrays.
    % Optionally return as string to include in command line output
    %
    % EXAMPLES
    % b=[0 0 1 1 1];
    % jdProp(b)
    %   ans = 0.6
    % jdProp(b,'/')
    %   ans = 3/5
    % jdProp(b,' of ')
    %   ans = 3 of 5
    % jdProp(b,'%')
    %   ans = 60%
    %
    % Jacob 2016-02-10
    
    narginchk(1,2);
    if ~islogical(b)
        if sum(b==0 | b==1)~=numel(b) % works for logicals too but 'islogical' is much faster
            error('Input should be logicals or 0 and 1 numericals');
        end
    end
    if nargin==1
        out=sum(b)/numel(b);
    else
        if ~ischar(optStr)
            error('optStr must be a string');
        end
        if numel(optStr)==1 && optStr=='%'
            out = [num2str(sum(b)/numel(b)*100,'%.0f') '%'];
        elseif ~isnan(str2double(optStr)) % '2'
            format = ['%.' num2str(round(str2double(optStr))) 'f'];
            out = num2str(sum(b)/numel(b),format);
        else
            out = sprintf('%d%s%d',sum(b),optStr,numel(b));
        end
    end
end
        
