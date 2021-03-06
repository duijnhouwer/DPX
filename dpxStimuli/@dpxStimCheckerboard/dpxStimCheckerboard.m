classdef dpxStimCheckerboard < dpxAbstractVisualStim
    
    properties (Access=public)
        RGBAfrac;
        nHori;
        nVert;
        contrast;
        nHoleHori;
        nHoleVert;
        sparseness;
    end
    properties (Access=protected)
        checkerboardTexture=[];
        dstRect;
    end
    methods (Access=public)
        function S=dpxStimCheckerboard
            % Set the defaults in the constructur (here)
            S.RGBAfrac=[.5 .5 .5  1];
            S.nHori=14;
            S.nVert=14;
            S.nHoleHori=6;
            S.nHoleVert=6;
            S.contrast=.5;
            S.sparseness=1/3;
        end
    end
    methods (Access=protected)
        function myInit(S)
            % Make the destination rectangle (screen pixels)
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.hPx/2+S.winCntrXYpx(2)];
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.hPx];
            % Make the checkerboard pattern
            white=S.scrGets.whiteIdx;
            cols=[white-white*S.contrast white+white*S.contrast]/2;
            checkerboard=reshape(mod(1:(S.nHori+1)*S.nVert,2),S.nHori+1,S.nVert);
            checkerboard=checkerboard(1:S.nHori,1:S.nVert);
            checkerboard=checkerboard*cols(1)+(1-checkerboard)*cols(2);
            % Make the opacity layer
            opacityLayer=cols(1)*(ones(size(checkerboard)));
            % Make the central hole
            if (S.nHoleHori&S.nHoleVert)>0
                xHole=round(S.nHori/2-S.nHoleHori/2+1:S.nHori/2+S.nHoleHori/2);
                yHole=round(S.nVert/2-S.nHoleVert/2+1:S.nVert/2+S.nHoleVert/2);
                opacityLayer(xHole,yHole)=S.scrGets.blackIdx;
            end
            % Blank random checks of the non-hole part ...
            notHoleIdx=find(opacityLayer>0);
            nBlanks=round(S.sparseness*numel(notHoleIdx));
            mask=[zeros(nBlanks,1); ones(numel(notHoleIdx)-nBlanks,1)];
            mask=mask(S.RND.randperm(numel(mask)));
            opacityLayer(notHoleIdx)=opacityLayer(notHoleIdx).*mask;
            % Concatenate the RGB and Opacity layer
            M=cat(3,checkerboard*S.RGBAfrac(1),checkerboard*S.RGBAfrac(2),checkerboard*S.RGBAfrac(3),opacityLayer);
            % Make the texture
            S.checkerboardTexture=Screen('MakeTexture', S.scrGets.windowPtr, M, 0);
        end
        function myDraw(S)
            if ~S.visible
                return;
            end
            filtermode=0; % 0 = nearest neighbor
            Screen('DrawTexture', S.scrGets.windowPtr, S.checkerboardTexture, [0 0 S.nHori S.nVert], S.dstRect, 0, filtermode);
        end
        function myClear(S)
            Screen('Close',S.checkerboardTexture)
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


