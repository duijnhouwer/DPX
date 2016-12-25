classdef dpxStimRdkSkip < dpxStimRdk
    properties (Access=public)
        xyt@single;
    end
    methods (Access=protected)
        function myInit(S)
            % Convert settings to stimulus properties
            S.nDots=max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            S.nDots=round(S.nDots/2)*2; % make sure even, better for 50/50 split of motion directions for example
            N=S.nDots;
            S.dotXPx=S.RND.rand(1,N)*S.wPx-S.wPx/2;
            S.dotYPx=S.RND.rand(1,N)*S.hPx-S.hPx/2;
            S.dotDirRads=ones(1,N)*real(S.dirDeg)/180*pi;
            if ~isreal(S.dirDeg)
                % imaginary component of S.dirDeg can be used to make half the dots move in
                % a direction imag(S.dirDeg) away from real(S.dirDeg)
                S.dotDirRads(1:2:end)=S.dotDirRads(1:2:end)+imag(S.dirDeg)/180*pi;
            end
            nNoiseDots=max(0,min(N,round(N * (1-abs(S.cohereFrac)))));
            S.noiseDots=[true(1,nNoiseDots) false(1,N-nNoiseDots)];
            S.noiseDots=S.noiseDots(S.RND.randperm(numel(S.noiseDots)));
            noiseDirRads=S.RND.rand(1,N)*2*pi;
            S.dotDirRads(S.noiseDots)=noiseDirRads(S.noiseDots);
            if S.cohereFrac<0
                S.dotDirRads=S.dotDirRads+pi; % negative coherence flips directions
            end
            S.dotDiamPx=S.dotDiamDeg*S.scrGets.deg2px;
            S.checkDotsize(S.dotDiamPx);
            S.dotAge=floor(S.RND.rand(1,N) * (abs(S.nSteps) + 1));
            S.pxPerFlip=S.speedDps * S.scrGets.deg2px / S.scrGets.measuredFrameRate;
            S.dotPolarity=S.RND.rand(1,N)<.5;
            S.dotsRGBA(:,S.dotPolarity)=repmat(S.dotRBGAfrac1(:)*S.scrGets.whiteIdx,1,sum(S.dotPolarity));
            S.dotsRGBA(:,~S.dotPolarity)=repmat(S.dotRBGAfrac2(:)*S.scrGets.whiteIdx,1,sum(~S.dotPolarity));
            S.motStartFlip=round(S.motStartSec*S.scrGets.measuredFrameRate);
            S.motStopFlip=S.motStartFlip+S.motDurSec*S.scrGets.measuredFrameRate;
            
            S.xyt=nan(2,S.nDots,200,'single');
        end
        function myDraw(S)              
            if S.visible
                ok=applyTheAperture(S);
                if S.nSteps<0
                    % Negativ only show the first and last instance of a dot
                    ok=ok & (S.dotAge==0 | S.dotAge==abs(S.nSteps));
                end
                if ~any(ok), return; end
                xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
               % Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2);                
                S.xyt(:,ok,S.stepCounter)=xy(:,ok);
            end
        end
    end
end
