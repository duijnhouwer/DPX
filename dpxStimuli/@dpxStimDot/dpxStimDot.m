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
            diam=max(1,S.wPx);
            if strcmpi(S.scrGets.stereoMode,'mono')
                Screen('DrawDots',S.scrGets.windowPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
            elseif strcmpi(S.scrGets.stereoMode,'mirror')
                for buffer=0:1
                    Screen('SelectStereoDrawBuffer', S.scrGets.windowPtr, buffer);
                    Screen('DrawDots',S.scrGets.windowPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
                end
            else
                error(['Unknown stereoMode ''' S.stereoMode '''.']);
            end
        end
    end
    methods
        function set.shape(S,value)
            if value=='?'
                disp('shape (char): not used anymore. Originally intended to toggle between dot and cross option, but has been split in separate classes since. Maintained for backward compatibility');
                return;
            end
            if ~isempty(value)
                error('Property ''shape'' is not used and should remain empty ([]). Maintained only for backward compatibility.');
            end
        end
        function set.RGBAfrac(S,value)
            if value=='?'
                disp('RGBAfrac (numeric): red-green-blue-opacity values [0..1] of the dot.');
                return;
            end
            [ok,errstr]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RBGAfrac should be a ' errstr]);
            else
                S.RGBAfrac=value;
            end
        end
    end
end
