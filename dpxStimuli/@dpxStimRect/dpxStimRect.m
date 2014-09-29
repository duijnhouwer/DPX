classdef dpxStimRect < dpxBasicStim
    
    properties (Access=public)
        RGBAfrac;
    end
    properties (Access=protected)
        RGBA;
    end
    methods (Access=public)
        function S=dpxStimRect
            S.RGBAfrac=[1 1 1 1];
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.RGBA=S.RGBAfrac*S.scrGets.whiteIdx;
        end
        function myDraw(S)
            xyTopLeft=S.winCntrXYpx+[S.xPx-S.wPx/2 S.yPx-S.hPx/2];
            xyBotRite=S.winCntrXYpx+[S.xPx+S.wPx/2 S.yPx+S.hPx/2];
            rect=[xyTopLeft xyBotRite];
            Screen('FillRect',S.scrGets.windowPtr,S.RGBA,rect);
            disp('fillrect :)');
        end
    end
    methods
        function set.RGBAfrac(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RBGAfrac should be a ' str]);
            else
                S.RGBAfrac=value;
            end
        end
    end
end
