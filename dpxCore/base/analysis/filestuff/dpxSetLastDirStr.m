function dpxSetLastDirStr(dirstr)

if nargin==0
    dirstr=pwd;
end
try
    p=regexp(userpath,';','split');
	save(fullfile(p{1},'.matlabDpxLastdirstr.mat'),'dirstr');
catch me
	warning('Unable to update .matlabDpxLastdirstr');
end