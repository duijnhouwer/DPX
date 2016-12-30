classdef dpxStimCross < dpxAbstractVisualStim
    
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
            S.wDeg=.5;
            S.hDeg=.5;
            S.RGBAfrac=[1 0 0 1];
            S.durSec=Inf;
            S.lineWidDeg=.1;
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.RGBA = S.RGBAfrac * S.scrGets.whiteIdx;
            S.lPx = S.lineWidDeg * S.scrGets.deg2px;
        end
        function myDraw(S)
            if ~S.visible
                return;
            end
            wPtr=S.scrGets.windowPtr;
            h=S.hPx/2;
            w=S.wPx/2;
            x=S.xPx;
            y=S.yPx;
            xy=[0 0 x-w x+w; y-h y+h 0 0];
            if strcmpi(S.scrGets.stereoMode,'mono')
                Screen('DrawLines',wPtr,xy,S.lPx,S.RGBA(:),S.winCntrXYpx,1);
            elseif strcmpi(S.scrGets.stereoMode,'mirror')
                for buffer=0:1
                    Screen('SelectStereoDrawBuffer', wPtr, buffer);
                    Screen('DrawLines',wPtr,xy,S.lPx,S.RGBA(:),S.winCntrXYpx,1,1);
                end
            elseif strcmpi(S.scrGets.stereoMode,'anaglyph')
                Screen('DrawLines',wPtr,xy,S.lPx,S.RGBA(:),S.winCntrXYpx,1,1);
            else
                error(['Unknown stereoMode ''' S.stereoMode '''.']);
            end
        end
    end
end
