classdef dpxStimRdk < dpxBasicStim
    
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
    end
    properties (Access=protected)
        nDots;
        dotXPx;
        dotYPx;
        dotDirDeg=[];
        dotDiam;
        dotAge;
        pxPerFlip; % the speed in pixels per flip
        dotsRGBA;
        noiseDots;
    end
    methods (Access=public)
        function S=dpxStimRdk
            % Set the defaults in the constructure (here)
            S.class='dpxStimRdk';
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
        end
        function init(S,physScrVals)
            if nargin~=2 || ~isstruct(physScrVals)
                error('Needs get(dpxStimWindow-object) structure');
            end
            if isempty(physScrVals.windowPtr)
                error('dpxStimWindow object has not been initialized');
            end
            D2P=physScrVals.deg2px; % degrees to pixels
            F2I=physScrVals.whiteIdx; % fraction to index (for colors)
            % Convert settings to stimulus properties
            S.nDots=max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            N=S.nDots;
            S.wPx = S.wDeg * D2P;
            S.hPx = S.hDeg * D2P;
            S.xPx = S.xDeg*D2P;
            S.yPx = S.yDeg*D2P;
            S.winCntrXYpx=[physScrVals.widPx/2  physScrVals.heiPx/2];
            S.dotXPx = rand(1,N) * S.wPx-S.wPx/2;
            S.dotYPx = rand(1,N) * S.hPx-S.hPx/2;
            S.dotDirDeg = ones(1,N) * S.dirDeg;
            nNoiseDots = max(0,min(N,round(N * (1-abs(S.cohereFrac)))));
            S.noiseDots = Shuffle([true(1,nNoiseDots) false(1,N-nNoiseDots)]);
            noiseDirs = rand(1,N) * 360;
            S.dotDirDeg(S.noiseDots) = noiseDirs(S.noiseDots);
            if S.cohereFrac<0, S.dotDirDeg = S.dotDirDeg + 180; end % negative coherence flips directions
            S.dotDiam = max(1,repmat(S.dotDiamDeg*D2P,1,N));
            S.dotAge = floor(rand(1,N) * (S.nSteps + 1));
            S.pxPerFlip = S.speedDps * D2P / physScrVals.measuredFrameRate;
            idx = rand(1,N)<.5;
            S.dotsRGBA(:,idx) = repmat(S.dotRBGAfrac1(:)*F2I,1,sum(idx));
            S.dotsRGBA(:,~idx) = repmat(S.dotRBGAfrac2(:)*F2I,1,sum(~idx));
            S.onFlip = S.onSec * physScrVals.measuredFrameRate;
            S.offFlip = (S.onSec + S.durSec) * physScrVals.measuredFrameRate;
            S.physScrVals=physScrVals;
            S.flipCounter=0;
        end
        function draw(S,windowPtr)
            S.flipCounter=S.flipCounter+1;
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            else
                ok=applyTheAperture(S);
                if ~any(ok), return; end
                xy=[S.dotXPx(:) S.dotYPx(:)]';
                Screen('DrawDots',windowPtr,xy(:,ok),S.dotDiam(ok),S.dotsRGBA(:,ok),S.winCntrXYpx,2);
            end
        end
        function step(S)
            % Reposition the dots, use shorthands for clarity
            x=S.dotXPx;
            y=S.dotYPx;
            w=S.wPx;
            h=S.hPx;
            dx=cosd(S.dotDirDeg)*S.pxPerFlip;
            dy=sind(S.dotDirDeg)*S.pxPerFlip;
            % Update dot lifetime
            S.dotAge=S.dotAge+1;
            expired=S.dotAge>S.nSteps;
            % give new position if expired
            x(expired)=rand(1,sum(expired))*w-w/2-dx(expired);
            y(expired)=rand(1,sum(expired))*h-h/2-dy(expired);
            % give new random direction if expired and dot is noise
            rndDirs=rand(size(x))*360;
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
