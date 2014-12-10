function dpxSetLastDirStr(dirstr)
    
    if nargin==0
        dirstr=pwd;
    end
    
    try
        save(fullfile(tempdir,'matlabDpxLastdirstr.mat'),'dirstr');
    catch ME
        warning('Unable to update ''matlabDpxLastdirstr.mat''.');
        disp(ME.message);
    end

    if false
        if nargin==0
            dirstr=pwd;
        end
        try
            p=regexp(userpath,';','split');
            save(fullfile(p{1},'.matlabDpxLastdirstr.mat'),'dirstr');
        catch me
            warning('Unable to update .matlabDpxLastdirstr');
        end
    end
end