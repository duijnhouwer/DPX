classdef dpxGR< dpxAbstractStim
    
    properties (Access=public)
        dirDeg;
        cyclesPerSecond;
        cyclesPerDeg;
        squareWave; % logical
        contrastFrac; % fraction of max screen contrast [maxBlack..maxWhite] 
        grayFrac; % point between maxBlack and maxWhite
        gEnvelope;
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
        function S=dpxGR
            % Set the defaults in the constructur (here)
            S.dirDeg=45;
            S.cyclesPerSecond=10;
            S.cyclesPerDeg=.5;
            S.squareWave=true;
            S.grayFrac=.5;
            S.contrastFrac=1;
            S.wDeg=10;
            S.hDeg=10; 
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
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.wPx/2+S.winCntrXYpx(2)];
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.wPx];
          
        end
        function myDraw(S)
            if strcmpi(S.scrGets.stereoMode,'mono')
            Screen('DrawTexture', S.scrGets.windowPtr, S.gratingTexture, S.srcRect, S.dstRect, -S.dirDeg);
            elseif strcmpi(S.scrGets.stereoMode,'mirror')
                for buffer =0:1
                  Screen('SelectStereoDrawBuffer', S.scrGets.windowPtr, buffer);
                   Screen('DrawTexture', S.scrGets.windowPtr, S.gratingTexture, S.srcRect, S.dstRect, -S.dirDeg);
                end
            end

            % Screen('DrawTexture', S.scrGets.windowPtr, S.gratingTexture, S.srcRect, S.dstRect, -S.dirDeg);
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
       % function set.grayFrac(S,value)
       %     if isempty(value)
       %     if ~isnumeric(value) || ~isempty(value) && (value<0 || value>1)
       %         error('grayFrac should be a fraction');
       %     end
       %     E.grayFrac=value;
       % end
    end   
end