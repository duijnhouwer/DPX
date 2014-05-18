function E=jdPTBgetGeneralInfo(callerscriptfilename)
    % Collect general information about subject, script, and setup
    % Typical usage:
    %   E=jdPTBgetGeneralInfo([mfilename('fullpath') '.m']);
    % Jacob, 2014-05-17
    E.subjectID=upper(input('Subject ID > ','s'));
    if isempty(E.subjectID)
        E.subjectID='0';
    end
    E.date=datestr(now,'yyyy-mmm-dd, HH:MM:SS');
    E.scriptinfo=getInfoCurrentScript(callerscriptfilename);
    [~,E.psychtoolboxversion]=PsychtoolboxVersion;
    E.openglinfo=opengl('data');
    E.computer=computer;
end

function scriptinfo=getInfoCurrentScript(callerscriptfilename)
    % Get all the lines of this file for future reference
    scriptinfo.name=callerscriptfilename;
    fid=fopen(scriptinfo.name,'r');
    tline = fgetl(fid);
    nLines=0;
    while ischar(tline)
        nLines=nLines+1;
        scriptinfo.line{nLines}=tline;
        tline = fgetl(fid);
    end
    fclose(fid);
end