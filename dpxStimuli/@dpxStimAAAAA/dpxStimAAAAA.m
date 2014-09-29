classdef dpxStimAAAAA < dpxBasicStim
    
    % This stimulus is a stub. If you want to add a stimulus class, you can
    % copy the entire @dpxStimAAAAA folder and replace all occurances of
    % AAAAA with your stimulus' name.
    % Jacob Duijnhouwer, 2014-09-29
    
    properties (Access=public)
        RGBAfrac; % A four element vector of values between [0..1] representing red-green-blue-opacity of the rectangle
    end
    properties (Access=protected)
        RGBA;
    end
    methods (Access=public)
        function S=dpxStimAAAAA
            S.RGBAfrac=[1 1 1 1];
        end
    end
    methods (Access=protected)
        function myInit(S)
            % Called at the beginning of the trial, typically public values
            % get converted here to behind the scenes protected properties
            S.RGBA=S.RGBAfrac*S.scrGets.whiteIdx;
        end
        function myStep(S)
            % Called every flip (i.e., video frame), prior to drawing.
            % Values for animation (e.g. stimulus positions) should be
            % updated here.
        end
        function myDraw(S)
            % Called every flip, after myStep. All drawing must be done
            % here, the video-flip is triggered right after this.
            xyTopLeft=S.winCntrXYpx+[S.xPx-S.wPx/2 S.yPx-S.hPx/2];
            xyBotRite=S.winCntrXYpx+[S.xPx+S.wPx/2 S.yPx+S.hPx/2];
            rect=[xyTopLeft xyBotRite];
            Screen('FillRect',S.scrGets.windowPtr,S.RGBA,rect);
        end
        function myClear(S)
            % Called at the end of the trial, can used to clear objects
            % that may have been instantiated during myInit. Typically this
            % function can be left out of your stimulus class.
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
