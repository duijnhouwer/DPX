classdef dpxStimPause < dpxAbstractStim
    
    % This stimulus is a stub. If you want to add a stimulus class, you can
    % copy the entire @dpxStimAAAAA folder and replace all occurances of
    % AAAAA with your stimulus' name.
    % Jacob Duijnhouwer, 2014-09-29
    
    properties (Access=public)
        RGBAfrac; % A four element vector of values between [0..1] representing red-green-blue-opacity of the rectangle
        textPause1; 
        textPause2;
        textSpacing;
        textSize;
    end
    properties (Access=protected)
        RGBA;
    end
    methods (Access=public)
        function S=dpxStimPause
            S.RGBAfrac=[1 1 1 1];
            S.textPause1='test1';                                           % Line 1
            S.textPause2='test2';                                           % Line 2
            S.durSec=Inf;                                                   
            S.textSpacing = 16;                                             % Spacing between lines 1 and 2
            S.textSize = 16; 
        end
    end
    methods (Access=protected)
        function myInit(S)
             S.RGBA = S.RGBAfrac * S.scrGets.whiteIdx;
        end
        function myStep(S)
            % Called every flip (i.e., video frame), prior to drawing.
            % Values for animation (e.g. stimulus positions) should be
            % updated here.
        end
        function myDraw(S)
            % Called every flip, after myStep. All drawing is done here,
            % the video-flip is triggered right after this.
              wPtr = S.scrGets.windowPtr;
              Screen('TextFont',wPtr, 'Courier New');
              Screen('TextSize',wPtr, S.textSize);                                                                                                          
              Screen('TextStyle', wPtr, 1);                                 %1=bold
              
             [newx1, newy1] = Screen(wPtr, 'DrawText', S.textPause1, 0, 0, [.5 .5 .5 1]);   % use background color
             [newx2, newy2] = Screen(wPtr, 'DrawText', S.textPause2, 0, 0, [.5 .5 .5 1]);   % use background color

            if strcmpi(S.scrGets.stereoMode, 'mono')
                      Screen(wPtr, 'DrawText', S.textPause1, S.winCntrXYpx(1) - newx1/2, S.winCntrXYpx(2) - S.textSpacing, S.RGBA);
                      Screen(wPtr, 'DrawText', S.textPause2, S.winCntrXYpx(1) - newx2/2, S.winCntrXYpx(2) + S.textSpacing, S.RGBA);
            elseif strcmpi(S.scrGets.stereoMode, 'mirror')
                 for buffer=0:1
                      Screen('SelectStereoDrawBuffer', wPtr, buffer);
                      Screen(wPtr, 'DrawText', S.textPause1, S.winCntrXYpx(1) - newx1/2, S.winCntrXYpx(2) - S.textSpacing, S.RGBA);
                      Screen(wPtr, 'DrawText', S.textPause2, S.winCntrXYpx(1) - newx2/2, S.winCntrXYpx(2) + S.textSpacing, S.RGBA);
                 end
            end
        end
        function myClear(S)
            %Screen('Close'); 
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
