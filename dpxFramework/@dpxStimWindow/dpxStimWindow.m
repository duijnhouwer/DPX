classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxStimWindow < hgsetget
    
    properties (Access=public)
        stereoMode='mono';
        winRectPx=[];
        distMm=600;
        interEyeMm=65;
        gamma=1;
        widHeiMm=[]; % leave [] for auto-detect
        backRGBA=[.5 .5 .5 1];
    end
    properties (GetAccess=public,SetAccess=private)
        distPx;
        mm2px;
        deg2px;
        windowPtr;
        whiteIdx;
        blackIdx;
        nominalFrameRate;
        measuredFrameRate;
        widPx;
        heiPx;
    end
    properties (Access=private)
        scrNr;
        stereoCode;
    end
    methods (Access=public)
        function S=dpxStimWindow
            AssertOpenGL;
            S=initValues(S);
            Screen('Preference','VisualDebuglevel',0);
            Screen('Preference','SkipSyncTests',0);
        end
        function open(S)
            S.windowPtr = Screen('OpenWindow',S.scrNr,[0 0 255],S.winRectPx,[],2,S.stereoCode);
            dpxGammaCorrection('set',S.scrNr,S.gamma);
            S.measuredFrameRate = 1/Screen('GetFlipInterval',S.windowPtr);
            Screen('BlendFunction',S.windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
            HideCursor;
        end
        function clear(S)
            % clear the window to background color
            if ~isempty(S.windowPtr);
                Screen('FillRect',S.windowPtr,S.backRGBA*S.whiteIdx);
            end
        end
        function close(S)
            warning on %#ok<WNON>
            ShowCursor;
            dpxGammaCorrection('restore');
            Screen('CloseAll');
            ListenChar(0);
            S.windowPtr=[];
        end
    end
    methods
        function set.winRectPx(S,value)
            if numel(value)~=4 && ~isempty(value)
                error('winRectPx needs to be empty ([]) or have 4 values ([topleft.x topleft.y lowerright.x lowerright.y])');
            end
            S.winRectPx=value;
            initValues(S);
        end
        function set.distMm(S, value)
            if ~isempty(S.windowPtr)
                error('Window already opened');
            end
            if value<0
                error('screen distance in mm should be positive');
            end
            S.distMm=value;
            initValues(S);
        end
        function set.gamma(S,value)
            S.gamma=value;
            dpxGammaCorrection('set',S.scrNr,S.gamma);
            initValues(S);
        end
        function set.stereoMode(S,value)
            set.stereoMode=value;
            if strcmpi(S.stereoMode,'mono')
                S.stereoCode=0;
            elseif strcmpi(S.stereoMode,'stereo')
                S.stereoCode=4;
            else
                error(['Unknown stereoMode ''' S.stereoMode '''.']);
            end
            initValues(S);
        end
        function set.widHeiMm(S,value)
            if ~isempty(value) && numel(value)~=2
                error('widHeiMm needs two values');
            end
            if ~isempty(S.windowPtr);
                error('Can''t set widHeiMm when window is already open');
            else
                S.widHeiMm=value;
                initValues(S);
            end
        end
        function set.backRGBA(S,value)
            if numel(value)~=4 || any(value>1) || any(value<0)
                error('backgrRGBA needs 4 values between 0 and 1');
            else
                S.backgrRGBA=value;
            end
        end
    end
    methods (Access=private)
        function S=initValues(S)
            S.scrNr=max(Screen('screens'));
            if isempty(S.winRectPx)
                [S.widPx, S.heiPx]=Screen('WindowSize',S.scrNr);
                S.winRectPx=[0 0 S.widPx S.heiPx];
            else
                S.widPx = S.winRectPx(3)-S.winRectPx(1);
                S.heiPx = S.winRectPx(4)-S.winRectPx(2);
            end
            if isempty(S.widHeiMm)
                [w,h]=Screen('DisplaySize',S.scrNr);
                S.widHeiMm=[w h];
            end
            S.whiteIdx = WhiteIndex(S.scrNr);
            S.blackIdx = BlackIndex(S.scrNr);
            S.mm2px = S.widPx/S.widHeiMm(1);
            S.distPx = round(S.distMm*S.mm2px);
            scrWidDeg = atan2d(S.widHeiMm(1)/2,S.distMm)*2;
            S.deg2px = S.widPx/scrWidDeg;
            S.nominalFrameRate=Screen('NominalFrameRate',S.scrNr);
        end
    end
end
