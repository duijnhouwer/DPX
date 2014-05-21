% Part of Duijnhouwer-Psychtoolbox-Experiments
% Jacob, 2014-05-16

function [E,windowPtr]=jdPTBprepExperiment(varargin) 
    % EXAMPLES:
    %   jdPTBprepExperiment without any arguments sets up experiment in
    %   full screen mode
    %
    %   jdPTBprepExperiment('winRect',[0 100 600 400]) to run in winRect,
    %   exclusively useful for debugging purposes
    %
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParamValue('winRect',[],@(x)isempty(x) || isnumeric(x) && numel(x)==4); % [] default to full screen
    p.parse(varargin{:});
    st=dbstack; % get the functions that called this one
    scriptname=st(end).file; % this is the name of the current experiment (the script that called jdPTBprepExperiment)
    E=jdPTBgetGeneralInfo(scriptname);
    settingsFileName=[E.mainscript.name 'Settings'];
    [E.conditions,E.nBlocks,E.instruction,E.outputfolder,setup]=eval(settingsFileName);
    if ~strcmpi(E.subjectID,'0')
        warning('off'); %#ok<WNOFF>
        HideCursor;
    end
    [windowPtr,E.physScr]=openStimWindow('winRect',p.Results.winRect,'hardware',setup); % physScr contains info on all physical display properties, windowPtr is a pointer to window
end

%--- SUBFUNCTIONS -----------------------------------------------------

function E=jdPTBgetGeneralInfo(scriptname)
    % Collect general information about subject, script, and setup
    % Typical usage:
    %   E=jdPTBgetGeneralInfo([mfilename('fullpath') '.m']);
    % Jacob, 2014-05-17
    E.subjectID=upper(input('Subject ID > ','s'));
    if isempty(E.subjectID)
        E.subjectID='0';
    end
    E.date=datestr(now,'yyyy-mmm-dd, HH:MM:SS');
    E.mainscript.name=scriptname(1:find(scriptname=='.',1,'last')-1);
    E.mainscript.content=getInfoCurrentScript(scriptname);
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


function [windowPtr,physScr]=openStimWindow(varargin)
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParamValue('winRect',[],@(x)isempty(x) || isnumeric(x) && numel(x)==4); % [] default to full screen
    p.addParamValue('hardware', struct('screenWidHeiMm',[],'screenDistMm',500,'gammaCorrection',1),@isstruct);
    p.parse(varargin{:});
    GetSecs; % just to load MEX into memory
    AssertOpenGL;
    %HideCursor;
    scr=Screen('screens');
    physScr.scrNr=max(scr);
    if isempty(p.Results.winRect)
        [physScr.widPx, physScr.heiPx]=Screen('WindowSize',physScr.scrNr);
    else
        physScr.widPx = p.Results.winRect(3)-p.Results.winRect(1);
        physScr.heiPx = p.Results.winRect(4)-p.Results.winRect(2);
    end
    if isempty(p.Results.hardware.screenWidHeiMm)
        [physScr.widMm, physScr.heiMm]=Screen('DisplaySize',physScr.scrNr);
    else
        physScr.widMm = p.Results.hardware.screenWidHeiMm(1); %406;
        physScr.heiMm = p.Results.hardware.screenWidHeiMm(2); %305;
    end
    physScr.whiteIdx = WhiteIndex(physScr.scrNr);
    physScr.blackIdx = BlackIndex(physScr.scrNr);
    physScr.distMm = p.Results.hardware.screenDistMm;
    physScr.mm2px = physScr.widPx/physScr.widMm;
    physScr.distPx = round(physScr.distMm*physScr.mm2px);
    physScr.scrWidDeg = atan2d(physScr.widMm/2,physScr.distMm)*2;
    physScr.deg2px = physScr.widPx/physScr.scrWidDeg;
    [windowPtr, physScr.winRect] = Screen('OpenWindow',physScr.scrNr,0,p.Results.winRect); %[0 0 physScr.widPx physScr.heiPx],[],2);
    physScr.gamma = p.Results.hardware.gammaCorrection;
    jdPTBgammaCorrection('set',physScr.scrNr,physScr.gamma);
    physScr.frameDurSecs = Screen('GetFlipInterval',windowPtr);
    Screen('Preference','VisualDebuglevel',0);
    Screen('Preference','SkipSyncTests',0);
    Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
end