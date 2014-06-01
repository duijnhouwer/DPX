classdef dpxStimFix < dpxBasicStim
    
    properties (Access=public)
        shape;
        RGBAfrac;
    end
    properties (Access=private)
        RGBA;
    end
    methods
        function S=dpxStimFix
            S.shape='dot';
            S.wDeg=.25;
            S.hDeg=.25;
            S.RGBAfrac=[1 0 0 1];
            S.durSec=2;
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.RGBA = S.RGBAfrac * S.physScrVals.whiteIdx;
        end
        function myDraw(S)
            if strcmpi(S.shape,'dot')
                drawDot(S);
            elseif strcmpi(S.shape,'cross')
                drawCross(S);
            else
                error(['Unknown shape ''' S.shape '''.']);
            end
        end
    end
end

function drawDot(S)
    wPtr=S.physScrVals.windowPtr;
    diam=max(1,max(S.wPx,S.hPx));
    if strcmpi(S.physScrVals.stereoMode,'mono')
        Screen('DrawDots',wPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
    elseif strcmpi(S.physScrVals.stereoMode,'mirror')
        for buffer=0:1
            Screen('SelectStereoDrawBuffer', wPtr, buffer);
            Screen('DrawDots',wPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
        end
    else
        error(['Unknown stereoMode ''' S.stereoMode '''.']);
    end
end

function drawCross(S) %#ok<INUSD>
    error('To be implemented');
end
