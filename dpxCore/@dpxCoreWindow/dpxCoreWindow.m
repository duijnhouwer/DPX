classdef (CaseInsensitiveProperties=true ...
        ,Description='a' ...
        ,DetailedDescription='ab') ...
        dpxCoreWindow < hgsetget
    
    properties (Access=public)
        winRectPx=[10 10 400 300];
        widHeiMm=[]; % leave [] for auto-detect
        distMm=600;
        interEyeMm=65;
        gamma=1;
        backRGBA=[.5 .5 .5 1];
        stereoMode='mono';
        SkipSyncTests=0;
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
        interEyePx=[]
        leftEyeXYZpx;
        rightEyeXYZpx;
        cyclopEyeXYZpx;
        limits=struct;
    end
    properties (Access=protected)
        scrNr;
        stereoCode;
    end
    methods (Access=public)
        function W=dpxCoreWindow
            % constructor
            AssertOpenGL;
            W=initValues(W);
        end
        function open(W)
            Screen('Preference','VisualDebuglevel',0);
            Screen('Preference','SkipSyncTests',W.SkipSyncTests);
            [W.windowPtr,W.winRectPx] = Screen('OpenWindow',W.scrNr,[0.5 0.5 0.5 1],W.winRectPx,[],2,W.stereoCode);
            W.measuredFrameRate = 1/Screen('GetFlipInterval',W.windowPtr);
            % Set the blend function so we can use antialiasing of dots and
            % lines.
            Screen('BlendFunction',W.windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
            % Query OpenGL about limits on parameters, this only works
            % after the window has been opened using Screen('OpenWindow')
            InitializeMatlabOpenGL(1); % this loads OpenGL constant labels as GL_XXX GLU_XXX etc.
            W.limits.GL_ALIASED_POINT_SIZE_RANGE=glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE);
            % Bump the priority of the matlab process
            priorityLevel=MaxPriority(W.windowPtr);
            Priority(priorityLevel);
        end
        %function clear(W)
        %    % clear the window to background color, unless the background
        %    % color is completely translucent (alpha==0)
        %    if ~isempty(W.windowPtr) && W.backRGBA(4)>0
        %        Screen('FillRect',W.windowPtr,W.backRGBA*W.whiteIdx);
        %    end
        %end
        function close(W)
            warning on %#ok<WNON>
            ShowCursor;
            set(W,'gamma',1);
            Screen('CloseAll');
            try
                ListenChar(0);
            catch me
                disp(me);
            end
            W.windowPtr=[];
        end
        function gui(W)
            dpxToolStimWindowGui(W);
        end
    end
    methods
        function set.winRectPx(W,value)
            if ~isempty(value) && (~isnumeric(value) && numel(value)==4)
                error('winRectPx needs to be empty ([]) or have 4 numerical values ([topleft.x topleft.y lowerright.x lowerright.y])');
            end
            W.winRectPx=value;
            initValues(W);
        end
        function set.distMm(W, value)
            if ~isnumeric(value)
                error('distMm needs to be numerical');
            end
            if ~isempty(W.windowPtr)
                error('Window already opened');
            end
            if value<0
                error('screen distance in mm should be positive');
            end
            W.distMm=value;
            initValues(W);
        end
        function set.gamma(W,value)
            if ~isnumeric(value) || isempty(value)
                error('gamma needs to be positive number (typically between 0.4 and 2)');
            end
            W.gamma=value;
            initValues(W);
        end
        function set.stereoMode(W,value)
            W.stereoMode=value;
            if strcmpi(W.stereoMode,'mono')
                W.stereoCode=0;
            elseif strcmpi(W.stereoMode,'mirror')
                W.stereoCode=4;
            else
                error(['Unknown stereoMode ''' W.stereoMode '''. Valid options are ''mono'' and ''mirror''']);
            end
            initValues(W);
        end
        function set.widHeiMm(W,value)
            if ~isempty(value) && numel(value)~=2 || ~isnumeric(value)
                error('widHeiMm needs two numerical values or be empty');
            end
            if ~isempty(W.windowPtr);
                error('Can''t set widHeiMm when window is already open');
            else
                W.widHeiMm=value;
                initValues(W);
            end
        end
        function set.backRGBA(W,value)
            if numel(value)~=4 || any(value>1) || any(value<0) || ~isnumeric(value) || isempty(value)
                error('backRGBA needs 4 numerical values between 0 and 1');
            else
                W.backRGBA=value;
            end
        end
        function set.interEyeMm(W,value)
            if isempty(value) || ~isnumeric(value) || value<0
                error('interEyeMm should be a positive number');
            end
            W.interEyeMm=value;
            initValues(W);
        end
    end
    methods (Access=private)
        function W=initValues(W)
            W.scrNr=max(Screen('screens'));
            if isempty(W.winRectPx)
                [W.widPx, W.heiPx]=Screen('WindowSize',W.scrNr);
                W.winRectPx=[0 0 W.widPx W.heiPx];
            else
                W.widPx = W.winRectPx(3)-W.winRectPx(1);
                W.heiPx = W.winRectPx(4)-W.winRectPx(2);
            end
            if isempty(W.widHeiMm)
                [w,h]=Screen('DisplaySize',W.scrNr);
                if strcmpi(W.stereoMode,'mirror')
                    w=w/2;
                end
                W.widHeiMm=[w h];
            end
            if strcmpi(W.stereoMode,'mirror')
                effectiveWidMm=W.widHeiMm(1)/2;
            else
                effectiveWidMm=W.widHeiMm(1);
            end
            W.whiteIdx = WhiteIndex(W.scrNr);
            W.blackIdx = BlackIndex(W.scrNr);
            W.mm2px = W.widPx/effectiveWidMm;
            W.distPx = round(W.distMm*W.mm2px);
            winWidDeg = atan2(effectiveWidMm/2,W.distMm)*2*180/pi;
            W.deg2px = W.widPx/winWidDeg;
            W.nominalFrameRate=Screen('NominalFrameRate',W.scrNr);
            W.interEyePx=W.interEyeMm*W.mm2px;
            W.leftEyeXYZpx=[-W.interEyePx/2;W.distPx;0];
            W.rightEyeXYZpx=[W.interEyePx/2;W.distPx;0];
            W.cyclopEyeXYZpx=[0;W.distPx;0];
            newGammaTab=repmat((0:1/WhiteIndex(W.scrNr):1)',1,3).^W.gamma;
            Screen('LoadNormalizedGammaTable',W.scrNr,newGammaTab);
        end
    end
end




