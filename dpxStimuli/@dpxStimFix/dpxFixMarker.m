classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxFixMarker < dpxBasicStim
    
    properties (Access=public)
        shape;
        RGBAfrac;
    end
    properties (Access=private)
    end
    methods
        function S=dpxFixMarker
            S.shape='dot';
            S.wDeg=.25;
            S.hDeg=.25;
            S.RGBAfrac=[1 0 0 1];
        end
        function init(S,physScrVals)
            if nargin~=2 || ~isstruct(physScrVals)
                error('Needs get(dpxStimWindow-object) struct');
            end
            S.type='dpxFixMarker';
            S.winCntrXYpx = [physScrVals.widPx/2 physScrVals.heiPx/2];
            S.xPx = S.xDeg * physScrVals.deg2px;
            S.yPx = S.yDeg * physScrVals.deg2px;
            S.rgba = S.RGBAfrac * physScrVals.whiteIdx;
            S.wPx = S.wDeg * physScrVals.deg2px;
            S.hPx = S.hDeg * physScrVals.deg2px;
            S.onFlip = S.onSecs * physScrVals.measuredFrameRate;
            S.offFlip = (S.onSecs + S.durSecs) * physScrVals.measuredFrameRate;
            S.physScrVals = physScrVals;
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
    if strcmpi(S.physScrVals.stereoMode,'mono')
        Screen('DrawDots',windowPtr,[S.xPx;S.yPx],diam,S.rgba(:),S.winCntrXYpx,2);
    elseif strcmpi(S.physScrVals.stereoMode,'mirror')
        for buffer=0:1
            Screen('SelectStereoDrawBuffer', windowPtr, buffer);
            Screen('DrawDots',windowPtr,[S.xPx;S.yPx],diam,S.rgba(:),S.winCntrXYpx,2);
        end
    else
        error(['Unknown stereoMode ''' S.stereoMode '''.']);
    end
end
