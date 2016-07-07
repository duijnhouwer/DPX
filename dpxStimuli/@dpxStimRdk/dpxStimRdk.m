classdef dpxStimRdk < dpxAbstractVisualStim
    
    properties (Access=public)
        dirDeg;
        speedDps;
        dotsPerSqrDeg;
        dotDiamDeg;
        dotRBGAfrac1;
        dotRBGAfrac2;
        nSteps;
        cohereFrac; % negative coherence flips directions
        apert;
        motType; % use for phi and reversephi
        motStartSec; % relative to stim on 2015-10-28
        motDurSec; % 2015-10-28
        freezeFlip;
    end
    properties (Access=protected)
        nDots;
        dotXPx;
        dotYPx;
        dotDirRads=[];
        dotDiamPx;
        dotAge;
        pxPerFlip; % the speed in pixels per flip
        dotsRGBA;
        noiseDots;
        dotPolarity;
        motStartFlip;
        motStopFlip;
    end
    methods (Access=public)
        function S=dpxStimRdk
            % Set the defaults in the constructure (here)
            S.dirDeg=0;
            S.speedDps=10;
            S.dotsPerSqrDeg=10;
            S.dotDiamDeg=.1;
            S.dotRBGAfrac1=[0 0 0 1];
            S.dotRBGAfrac2=[1 1 1 1];
            S.nSteps=1; % single step is default, use Inf for unlimited
            S.cohereFrac=1; % negative coherence flips directions
            S.apert='circle';
            S.wDeg=10;
            S.hDeg=10;
            S.motType='phi';
            S.motStartSec=0; % relative to stimOnSec
            S.motDurSec=Inf;
            S.freezeFlip=1;
        end
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
            [S.dotDiamPx,wasoutofrange]=dpxClip(S.dotDiamDeg*S.scrGets.deg2px,S.scrGets.limits.GL_ALIASED_POINT_SIZE_RANGE);
            if wasoutofrange
                S.dotDiamDeg=S.dotDiamPx/S.scrGets.deg2px;
                warning(['S.dotDiamDeg was out of range for this computer, capped at the limit of ' num2str(S.dotDiamDeg) ' degrees.']);
            end
            S.dotAge=floor(S.RND.rand(1,N) * (S.nSteps + 1));
            S.pxPerFlip=S.speedDps * S.scrGets.deg2px / S.scrGets.measuredFrameRate;
            S.dotPolarity=S.RND.rand(1,N)<.5;
            S.dotsRGBA(:,S.dotPolarity)=repmat(S.dotRBGAfrac1(:)*S.scrGets.whiteIdx,1,sum(S.dotPolarity));
            S.dotsRGBA(:,~S.dotPolarity)=repmat(S.dotRBGAfrac2(:)*S.scrGets.whiteIdx,1,sum(~S.dotPolarity));
            S.motStartFlip=round(S.motStartSec*S.scrGets.measuredFrameRate);
            S.motStopFlip=S.motStartFlip+S.motDurSec*S.scrGets.measuredFrameRate;
        end
        function myDraw(S)
            if S.visible
                ok=applyTheAperture(S);
                if ~any(ok), return; end
                xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
                Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2,1);
            end
        end
        function myStep(S)
            if S.nDots==0
                return;
            end
            frozen=mod(S.stepCounter-S.motStartFlip,S.freezeFlip)>0; % way of reducing framerate
            if ~frozen
                % Reposition the dots, use shorthands for clarity
                x=S.dotXPx;
                y=S.dotYPx;
                w=S.wPx;
                h=S.hPx;
                % Update dot lifetime
                S.dotAge=S.dotAge+1;
                expired=S.dotAge>S.nSteps;
                % give new position if expired
                x(expired)=S.RND.rand(1,sum(expired))*w-w/2;
                y(expired)=S.RND.rand(1,sum(expired))*h-h/2;
                % give new random direction if expired and dot is noise
                S.dotDirRads(expired&S.noiseDots)=S.RND.rand(1,sum(expired&S.noiseDots))*2*pi;
                S.dotAge(expired)=0;
                % Move the dots, note, dots that have just been replaced within the
                % aperture because of life-time expirations should not step. Unless the
                % outside the motion interval [motStart--motStop>, of course.
                if S.stepCounter>=S.motStartFlip && S.stepCounter<S.motStopFlip
                    dx=cos(S.dotDirRads(~expired))*S.pxPerFlip*S.freezeFlip;
                    dy=sin(S.dotDirRads(~expired))*S.pxPerFlip*S.freezeFlip;
                    x(~expired)=x(~expired)+dx;
                    y(~expired)=y(~expired)+dy;
                    % Wrap the dots around if they cross the stimulus edge
                    x(x>=w/2)=x(x>=w/2)-w;
                    x(x<-w/2)=x(x<-w/2)+w;
                    y(y>=h/2)=y(y>=h/2)-h;
                    y(y<-h/2)=y(y<-h/2)+h;
                end
                % Copy shorthand into member variables
                S.dotXPx=x;
                S.dotYPx=y;
                % Flip the contrasts in case of reverse-phi motion
                if strcmpi(S.motType,'IHP')
                    % Flip rgba1 and rgba2
                    rgba1=S.dotRBGAfrac1(:)*S.scrGets.whiteIdx;
                    rgba2=S.dotRBGAfrac2(:)*S.scrGets.whiteIdx;
                    firstTrue=find(S.dotPolarity==true,1);
                    if isempty(firstTrue)
                        % rare case if all dots are the same off-color
                        if all(S.dotsRGBA(:,1)-rgba1<eps)
                            S.dotsRGBA=repmat(rgba2,1,S.nDots);
                        else
                            S.dotsRGBA=repmat(rgba1,1,S.nDots);
                        end
                    end
                    if all(S.dotsRGBA(:,firstTrue)-rgba1==0)
                        S.dotsRGBA(:,S.dotPolarity) = repmat(rgba2,1,sum(S.dotPolarity));
                        S.dotsRGBA(:,~S.dotPolarity) = repmat(rgba1,1,sum(~S.dotPolarity));
                    else
                        S.dotsRGBA(:,S.dotPolarity) = repmat(rgba1,1,sum(S.dotPolarity));
                        S.dotsRGBA(:,~S.dotPolarity) = repmat(rgba2,1,sum(~S.dotPolarity));
                    end
                end
            end
        end
    end
    methods (Access=protected)
        function ok=applyTheAperture(S)
            if strcmpi(S.apert,'CIRCLE')
                r=min(S.wPx,S.hPx)/2;
                ok=hypot(S.dotXPx,S.dotYPx)<r;
            elseif strcmpi(S.apert,'RECT')
                % no need to do anythingSC
            else
                error(['Unknown apert option: ' S.apert ]);
            end
        end
    end
    methods
        function set.motType(S,value)
            if ~any(strcmpi(value,{'phi','ihp'}))
                error('motType should be PHI or IHP (case IN-sensitive)');
            else
                S.motType=value;
            end
        end
        function set.freezeFlip(S,value)
            [b,str]=dpxIsWholeNumber(value);
            if ~b
                error(['freezeFlip should be ' str ]);
            end
            S.freezeFlip=value;
        end
    end
end


