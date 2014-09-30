classdef dpxStimCross < dpxAbstractStim
    
    properties (Access=public)
        shape;
        RGBAfrac;
        lineWidDeg;
    end
    properties (Access=private)
        RGBA;
        lPx;
    end
    methods
        function S=dpxStimCross
            S.wDeg=.15;
            S.hDeg=.15;
            S.RGBAfrac=[1 0 0 1];
            S.durSec=Inf;
            S.lineWidDeg=.1;
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.RGBA = S.RGBAfrac * S.scrGets.whiteIdx;
            S.lineWidDeg = S.lineWidDeg * S.scrGets.deg2px;
        end
        function myDraw(S)
            wPtr=S.scrGets.windowPtr;
            h=S.hPx/2;
            w=S.wPx/2;
            x=S.xPx;
            y=S.yPx;
            if strcmpi(S.scrGets.stereoMode,'mono')
                Screen('DrawLines',wPtr,[0 0 x-w y+h; x-w y+h 0 0],S.lineWidDeg,S.RGBA(:),S.winCntrXYpx);
            elseif strcmpi(S.scrGets.stereoMode,'mirror')
                for buffer=0:1
                    Screen('SelectStereoDrawBuffer', wPtr, buffer);
                    Screen('DrawLines',wPtr,[0 0 x-w y+h; x-w y+h 0 0],S.lineWidDeg,S.RGBA(:),S.winCntrXYpx);
                end
            else
                error(['Unknown stereoMode ''' S.stereoMode '''.']);
            end
        end
    end
end
