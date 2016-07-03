function fnames=rdDpxFileInput()
f=dbstack; if numel(f)==2; par=f(2); 
parDir=which(par.file); parDir=parDir(1:end-numel(par.file)); cd(parDir)
else par.name=[]; par.file='.mat';
end


fileName=['.DPXLastfnames' par.name '.mat'];

if exist(fileName,'file')
    load(fileName)
    if ~isempty(fnames)
        disp(['Found DPX Last filenames file for experiment ' par.name]);
        disp(['First file: ' fnames{1}])
    if strcmpi(input('Use it? : [Y/N] >>>','s'),'y')
    else
        disp(['you pressed anything but [Y]es'])
        if strcmpi(input('saving new DPX last filesnames file\n Overwrite old? : [Y/N] >>>','s'),'y')
            clear fnames
            delete(fileName)
        else
            fnames=dpxUIgetFiles;
        end
    end
    else 
        clear fnames
    end
end
if ~exist('fnames','var')
    fnames=dpxUIgetFiles;
    save(fileName,'fnames')
end
end


