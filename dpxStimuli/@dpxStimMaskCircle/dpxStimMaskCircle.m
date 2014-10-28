classdef dpxStimMaskCircle < dpxAbstractStim
    
    properties (Access=public)
        RGBAfrac;
        innerDiamDeg;
        outerDiamDeg;
    end
    properties (Access=protected)
        maskTexture=[];
        dstRect;
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
            % Make a texture, first as a solid layer of gray, we will later
            % gives this a color and we will add an opacity layer
            % in which we draw a circle with an optional linear gradient
            % toward the edges (from innerdiam to outerdiam).
            % STEP 1
            texHalfLenPx=round(S.wPx/2);
            S.visibleSizePx=2*texHalfLenPx+1;
            grayLayer=ones(S.visibleSizePx, S.visibleSizePx) * round(S.scrGets.whiteIdx);
            % STEP 2: Make the transparent circle with the gradient
            [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,-texHalfLenPx:texHalfLenPx);
            ir=S.innerDiamDeg*S.scrGets.deg2px/2;
            or=S.outerDiamDeg*S.scrGets.deg2px/2;
            I=(hypot(x,y)-ir)/(or-ir);
            opaLayer=S.scrGets.whiteIdx*(dpxClip(I,[0 1]));
            % STEP 3: make an R, G, and B layer by scaling the grayLayer,
            % and concatenate them and the opacity layer. Call it M.
            M=cat(3,grayLayer*S.RGBAfrac(1),grayLayer*S.RGBAfrac(2),grayLayer*S.RGBAfrac(3),opaLayer);
            % STEP 4: make the texture 
            S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, M, 0);
            % Determine the rectangle in pixels in which the texture will be shown
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.hPx/2+S.winCntrXYpx(2)];
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.hPx];
        end
        function myDraw(S)
            srcRect=[0 0 S.visibleSizePx S.visibleSizePx];
            Screen('DrawTexture',S.scrGets.windowPtr,S.maskTexture,srcRect,S.dstRect,0);
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


