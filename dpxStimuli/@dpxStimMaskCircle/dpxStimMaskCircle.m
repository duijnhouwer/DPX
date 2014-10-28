classdef dpxStimMaskCircle < dpxAbstractStim
    
    properties (Access=public)
        RGBAfrac;
        innerDiamDeg;
        outerDiamDeg;
    end
    properties (Access=protected)
        maskTexture=[];
        dstRect;
        srcRect;
        visibleSizePx;
    end
    methods (Access=public)
        function S=dpxStimMaskCircle
            % Set the defaults in the constructur (here)
            S.innerDiamDeg=.5;
            S.outerDiamDeg=1;
            S.RGBAfrac=[.5 .5 .5 1];
        end
    end
    methods (Access=protected)
        function myInit(S)
            grayFrac=S.RGBAfrac(1);
            if std(S.RGBAfrac(1:3))>eps
                error('CURRENTLY ONLY GRAYSCALES (R=G=B) IMPLEMENTED, ONLY REASON BEING THAT I WSA IN A HURRY, CAN BE IMPLEMENTED WITHOUT PORBLEM');
            end
            texHalfLenPx=round(S.wPx/2);
            S.visibleSizePx=2*texHalfLenPx+1;
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.hPx/2+S.winCntrXYpx(2)];
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.hPx];
            white=S.scrGets.whiteIdx;
            opaque=white;
            grayscaleLayer=ones(S.visibleSizePx, S.visibleSizePx) * round(white*  grayFrac);
            [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,-texHalfLenPx:texHalfLenPx);
            ir=S.innerDiamDeg*S.scrGets.deg2px/2;
            or=S.outerDiamDeg*S.scrGets.deg2px/2;
            I=(hypot(x,y)-ir)/(or-ir);
            opacityLayer=opaque*(dpxClip(I,[0 1]));
            M=cat(3,grayscaleLayer,opacityLayer);
            S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, M, 0);
        end
        function myDraw(S)
            Screen('DrawTexture', S.scrGets.windowPtr, S.maskTexture, [0 0 S.visibleSizePx S.visibleSizePx], S.dstRect, 0);
        end
        function myClear(S)
            Screen('Close',S.maskTexture)
        end
    end
    methods
        function set.RGBAfrac(S,value)
           	[ok,str]=dpxIsRGBAfrac(value);
            if ~ok, error(str); end
            S.RGBAfrac=value;
        end
    end
end


