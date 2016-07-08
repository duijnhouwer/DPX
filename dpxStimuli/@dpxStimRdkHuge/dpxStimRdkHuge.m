classdef dpxStimRdkHuge < dpxStimRdk
    % The Same As dpxStimRdk But uses FillOval instead of DrawDots to allow
    % for Huge dots.
    methods (Access=protected)
        function myDraw(S)
            if S.visible
                ok=applyTheAperture(S);
                if ~any(ok), return; end
                centerX = S.winCntrXYpx(1)+S.dotXPx(:)'+S.xPx;
                centerY = S.winCntrXYpx(2)+S.dotYPx(:)'+S.yPx;
                leftX = centerX-S.dotDiamPx/2;
                rightX = centerX+S.dotDiamPx/2;
                topY = centerY+S.dotDiamPx/2;
                bottomY = centerY-S.dotDiamPx/2;
                rectArray = [leftX(:) topY(:) rightX(:) bottomY(:)]';
                Screen('FillOval',S.scrGets.windowPtr,S.dotsRGBA(:,ok),rectArray(:,ok),S.dotDiamPx*1.1);
            end
        end
        function checkDotsize(S,px)
            % no need for when drawing with FillOval instead of DrawDots,
            % so this empty function simply overrides the one in dpxStimRdk
        end
    end
end
