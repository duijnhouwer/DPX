% Part of Duijnhouwer-Psychtoolbox-Experiments
% Jacob, 2014-05-16

function [E,windowPtr]=jdPTBprepExperiment
    E=jdPTBgetGeneralInfo([mfilename('fullpath') '.m']);
    [E.conditions,E.nBlocks,E.instruction,E.outputfolder,setup]=rdkSettings;
    if ~strcmpi(E.subjectID,'0')
        warning('off'); %#ok<WNOFF>
        HideCursor;
    end
    [windowPtr,E.physScr]=openStimWindow('winRect',[],'hardware',setup); % physScr contains info on all physical display properties, windowPtr is a pointer to window
end

function [windowPtr,physScr]=openStimWindow(varargin) 
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParamValue('winRect',[],@(x)isempty(x) || isnumeric(x) && numel(x)==4); % [] default to full screen
    p.addParamValue('hardware', struct('screenWidHeiMm',[],'screenDistMm',500,'gammaCorrection',1),@isstruct);
    p.parse(varargin{:});
    physScr.oldVerbosityLevel=Screen('Preference','Verbosity',3);
    Screen('Preference','VisualDebuglevel',0);
    Screen('Preference','SkipSyncTests',0);
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
    physScr.whiteIdx=WhiteIndex(physScr.scrNr);
    physScr.blackIdx=BlackIndex(physScr.scrNr);
    physScr.distMm=p.Results.hardware.screenDistMm;
    physScr.mm2px=physScr.widPx/physScr.widMm;
    physScr.distPx=round(physScr.distMm*physScr.mm2px);
    physScr.scrWidDeg=atan2d(physScr.widMm/2,physScr.distMm)*2;
    physScr.deg2px=physScr.widPx/physScr.scrWidDeg;
    [windowPtr, physScr.winRect]=Screen('OpenWindow',physScr.scrNr,0,p.Results.winRect); %[0 0 physScr.widPx physScr.heiPx],[],2);
    physScr.frameDurSecs=Screen('GetFlipInterval',windowPtr);
    Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    physScr.oldGammaTab=Screen('ReadNormalizedGammaTable',physScr.scrNr);%#ok<*NASGU>
    physScr.gammaTab=repmat((0:1/WhiteIndex(physScr.scrNr):1)',1,3).^p.Results.hardware.gammaCorrection;
    physScr.gamma=p.Results.hardware.gammaCorrection;
    Screen('LoadNormalizedGammaTable',physScr.scrNr,physScr.gammaTab);
end