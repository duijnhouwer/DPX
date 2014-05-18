function [filename,crashdump]=jdPTBsaveData(data)
    % Generalized save function for all jdPTB experiments
    % DATA is a struct which should at least contain the field:
    %       data.outputfolder: a string
    %       data.subjectID: a string
    % and something worth saving of course...
    
    st=dbstack; % get the functions that called this one
    scriptname=st(end).file; % this would be the current experiment
    scriptname=scriptname(1:find(scriptname=='.',1,'last')-1); % remove extension (.m)
    crashdump=false;
    try
        if isempty(data.subjectID)
            data.subjectID='0';
        end
        if nargin==1
            if ~exist(data.outputfolder,'file')
                mkdir(data.outputfolder);
            end
            filename=fullfile(data.outputfolder,[scriptname '_' data.subjectID '_' datestr(now,'yyyy-mm-dd-HH-MM-SS') '.mat']);
        end
        save(filename,'data');      
    catch me
        disp(me);
        if ispc
            filename=['C:\temp\recovery_' scriptname '.mat'];
        else
            filename=['~/recovery_' scriptname '.mat'];
        end
        save(filename,'data');
        crashdump=true;
    end
    disp(['Saved data to ''' filename '''']);
end