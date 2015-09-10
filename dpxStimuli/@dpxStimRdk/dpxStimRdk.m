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
        freezeFlip;
    end
    properties (Access=protected)
        nDots;
        dotXPx;
        dotYPx;
        dotDirDeg=[];
        dotDiamPx;
        dotAge;
        pxPerFlip; % the speed in pixels per flip
        dotsRGBA;
        noiseDots;
        dotPolarity;
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
            S.nSteps=2;
            S.cohereFrac=1; % negative coherence flips directions
            S.apert='circle';
            S.wDeg=10;
            S.hDeg=10;
            S.motType='phi';
            S.freezeFlip=1;
        end
    end
    methods (Access=protected)
        function myInit(S)
            % Convert settings to stimulus properties
            S.nDots=max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            N=S.nDots;
            S.dotXPx = S.RND.rand(1,N) * S.wPx-S.wPx/2;
            S.dotYPx = S.RND.rand(1,N) * S.hPx-S.hPx/2;
            S.dotDirDeg = ones(1,N) * S.dirDeg;
            nNoiseDots = max(0,min(N,round(N * (1-abs(S.cohereFrac)))));
            S.noiseDots = [true(1,nNoiseDots) false(1,N-nNoiseDots)];
            S.noiseDots=S.noiseDots(S.RND.randperm(numel(S.noiseDots)));
            noiseDirs = S.RND.rand(1,N) * 360;
            S.dotDirDeg(S.noiseDots) = noiseDirs(S.noiseDots);
            if S.cohereFrac<0, S.dotDirDeg = S.dotDirDeg + 180; end % negative coherence flips directions
            [S.dotDiamPx,wasoutofrange]=dpxClip(S.dotDiamDeg*S.scrGets.deg2px,S.scrGets.limits.GL_ALIASED_POINT_SIZE_RANGE);
            if wasoutofrange
                S.dotDiamDeg=S.dotDiamPx/S.scrGets.deg2px;
                warning(['S.dotDiamDeg was out of range for this computer, capped at the limit of ' num2str(S.dotDiamDeg) ' degrees.']);
            end
            S.dotAge = floor(S.RND.rand(1,N) * (S.nSteps + 1));
            S.pxPerFlip = S.speedDps * S.scrGets.deg2px / S.scrGets.measuredFrameRate;
            S.dotPolarity = S.RND.rand(1,N)<.5;
            S.dotsRGBA(:,S.dotPolarity) = repmat(S.dotRBGAfrac1(:)*S.scrGets.whiteIdx,1,sum(S.dotPolarity));
            S.dotsRGBA(:,~S.dotPolarity) = repmat(S.dotRBGAfrac2(:)*S.scrGets.whiteIdx,1,sum(~S.dotPolarity));
        end
        function myDraw(S)
            if S.visible
                ok=applyTheAperture(S);
                if ~any(ok), return; end
                xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
                Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2);
            end
        end
        function myStep(S)
            if S.nDots==0
                return;
            end
            frozen=mod(S.stepCounter,S.freezeFlip)>0; % way of reducing framerate
            if ~frozen
                % Reposition the dots, use shorthands for clarity
                x=S.dotXPx;
                y=S.dotYPx;
                w=S.wPx;
                h=S.hPx;
                dx=cosd(S.dotDirDeg)*S.pxPerFlip*S.freezeFlip;
                dy=sind(S.dotDirDeg)*S.pxPerFlip*S.freezeFlip;
                % Update dot lifetime
                S.dotAge=S.dotAge+1;
                expired=S.dotAge>S.nSteps;
                % give new position if expired
                x(expired)=S.RND.rand(1,sum(expired))*w-w/2-dx(expired);
                y(expired)=S.RND.rand(1,sum(expired))*h-h/2-dy(expired);
                % give new random direction if expired and dot is noise
                rndDirs=S.RND.rand(size(x))*360;
                S.dotDirDeg(expired&S.noiseDots)=rndDirs(expired&S.noiseDots);
                S.dotAge(expired)=0;
                % Move the dots
                x=x+dx;
                y=y+dy;
                if dx>0
                    x(x>=w/2)=x(x>=w/2)-w;
                elseif dx<0
                    x(x<-w/2)=x(x<-w/2)+w;
                end
                if dy>0
                    y(y>=h/2)=y(y>=h/2)-h;
                elseif dy<0
                    y(y<-h/2)=y(y<-h/2)+h;
                end
                S.dotXPx=x;
                S.dotYPx=y;
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


% --- HELP FUNCTION ------------------------------------------------------

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

