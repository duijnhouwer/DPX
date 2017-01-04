classdef dpxStimRdkStore < dpxStimRdkShuffleStep
    properties (Access=public)
        xyt@single;
        pxPerFrame;
    end
    methods (Access=protected)
        function myDraw(S)
            if isempty(S.xyt)
                S.xyt=nan(2,S.nDots,200,'single');
                S.pxPerFrame=S.pxPerFlip;
            end
            if S.visible
                ok=applyTheAperture(S);
                if S.shuffleBool
                     % show only 2 instances of the dot
                    ok=ok & (S.dotAge==0|S.dotAge==S.flash2ndTime);
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
