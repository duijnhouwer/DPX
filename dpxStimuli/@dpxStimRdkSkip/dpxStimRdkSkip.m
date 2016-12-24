classdef dpxStimRdkSkip < dpxStimRdk
    % The Same As dpxStimRdk but allows dots to be invisible except for the
    % first and last instance on the trajectory. This can be used to make
    % stimuli like Bours-Lankheet
    
    
    properties (Access=protected)
        dotAge;
    end
    methods (Access=protected)
        function myDraw(S)
            if S.visible
                ok=applyTheAperture(S);
                
                if ~any(ok), return; end
                xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
                Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2);
            end
        end
    end
end
