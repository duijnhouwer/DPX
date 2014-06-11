function [b,n,fields]=dpxTblIs(T,varargin)

%  [b n fields]=dpxTblIs(t,varargin)
% Checks whether input t is a TblStruct.
% A TblStruct is a struct whose members are all of equal length
% except for the special and required field 'N' which contains that length
% Arguments:
% p.addRequired('t');
% p.addOptional('verbosity',0,@isnumeric);

%%% Handle varargin list %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('t');
p.addOptional('verbosity',0,@isnumeric); % 0 do nothing, >=1, disp problem, >=2 + stop for debugging 
p.parse(T,varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b=true;

% Check that it is a struct
% done in inputParser

% Check that it has the required N field
if ~isfield(T,'N')
   b=false;
   n=[];
   fields=[];
   if p.Results.verbosity==1
       warning('Not a dpxTbl because N field is missing.');
   end
   if p.Results.verbosity>=2
       error('Not a dpxTbl because N field is missing.');
   end
   return;
end

% Check that the length of all fields is equal (except fields 'N' and optional 'Cyclopean')
fields=fieldnames(T);
lengthsarray=[];
for i=1:length(fields)
    thisfield=fields{i};
    if strcmp(thisfield,'N') || strcmp(thisfield,'Cyclopean')
        continue;
    end
    lengthsarray(end+1)=length(T.(thisfield));
end
if std(lengthsarray)~=0
    b=false;
    n=[];
    if p.Results.verbosity>=1
       warning('Not a dpxTbl because not all lengths are equal.');
    end
    if p.Results.verbosity>=2
        keyboard;
    end
    return;
end  

% Check that the calculated length of is N
if lengthsarray(1)~=T.N
    b=false;
    n=[];
    if p.Results.verbosity>=1
        warning('Not a dpxTbl because the field lengths are not of the length specified in N.');
    end
    if p.Results.verbosity>=2
        keyboard;
    end
    return;
end

% Check that the pointers in the optional Cyclopean field have a
% corresponding data field
if any(strcmpi(fields,'Cyclopean'))
    if numel(T.Cyclopean.pointers)~=T.N
        error('Number of pointers in Cyclopean substruct should equal dpxTbls N');
    end
    uPointers=unique(T.Cyclopean.pointers);
    if min(uPointers)~=1 || any(diff(uPointers)~=1)
        error('Pointers in cyclopean substruct should be consecutive intergers starting from 1');
    elseif numel(T.Cyclopean.data)~=numel(uPointers)
        error('Number of pointers does not match number of data fields in Cyclopean substruct!');
    end
end

