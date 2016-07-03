function checkName()

fname = rdDpxFileInput;
for f=1:numel(fname);
    DPXD = dpxdLoad(fname{f});
    
    if isempty(DPXD)
        continue;
    end
    
    badName = {};
    if numel(unique(DPXD.exp_subjectId)) ~= 1;
        badName(end+1) = {strjoin(unique(DPXD.exp_subjectId))};
        fprintf('bad subject name: %s \n',badName{end})
        newName = input('Type a new name:','s');
        
        for n = 1:numel(DPXD.exp_subjectId);
            DPXD.exp_subjectId{n} = newName;
        end
        
        fprintf('\nChanged names from : %s\nTo: %s\n\n',badName{end},newName);
        choice = [];
        
        while ~any([strcmpi(choice,'Y'),strcmpi(choice,'N')])
            if ~isempty(choice);
                disp('Wrong input given, say Y or N');
            end
            choice = input('Save this change? Y/N:','s');
        end
        
        save(fname{f},'DPXD')
        
        fprintf('Replaced file ...%s\n\n',fname{f}(end-50:end));
       
    end
end
    
if isempty(badName)
    disp('no bad subject names!');
end