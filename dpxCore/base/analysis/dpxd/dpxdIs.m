function b=dpxdIs(T,varargin)
    
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
    % Check that it is a struct
    if ~isstruct(T)
        b=false;
        if p.Results.verbosity==1
            warning('Not a DPXD because not a struct.');
            if p.Results.verbosity>=2
                keyboard;
            end
        end
        return;
    end
    % Check that it has the required N field
    if ~isfield(T,'N')
        b=false;
        if p.Results.verbosity==1
            warning('Not a DPXD because N field is missing.');
            if p.Results.verbosity>=2
                keyboard;
            end
        end
        return;
    end
    % Check that the lengths of all fields except field 'N' are equal 
    fields=fieldnames(T);
    fields=fields(~strcmp(fields,'N'));
    if isempty(fields)
        if T.N~=0
            b=false;
            if p.Results.verbosity>=1
                warning('Not a DPXD because if there are no fields other than N, N should be 0');
                if p.Results.verbosity>=2
                    keyboard;
                end
            end
            return;
        end
    end
    numelArray=zeros(size(fields));
    for i=1:length(fields)
        numelArray(i)=length(T.(fields{i}));
    end
    if std(numelArray)~=0
        b=false;
        if p.Results.verbosity>=1
            warning('Not a DXPD because not all data fields arrays have equal lengths.');
            if p.Results.verbosity>=2
                keyboard;
            end
        end
        return;
    end
    % Check that the calculated length of is N
    if numelArray(1)~=T.N
        b=false;
        if p.Results.verbosity>=1
            warning('Not a DPXD because the data field arrays don''t have N elements.');
            if p.Results.verbosity>=2
                keyboard;
            end
        end
        return;
    end
end

