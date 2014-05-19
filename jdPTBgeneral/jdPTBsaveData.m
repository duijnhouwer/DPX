function [filename]=jdPTBsaveData(data,optionstr)
    % Generalized save function for all jdPTB experiments
    % DATA is a struct which should at least contain the field:
    %       data.outputfolder: a string
    %       data.subjectID: a string
    % and something worth saving of course...
    if nargin==1,
        optionstr='final';
    end
    st=dbstack; % get the functions that called this one
    scriptname=st(end).file; % this would be the current experiment
    scriptname=scriptname(1:find(scriptname=='.',1,'last')-1); % remove extension (.m)
    try
        if strfind(optionstr,'final')
            if isempty(data.subjectID)
                data.subjectID='0';
            end
            if ~exist(data.outputfolder,'file')
                mkdir(data.outputfolder);
            end
            filename=fullfile(data.outputfolder,[scriptname '_' data.subjectID '_' datestr(now,'yyyy-mm-dd-HH-MM-SS') '.mat']);
            save(filename,'data');
        elseif strfind(optionstr,'recovery')
            filename=saveRecovery(scriptname);
        else
            jdPTBerror(['Can''t parse optionstr ''' optionstr '''.']);
        end
    catch me
        filename=saveRecovery(data,scriptname);
        jdPTBerror(me.message);
    end
    disp(['Saved data to ''' filename '''']);
end

function filename=saveRecovery(data,scriptname) %#ok<INUSL>
    try
        if ispc
            filename=['C:\temp\recovery_' scriptname '.mat'];
        elseif ismac || isunix 
            filename=['~/recovery_' scriptname '.mat'];
        else 
            filename=['recovery_' scriptname '.mat'];
        end
        save(filename,'data');
    catch me
        jdPTBerror(me.message);
    end
end

