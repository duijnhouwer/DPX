classdef dpxStimGrating < dpxAbstractVisualStim
    
    properties (Access=public)
        dirDeg;
        cyclesPerSecond;
        cyclesPerDeg;
        squareWave; % logical
        contrastFrac; % fraction of max screen contrast [maxBlack..maxWhite]
        grayFrac; % point between maxBlack and maxWhite
        buffer;
    end
    properties (Access=protected)
        visibleSizePx;
        cyclesPerPx;
        pxPerCycle;
        gratingTexture=[];
        dstRect;
        srcRect;
        shiftPxPerFlip;
    end
    methods (Access=public)
        function S=dpxStimGrating
            % Set the defaults in the constructur (here)
            S.dirDeg=45;
            S.cyclesPerSecond=10;
            S.cyclesPerDeg=.5;
            S.squareWave=false;
            S.grayFrac=.5;
            S.contrastFrac=1;
            S.wDeg=10;
            S.hDeg=10;
            S.buffer=[];
        end
    end
    methods (Access=protected)
        function myInit(S)
            D2P=S.scrGets.deg2px; % degrees to pixels deg*D2P=px
            S.cyclesPerPx=S.cyclesPerDeg/D2P;
            S.pxPerCycle=1/S.cyclesPerPx;
            texHalfLenPx=round(S.wPx/2);
            S.visibleSizePx=2*texHalfLenPx+1;
            S.shiftPxPerFlip= -1 * S.pxPerCycle * S.cyclesPerSecond / S.scrGets.measuredFrameRate;
            spacePx=meshgrid(-texHalfLenPx:texHalfLenPx + S.pxPerCycle, 1);
            white=S.scrGets.whiteIdx;
            black=S.scrGets.blackIdx;
            midgray=round((white+black)*S.grayFrac);
            maxAmplitude=min(white-midgray,abs(midgray-black));
            grating=midgray + S.contrastFrac*maxAmplitude*cosd(S.cyclesPerPx*spacePx*360);
            if S.squareWave
                grating(grating>=midgray)=midgray+S.contrastFrac*maxAmplitude;
                grating(grating<midgray)=midgray-S.contrastFrac*maxAmplitude;
            end
            S.gratingTexture=Screen('MakeTexture', S.scrGets.windowPtr, grating, -S.dirDeg);
            % calculate the rectangle into which the texture will be shown on the
            % screen "destination rectangle"
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.hPx/2+S.winCntrXYpx(2)]; % lower left
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.hPx]; % add top right
        end
        function myDraw(S)
            if ~S.visible
                return;
            end
            if strcmp(S.scrGets.stereoMode,'mono')
                Screen('DrawTexture', S.scrGets.windowPtr, S.gratingTexture, S.srcRect, S.dstRect, -S.dirDeg);
            elseif strcmp(S.scrGets.stereoMode,'mirror')
                if isempty(S.buffer)
                    Screen('DrawTexture', S.scrGets.windowPtr, S.gratingTexture, S.srcRect, S.dstRect, -S.dirDeg);
                else
                    Screen('SelectStereoDrawBuffer', S.scrGets.windowPtr, S.buffer);
                    Screen('DrawTexture', S.scrGets.windowPtr, S.gratingTexture, S.srcRect, S.dstRect, -S.dirDeg);
                end
            end
        end
        function myStep(S)
            % We move the grating by shifting the part we show of the
            % underlying  texture. Define shifted srcRect that cuts out the
            % properly shifted rectangular area from the texture: We cut
            % out the range 0 to visiblesize in the vertical direction
            % although the texture is only 1 pixel in height! This works
            % because the hardware will automatically replicate pixels in
            % one dimension if we exceed the real borders of the stored
            % texture. This allows us to save storage space here, as our
            % 2-D grating is essentially only defined in 1-D:
            xoffset = mod(S.flipCounter*S.shiftPxPerFlip,S.pxPerCycle);
            S.srcRect=[xoffset 0 xoffset+S.visibleSizePx S.visibleSizePx];
        end
        function myClear(S)
            Screen('Close',S.gratingTexture);
        end
    end
    methods
        %function set.grayFrac(S,value)
        % I'm not sure why this commented out (jacob 2015-06-23)
        %    if ~isnumeric(value) || ~isempty(value) && (value<0 || value>1)
        %        error('grayFrac should be a fraction');
        %    end
        %    S.grayFrac=value;
        %end
    end
end


