classdef dpxStimRdkStore < dpxStimRdkShuffleStep
    properties (Access=public)
        xyt@single;
    end
    methods (Access=protected)
        function myDraw(S)
            if isempty(S.xyt)
                S.xyt=nan(2,S.nDots,200,'single');
            end
            if S.visible
                ok=applyTheAperture(S);
                if S.shuffleBool
                    % only show the first and last instance of a dot
                    ok=ok & (S.dotAge==0|S.dotAge==S.nStepsArray);
                end
                if ~any(ok), return; end
                xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
                %Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2);
                S.xyt(:,ok,S.stepCounter)=xy(:,ok);
            end
        end
        function myClear(S)
            S.xyt(:,:,S.stepCounter+1:end)=[];
        end
    end
end
