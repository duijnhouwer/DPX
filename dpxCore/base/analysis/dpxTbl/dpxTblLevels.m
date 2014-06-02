function [n]=dpxTblLevels(r,fieldname)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Handle varargin list
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('r', @isstruct);
p.addRequired('fieldname',@ischar);
p.parse(r,fieldname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(r,fieldname)
	str=sprintf('Error: Passed fieldname "%s" is not an existing field in dpxTbl.\nValid fieldnames are:',fieldname);
	disp(str);
	disp(fieldnames(r))
	error('(see above)');
end
vals=eval(['r.' fieldname]);
n=length(unique(vals));
