classdef dpxStimMask < dpxAbstractStim
    
    properties (Access=public)
        typeStr; % 'none', 'gaussian', 'circle'
        pars; % see myInit for how this is used, depends on typeStr value
        grayFrac;
    end
    properties (Access=protected)
        maskTexture=[];
        dstRect;
        srcRect;
        shiftPxPerFlip;
        visibleSizePx;
    end
    methods (Access=public)
        function S=dpxStimMask
            % Set the defaults in the constructure (here)
            S.typeStr='circle';
            S.pars=1;
            S.wDeg=5;
            S.hDeg=5;
            S.grayFrac=.5;
        end
    end
    methods (Access=protected)
        function myInit(S)
            texHalfLenPx=round(S.wPx/2);
            S.visibleSizePx=2*texHalfLenPx+1;
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.wPx/2+S.winCntrXYpx(2)];
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.wPx];
            D2P=S.scrGets.deg2px; % degrees to pixels deg*D2P=px
            white=S.scrGets.whiteIdx;
            opaque=white;
            black=S.scrGets.blackIdx;
            if strcmpi(S.typeStr,'none')
                S.maskTexture=[];
            else
                grayscaleLayer=ones(S.visibleSizePx, S.visibleSizePx) * round(white*S.grayFrac);
                if strcmpi(S.typeStr,'gaussian')
                    sigmaPx=S.pars*D2P;
                    [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,-texHalfLenPx:texHalfLenPx);
                    opacityLayer=opaque * (1 - exp(-((x/sigmaPx).^2)-((y/sigmaPx).^2)));
                elseif strcmpi(S.typeStr,'circle')
                    rampPx=S.pars*D2P;
                    [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,-texHalfLenPx:texHalfLenPx);
                    opacityLayer=opaque*(1-dpxClip((hypot(x,y)-texHalfLenPx)*-1./rampPx,[0 1]));
                elseif strcmpi(S.typeStr,'halfdome')
                    if numel(S.pars)~=4
                        error('HalfDome mask requires four parameter: [topDiamPx botDiamPx botDiamOffsetPx blurPx]');
                    end
                    opacityLayer=false(size(grayscaleLayer));
                    topDiamPx=S.pars(1);
                    botDiamPx=S.pars(2);
                    botDiamOffsetPx=S.pars(3);
                    blurPx=S.pars(end);
                    if blurPx<1, blurPx=1; end
                    [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,(-texHalfLenPx:texHalfLenPx)-texHalfLenPx/2);
                    topCurve=hypot(x,y)>topDiamPx;
                    botCurve=hypot(x,y+botDiamPx)>botDiamPx+botDiamOffsetPx;
                    if true
                        dpxFindFig('halfdomemask');
                        subplot(1,3,1);
                        imagesc(topCurve); axis equal;
                        subplot(1,3,2);
                        imagesc(botCurve); axis equal;
                        subplot(1,3,3);
                        imagesc(topCurve | botCurve); axis equal;
                    end
                    opacityLayer(topCurve | botCurve)=true;
                    G = fspecial('gaussian',[blurPx blurPx],blurPx/5);
                    opacityLayer=imfilter(opaque*opacityLayer,G,opaque,'same');
                else
                    error(['Unknown typeStr ' S.typeStr]);
                end
                M=cat(3,grayscaleLayer,opacityLayer);
                S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, M, 0);
            end
        end
        function myDraw(S)
            Screen('DrawTexture', S.scrGets.windowPtr, S.maskTexture, [0 0 S.visibleSizePx S.visibleSizePx], S.dstRect, 0);
        end
        function myClear(S)
            Screen('Close',S.maskTexture)
        end
    end
end


