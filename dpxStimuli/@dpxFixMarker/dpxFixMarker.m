classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxFixMarker < dpxBasicStim
    
    properties (Access=public)
        shape='dot';
        wDeg=.25;
        hDeg=.25;
        RGBAfrac=[1 0 0 1];
    end
    properties (Access=private)
        xyPx;
        wPx;
        hPx;
        onFlip;
        offFlip;
        flipCounter=0;
        stereoMode;
        scrCenterXYpx;
    end
    methods
        function S=dpxFixMarker
        end
        function init(S,physScrValues)
            if nargin~=2 || ~isstruct(physScrValues)
                error('Needs get(dpxStimWindow-object) struct');
            end
            S.type='dpxFixMarker';
            S.scrCenterXYpx = [physScrValues.widPx/2 physScrValues.heiPx/2];
            S.xyPx = [S.xDeg S.yDeg];
            S.rgba = S.RGBAfrac * physScrValues.whiteIdx;
            S.wPx = S.wDeg * physScrValues.deg2px;
            S.hPx = S.hDeg * physScrValues.deg2px;
            S.onFlip = S.onSecs * physScrValues.measuredFrameRate;
            S.offFlip = (S.onSecs + S.durSecs) * physScrValues.measuredFrameRate;
            S.stereoMode = physScrValues.stereoMode;
            S.flipCounter=0;
        end
        function draw(S,windowPtr)
            S.flipCounter=S.flipCounter+1;
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            else
                if strcmpi(S.shape,'dot')
                    drawDot(S,windowPtr);
                elseif strcmpi(S.shape,'cross')
                    error('To be implemented');
                else
                    error(['Unknown shape ''' S.shape '''.']);
                end
            end
        end
    end
end

function drawDot(S,windowPtr)
    diam=max(1,max(S.wPx,S.hPx));
    if strcmpi(S.stereoMode,'mono')
        Screen('DrawDots',windowPtr,S.xyPx(:),diam,S.rgba(:),S.scrCenterXYpx,2);
    elseif strcmpi(S.stereoMode,'mirror')
        for buffer=0:1
            Screen('SelectStereoDrawBuffer', windowPtr, buffer);
            Screen('DrawDots',windowPtr,S.xyPx(:),diam,S.rgba(:),S.scrCenterXYpx,2);
        end
    else
        error(['Unknown stereoMode ''' S.stereoMode '''.']);
    end
end
