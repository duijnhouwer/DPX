classdef dpxStimDot < dpxAbstractStim
    
    properties (Access=public)
        shape;
        RGBAfrac;
    end
    properties (Access=private)
        RGBA;
    end
    methods
        function S=dpxStimDot
            S.wDeg=.15;
            S.hDeg=.15;
            S.RGBAfrac=[1 0 0 1];
            S.durSec=Inf;
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.RGBA = S.RGBAfrac * S.scrGets.whiteIdx;
        end
        function myDraw(S)
            wPtr=S.scrGets.windowPtr;
            diam=max(1,S.wPx);
            if strcmpi(S.scrGets.stereoMode,'mono')
                Screen('DrawDots',wPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
            elseif strcmpi(S.scrGets.stereoMode,'mirror')
                for buffer=0:1
                    Screen('SelectStereoDrawBuffer', wPtr, buffer);
                    Screen('DrawDots',wPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
                end
            else
                error(['Unknown stereoMode ''' S.stereoMode '''.']);
            end
        end
    end
end


function drawCross(S)
    wPtr=S.scrGets.windowPtr;
    crossXY=max(1,S.wPx);
    if strcmpi(S.scrGets.stereoMode,'mono')
        Screen('DrawLines',wPtr,[0 0 S.xPx-crossXY S.yPx+crossXY;S.xPx-crossXY S.yPx+crossXY 0 0] ...
            ,S.crossW,S.RGBA(:),S.winCntrXYpx);
    elseif strcmpi(S.scrGets.stereoMode,'mirror')
        for buffer=0:1
            Screen('SelectStereoDrawBuffer', wPtr, buffer);
            Screen('DrawLines',wPtr,[0 0 S.xPx-crossXY S.yPx+crossXY;S.xPx-crossXY S.yPx+crossXY 0 0] ...
                ,S.crossW,S.RGBA(:),S.winCntrXYpx);
        end
    else
        error(['Unknown stereoMode ''' S.stereoMode '''.']);
    end
end