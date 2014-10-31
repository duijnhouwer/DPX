classdef dpxStimMaskTiff < dpxAbstractStim
    
    properties (Access=public)
        RGBAfrac;
        filename;
        dstRectPx;
        blurPx;
    end
    properties (Access=protected)
        maskTexture=[];
        srcRectPx;
    end
    methods (Access=public)
        function S=dpxStimMaskTiff
            % Set the defaults in the constructur (here)
            S.RGBAfrac=[.5 .5 .5 1];
            S.filename='C:\Users\jacob\Documents\MATLAB\DPX\dpxExperiments\jacob\dpxToolsHalfDomeWarp_editedMask.tif';
            S.dstRectPx='fullscreen';
            S.blurPx=50;
        end
    end
    methods (Access=protected)
        function myInit(S)
            opaLayer=imread(S.filename);
            opaLayer=opaLayer(:,:,1); % use the only channel or the red one if more available
            % blur the opaLayer for smooth edges
            if S.blurPx>0
                G = fspecial('gaussian',[S.blurPx S.blurPx],S.blurPx/5);
                opaLayer=imfilter(opaLayer,G,0,'same');
            end
            % Make the graylayers
            grayLayer=ones(size(opaLayer));
            % Contruct the RGBA image, and make a texture of it
            M=cat(3,grayLayer*S.RGBAfrac(1),grayLayer*S.RGBAfrac(2),grayLayer*S.RGBAfrac(3),S.scrGets.whiteIdx-opaLayer);
            S.maskTexture=Screen('MakeTexture', S.scrGets.windowPtr, M, 0);
            % Determine the rectangular part of the texture that will be
            % shown (i.e., whole texture currently, could change in future)
            S.srcRectPx=[0 0 size(opaLayer,2) size(opaLayer,1)];
            % Determine the rectangle in pixels in which the texture will be shown
            if isempty(S.dstRectPx)
                S.dstRectPx=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.hPx/2+S.winCntrXYpx(2)];
                S.dstRectPx=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.hPx];
            elseif strcmpi(S.dstRectPx,'fullscreen')
                S.dstRectPx=[0 0 size(opaLayer,2) size(opaLayer,1)];
            elseif ~numel(S.dstRectPx)==4
                error('dstRectPx should be a 4 number rectangle (pixels), be empty (to use wDeg and hDeg), or the string ''fullscreen''.');
            end
        end
        function myDraw(S)
            Screen('DrawTexture',S.scrGets.windowPtr,S.maskTexture,S.srcRectPx,S.dstRectPx,0);
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


