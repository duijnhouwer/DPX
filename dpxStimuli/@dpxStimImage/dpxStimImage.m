classdef dpxStimImage < dpxBasicStim
    
    properties (Access=public)
        RGBA=[0 0 255 255];
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function S=dpxStimImage
        end
    end
    methods (Access=protected)
        function myInit(S)
        end
        function myDraw(S)
            % topleft of screen is 0,0
            xyTopLeft=S.winCntrXYpx+[S.xPx-S.wPx/2 S.yPx-S.hPx/2];
            xyBotRite=S.winCntrXYpx+[S.xPx+S.wPx/2 S.yPx+S.hPx/2];
            rect=[xyTopLeft xyBotRite];
            Screen('FillRect',S.scrGets.windowPtr,S.RGBA,rect);
        end
    end
end
