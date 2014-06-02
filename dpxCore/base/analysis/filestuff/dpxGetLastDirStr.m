function dirstr=dpxGetLastDirStr

try 
    p=regexp(userpath,';','split');
    load(fullfile(p{1},'.matlabDpxLastdirstr.mat'));
catch
    dirstr=pwd;
end

if ~ischar(dirstr)
    dirstr=pwd;
end