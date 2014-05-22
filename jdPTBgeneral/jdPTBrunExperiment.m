function E=jdPTBrunExperiment(setting2stimFx,showStimFx)
    %  E=jdPTBrunExperiment(setting2stimFx,showStimFx)
    %
    % setting2stimFx and showStimFx are function handles to custom,
    % experiment specific settings to condition coverter and showStimulus
    % function
    %
    try
        [E,windowPtr]=prepareExperiment;
        conditionList=mod(randperm(E.nBlocks*numel(E.conditions)),numel(E.conditions))+1;
        for tr=1:numel(conditionList)
            condNr=conditionList(tr);
            stim=setting2stimFx(E.conditions(condNr),E.physScr);
            Screen('FillRect',windowPtr,stim.backRGBA);
            if tr==1
                jdPTBdisplayText(windowPtr,E.instruction.start,'rgbaback',stim.backRGBA);
            elseif mod(tr,E.instruction.pause.nTrials)==0
                jdPTBsaveExperiment(E,'intermediate');
                jdPTBdisplayText(windowPtr,E.instruction.pause.txt,'rgbaback',stim.backRGBA);
            end
            [esc,timing,resp]=showStimFx(E.physScr,windowPtr,stim);
            if esc
                disp('Escape pressed');
                break; % stop the experiment
            else
                E.trials(tr).condition=condNr;
                E.trials(tr).respNum=resp.number;
                E.trials(tr).respSecs=resp.timeSecs;
                E.trials(tr).startSecs=timing.startSecs;
                E.trials(tr).stopSecs=timing.stopSecs;
            end
        end
    catch me
        jdPTBsaveExperiment(E,'crash');
        error(me.message);
    end
    jdPTBsaveExperiment(E,'final',windowPtr);
end



function [E,windowPtr]=prepareExperiment
    % EXAMPLES:
    %   prepExperiment without any arguments sets up experiment in
    %   full screen mode
    %
    %   prepExperiment('winRect',[0 100 600 400]) to run in winRect,
    %   exclusively useful for debugging purposes
    %
    st=dbstack; % get the functions that called this one
    scriptname=st(end).file; % this is the name of the current experiment (the script that called prepExperiment)
    E=jdPTBgetGeneralInfo(scriptname);
    settingsFileName=[E.mainscript.name 'Settings'];
    [E.conditions,E.nBlocks,E.instruction,E.outputfolder,setup]=eval(settingsFileName);
    if ~strcmpi(E.subjectID,'0')
        warning('off'); %#ok<WNOFF>
        HideCursor;
    end
    ListenChar(2);
    GetSecs; % just to load MEX into memory
    KbCheck; % just to load MEX into memory
    [windowPtr,E.physScr]=openStimWindow('hardware',setup); % physScr contains info on all physical display properties, windowPtr is a pointer to window
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
    p.addParamValue('hardware', struct('screenWidHeiMm',[],'screenDistMm',500,'gammaCorrection',1,'stereoMode','mono','window',[]),@isstruct);
    p.parse(varargin{:});
    %
    if strcmpi(p.Results.hardware.stereoMode,'mono')
        ptbStereoCode=0;
    elseif strcmpi(p.Results.hardware.stereoMode,'mirror')
        ptbStereoCode=4;
    else
        jdPTBendExperiment
        keyboard;
    end
    if ischar(p.Results.hardware.window)
        if strcmpi(p.Results.hardware.window,'small')
            window=[0 0 400 300]+20; % small screen for debugging purposes
        else
            window=[]; % full screen
        end
    else
        window=p.Results.hardware.window;
    end
    %
    AssertOpenGL;
    scr=Screen('screens');
    physScr.scrNr=max(scr);
    if isempty(window)
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
    [windowPtr, physScr.winRect] = Screen('OpenWindow',physScr.scrNr,[0 0 255],window,[],2,ptbStereoCode); %[0 0 physScr.widPx physScr.heiPx],[],2);
    physScr.gamma = p.Results.hardware.gammaCorrection;
    jdPTBgammaCorrection('set',physScr.scrNr,physScr.gamma);
    physScr.frameDurSecs = Screen('GetFlipInterval',windowPtr);
    Screen('Preference','VisualDebuglevel',0);
    Screen('Preference','SkipSyncTests',0);
    Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
end

