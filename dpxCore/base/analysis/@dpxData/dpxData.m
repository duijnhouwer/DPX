classdef dpxData < hgsetget
    
    % dpxData help here///
    % Jacob Duijnhouwer 2016-01-19
    
    properties (GetAccess=public,SetAccess=public)
        data@struct; % The internal data container
    end
    properties (GetAccess=public,SetAccess=protected)
        N@double; % Number of data
        nFields@double; % Number of fields (properties)
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function D=dpxData(dpxdStruct)
            narginchk(1,3);
            % Create a dpxData object. Optional input: a DPXD-struct.
            if nargin==0
                D.data=struct;
            else
                [ok,err]=dpxdIs(dpxdStruct);
                if ok
                    D.N=dpxdStruct.N;
                    D.data=rmfield(dpxdStruct,'N');
                else 
                    error(err);
                end
            end
        end
        function disp(D)
            if numel(D)==1
                disp(['  <a href="matlab:doc dpxData">dpxData</a>' sprintf('(%dx%d)',D.nFields,D.N) ':']);
                D.browseFields(1);
            else
                str=sprintf('%dx',size(D));
                str(end)=[];
                disp(['  ' str ' <a href="matlab:doc dpxData">dpxData</a> array:']);
                for i=1:numel(D)
                    fprintf('\t%s(%dx%d)',class(D(i)),D(i).nFields,D(i).N);
                end
                fprintf('\n');
            end
        end
        function DPXD=toDpxd(D)
            % Convert to (old-style) DPXD-struct;
            DPXD=D.data;
            for i=1:numel(DPXD) 
                DPXD(i).N=D(i).N;
            end
        end
        function fn=fieldnames(D,varargin)
            [depth,filtStr]=D.parseDepthFiltStr(varargin{:});
            fn=fieldnames(D.data);
            fn(strcmp(fn,'N'))=[];
            if ~isempty(filtStr)
                fn(~strncmp(fn,filtStr,numel(filtStr)))=[];
            end
            if depth>0
                for i=1:numel(fn)
                    idx=find(fn{i}=='_',depth);
                    if ~isempty(idx) && numel(idx)>=depth
                        fn{i}=fn{i}(1:idx(end));
                    end
                end
            end
            fn=unique(fn); % also unique all fields--sorts them
        end
        function browseFields(D,varargin)
            narginchk(1,3);
            [depth,filtStr]=D.parseDepthFiltStr(varargin{:});
            fn=D.fieldnames(depth,filtStr);
            str=fn;
            str=dpxRightAlign(str);
            for i=1:numel(fn)
                if fn{i}(end)=='_'
                    type='...';
                else
                    szStr=[num2str(size(D.data.(fn{i}),1)) 'x' num2str(size(D.data.(fn{i}),2))];
                    if iscell(D.data.(fn{i}))
                        type=['{' szStr ' cell}'];
                    else
                        type=['[' szStr ' ' class(D.data.(fn{i})) ']'];
                    end
                end
                str{i}=sprintf('\t%s',[ str{i} ': ' type]);
            end
            disp(char(str));
        end
        function D=annex(D,varargin)
            % varargin contains the dpxData(s) to merge with the current dpxData-object
            % it can also contain a mode string, extract that first
            T=[D varargin{1}];
            D=dpxData.merge(T,varargin{2:end});
        end
        function addField(D,name,vals)
            if isfield(D,name)
                error(['Field ' name ' already exists.']);
            end
            if numel(vals)==1
                vals=repmat(vals,1,D.N);
            elseif numel(vals)~=D.N
                error('Number of values should be 1 or D.N');
            end
            D.data.(name)=vals;
        end
        function setField(D,name,vals)
            if ~isfield(D,name)
                error(['Field ' name ' doesn''t exist.']);
            end
            if numel(vals)==1
                vals=repmat(vals,1,D.N);
            elseif numel(vals)~=D.N
                error('Number of values should be 1 or D.N');
            end
            D.data.(name)=vals;
        end
    end
    methods (Access=protected)
        function [depth,filtStr]=parseDepthFiltStr(varargin)
            depth=0;
            nr=find(cellfun(@isnumeric,varargin));
            if ~isempty(nr)
                depth=varargin{nr};
            end
            filtStr='';
            str=find(cellfun(@ischar,varargin));
            if ~isempty(str)
                filtStr=varargin{str};
            end
        end
    end
    methods (Static)
        function M=merge(varargin)
            % varargin contains the dpxData(s) to merge with the current dpxData-object
            % it can also contain a mode string, extract that first
            p=inputParser;
            p.addOptional('mode','intersect',@(x)any(strcmpi(x,{'concat','intersect','intersectwarn','setxor'})));
            p.parse(varargin{cellfun(@ischar,varargin)});
            varargin(strcmp(varargin,'mode'))=[];
            varargin(strcmp(varargin,p.Results.mode))=[];
            if numel(varargin)==0
                error('Nothing to merge.');
            elseif numel(varargin)>1
                error('Too many input arguments.');
            elseif ~isa(varargin{1},'dpxData')
                error('Input must be of class dpxData.');
            end
            T=cellfun(@(x)x.toDpxd,num2cell(varargin{1}),'UniformOutput',false);
            M=dpxdMerge(T,'mode',p.Results.mode);
            M=dpxData(M);
        end
    end
    methods
        function set.data(D,value)
            D.data=value;
            D.nFields=numel(fieldnames(value)); %#ok<MCSUP>
            if std(cellfun(@numel,struct2cell(D.data)))>0
                error('All fields must the same number of elements.');
            end
        end
    end
end