function [filename]=jdPTBsaveExperiment(E,optionstr,windowPtr)
    % Generalized save function for all jdPTB experiments
    % DATA is a struct which should at least contain the field:
    %       E.mainscript.name
    %       E.outputfolder: a string
    %       E.subjectID: a string
    %       E.physScr.oldVerbosityLevel
    %       E.physScr.scrNr
    %       E.physScr.oldGammaTab
    %
    % and something worth saving of course...
    try
        if nargin==1 || isempty(optionstr)
            optionstr='recovery';
            windowPtr=[];
        elseif nargin==2
            windowPtr=[];
        end
        expName=E.mainscript.name; % should not have an extension
        if ~isempty(strfind(lower(optionstr),'intermediate'))
            filename=saveRecovery(E,expName);
        elseif ~isempty(strfind(lower(optionstr),'crash'))
            filename=saveRecovery(E,expName);
            jdPTBendExperiment;
        elseif ~isempty(strfind(lower(optionstr),'final'))
            if isempty(E.subjectID)
                E.subjectID='0';
            end
            if ~exist(E.outputfolder,'file')
                mkdir(E.outputfolder);
            end
            filename=fullfile(E.outputfolder,[expName '_' E.subjectID '_' datestr(now,'yyyy-mm-dd-HH-MM-SS') '.mat']);
            save(filename,'E');
            if ~isempty(windowPtr) && ~isempty(strfind(lower(optionstr),'noendtextscr'))
                showFinalTextScreen(windowPtr,filename);
            end
            jdPTBendExperiment;
        else
            jdPTBunknown('optionstr',optionstr);
        end
        disp(['Saved data to ''' filename '''']);
    catch me
        filename=saveRecovery(E,'unknownExp');
        disp(['Saved data to ''' filename '''']);
        jdPTBerror(me);
    end
end


function filename=saveRecovery(E,expName) %#ok<INUSL>
    try
        if ispc
            filename=['C:\temp\recovery_' expName '.mat'];
        elseif ismac || isunix
            filename=['~/recovery_' expName '.mat'];
        else
            filename=['recovery_' expName '.mat'];
        end
        save(filename,'E');
    catch me
        jdPTBerror(me);
    end
end


function showFinalTextScreen(windowPtr,filename)
    try
        if nargin==1
            str='[-:  T H E   E N D  :-]';
        else
            str=['[-:  T H E   E N D  :-]\n\nThe data has been saved to:\n' filename];
        end
        jdPTBdisplayText(windowPtr,str,'rgbback',[127 127 127],'rgb',[255 255 255]);
    catch me
        jdPTBerror(me);
    end
end

