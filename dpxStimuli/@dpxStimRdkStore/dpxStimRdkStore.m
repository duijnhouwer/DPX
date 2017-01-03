classdef dpxStimRdkStore < dpxStimRdkShuffleStep
    properties (Access=public)
        xyat@single;
    end
    methods (Access=protected)
        function myDraw(S)
            if isempty(S.xyat)
                S.xyat=nan(3,S.nDots,200,'single');
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

                
                sca
                S.xyat(:,ok,S.stepCounter)=[xy(:,ok); S.dotAge(ok)];
            end
        end
        function myClear(S)
            S.xyat(:,:,S.stepCounter+1:end)=[];
        end
    end
end
