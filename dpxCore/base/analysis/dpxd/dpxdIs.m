function [b,err]=dpxdIs(T,varargin)
    
    % b=dpxdIs(T,varargin)
    % Checks whether input T is a DPXD.
    % DPXD is a structure whose members have equal numbers of elements except
    % for the special and required field 'N' which contains that number.
    % Arguments:
    % p.addRequired('T');
    % p.addOptional('verbosity',0,@isnumeric);
    
    if nargin==0
        error('Not enough input arguments.');
    end
    %%% Handle varargin list %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('T');
    p.addOptional('verbosity',0,@isnumeric); % 0 do nothing, >=1, disp problem, >=2 + stop for debugging
    p.parse(T,varargin{:});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    b=true;
    err='';
    % Check that it is a struct
    if ~isstruct(T)
        b=false;
        err=explain('Not a DPXD because not a struct.',p.Results.verbosity);
        return;
    end
    % Check that it has the required N field
    if ~isfield(T,'N')
        b=false;
        err=explain('Not a DPXD because N field is missing.',p.Results.verbosity);
        return;
    end
    if numel(fieldnames(T))==1
        if T.N==0
            return;
        else
            b=false;
            err=explain('Not a DPXD because N must be 0 when there are no data-arrays (empty dpxd).',p.Results.verbosity);
            return;
        end
    end
    % Check that the lengths of all fields except field 'N' are equal 
    fields=fieldnames(T);
    fields=fields(~strcmp(fields,'N'));
    if isempty(fields)
        if T.N~=0
            b=false;
            err=explain('Not a DPXD because if there are no fields other than N, N should be 0',p.Results.verbosity);
            return;
        end
    end
    numelArray=zeros(size(fields));
    for i=1:length(fields)
        sz=size(T.(fields{i}));
        numelArray(i)=sz(2);
        if numel(sz)>9 % Max 9 dimensional
            b=false;
            err=explain('Not a DPXD because one data field has more than 9 dimensions'); 
            return;
        end    
    end
    if std(numelArray)~=0
        b=false;
        err=explain('Not a DXPD because not all data fields have an equal number of columns.',p.Results.verbosity);
        return;
    end
    % Check that the calculated length of is N
    if numelArray(1)~=T.N
        b=false;
        err=explain('Not a DPXD because the data field arrays don''t have N columns.',p.Results.verbosity);
        return;
    end
end

function str=explain(str,verbo)
    if verbo>=1
        warning(str);
        if verbo>=2
            keyboard;
        end
    end
end



