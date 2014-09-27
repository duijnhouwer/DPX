classdef dpxStimMask < dpxBasicStim
    
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
                mask=ones(S.visibleSizePx, S.visibleSizePx, 2) * round((opaque+black)*S.grayFrac);
                % mask(:,:,1) is the RGB part of the mask texture
                % mask(:,:,2) is the OPACITY
               
                if strcmpi(S.typeStr,'gaussian')
                    sigmaPx=S.pars*D2P;
                     [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,-texHalfLenPx:texHalfLenPx);
                    mask(:, :, 2)=opaque * (1 - exp(-((x/sigmaPx).^2)-((y/sigmaPx).^2)));
                    S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, mask, 0);
                elseif strcmpi(S.typeStr,'circle')
                    rampPx=S.pars*D2P;
                     [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,-texHalfLenPx:texHalfLenPx);
                    mask(:,:,2)=opaque*(1-dpxClip((hypot(x,y)-texHalfLenPx)*-1./rampPx,[0 1]));
                    S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, mask, 0);
                elseif strcmpi(S.typeStr,'halfdome')
                    diamPx=S.pars(1);
                    blurPx=S.pars(2);
                    [x,y]=meshgrid(-texHalfLenPx:texHalfLenPx,(-texHalfLenPx:texHalfLenPx)-texHalfLenPx/2);
                    mask(:,:,2)=opaque*(hypot(x,y)>diamPx);
                    mask(round(end*.75):end,:,2)=opaque;
                    G = fspecial('gaussian',[blurPx blurPx],blurPx/5);
                    mask(:,:,2) = imfilter(mask(:,:,2),G,opaque,'same');
                    %imagesc(mask(:,:,2)); axis equal; colormap gray
                    
                    S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, mask, 0);
                else
                    error(['Unknown typeStr ' S.typeStr]);
                end
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


