classdef dpxStimRdkHuge < dpxStimRdk
    function myDraw(S)
        if S.visible
            ok=applyTheAperture(S);
            if ~any(ok), return; end
            xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
            Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2);
        end
    end
end
