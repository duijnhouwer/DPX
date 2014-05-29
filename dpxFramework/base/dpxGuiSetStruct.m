function [p,changed] = dpxGuiSetStruct(p,prompt)
% function p = guisetstruct(p,prompt)
% Pass a struct; a list edit box will open with the current values of the
% fields in the struct, the user can edit these, then click ok, and the
% function will return the updated struct. 
% Useful in GUIs where a (varying) number of parameters needs to be set.
% INPUT
% p  = A struct with fields that have numeric or char data.
%       Fields in the struct that are not numeric or char, cannot be changed.
%       (The value in the dialog will be 'FIXED')
% prompt = Optional title for dialog box.
% OUTPUT
% p = Updated struct.
%
% BK - May 2010
if nargin<2
    prompt = 'Parameter Settings';
end
parms = fieldnames(p);
org = struct2cell(p);

current = struct2cell(p);
out = cellfun(@(x)(~(ischar(x)||isnumeric(x) ||islogical(x)) || size(x,1)>1),current);

islog  = cellfun(@(x)(islogical(x)),current);
isnum = cellfun(@(x)(isnumeric(x)),current);
current(isnum|islog) = cellfun(@(x)(strtrim(sprintf('%g ',x))),current(isnum | islog),'Uniform',false);

[current{out}] = deal('FIXED');

options.WindowStyle = 'modal';
options.Resize = 'on';
options.Interpreter = 'none';

[answer] = inputdlg(parms,prompt,1,current,options);

if isempty(answer)
    % Cancel. No Change
    changed = false;
else
    answer(isnum) = cellfun(@(x)(str2num(x)),answer(isnum),'Uniform',false); %#ok<ST2NM>
    answer(islog) = cellfun(@(x)(logical(str2num(x))),answer(islog),'Uniform',false); %#ok<ST2NM>
    [answer{out}] = deal(org{out});
    p = cell2struct(answer,parms);
    changed = true;    
end
