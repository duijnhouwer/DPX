classdef dpxStimRdkShuffleStep < dpxAbstractVisualStim
    
    properties (Access=public)
        dirDeg@double;
        speedDps@double;
        dotsPerSqrDeg@double;
        dotDiamDeg@double;
        dotRBGAfrac1@double;
        dotRBGAfrac2@double;
        nSteps@double;;
        cohereFrac@double;; % negative coherence flips directions
        apert@char;
        motType@char; % use for phi or ihp, shuffle or straight
        motStartSec; % relative to stim on 2015-10-28
        motDurSec@double; % 2015-10-28
        freezeFlip@double;
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
        nStepsArray; % 2016-12-29. To make shuffle step possible
        revphiBool;
        shuffleBool;
    end
    methods (Access=public)
        function S=dpxStimRdkShuffleStep
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
            S.motType='straight,phi';
            S.motStartSec=0; % relative to stimOnSec
            S.motDurSec=Inf;
            S.freezeFlip=1;
        end
    end
    methods (Access=protected)
        function myInit(S)
            % Convert settings to stimulus properties
            S.nDots=max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            S.nDots=round(S.nDots/2)*2; % guarantee evenness, better for 50/50 split of motion directions for example
            S.revphiBool=~isempty(strfind(upper(S.motType),'IHP'));
            S.shuffleBool=~isempty(strfind(upper(S.motType),'SHUFFLE'));
            if S.shuffleBool
                S.nDots=S.compensateVisibleShuffleDots();
            end
            N=S.nDots; % shorthand for readability
            S.nStepsArray=S.makeStepArray(N,S.nSteps,S.shuffleBool);
            if ~S.shuffleBool && ~isempty(strfind(upper(S.motType),'MATCH2SHUFF'))
                S.nStepsArray=S.matchNStepsArrayToShuffle();
            end
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
            S.dotAge=floor(S.RND.rand(1,N) .* (abs(S.nStepsArray) + 1));
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
                if S.shuffleBool
                    % only show the first and last instance of a dot
                    ok=ok & (S.dotAge==0|S.dotAge==S.nStepsArray);
                end
                if ~any(ok), return; end
                xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
                Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,2);
            end
        end
        function myStep(S)
            if S.nDots==0
                return;
            end
            frozen=mod(S.stepCounter-S.motStartFlip,S.freezeFlip)>0; % way of reducing framerate
            if ~frozen
                % Reposition the dots, use shorthands for clarity. I think
                % the compiler will detect this and fix it so it doesn't
                % incur a runtime penalty. but i'm not certain about that
                % (will test someday, tic-toc away if you feel so inclined)
                x=S.dotXPx;
                y=S.dotYPx;
                w=S.wPx;
                h=S.hPx;
                % Update dot lifetime
                S.dotAge=S.dotAge+1;
                expired=S.dotAge>S.nStepsArray;
                % give new position if expired
                x(expired)=S.RND.rand(1,sum(expired))*w-w/2;
                y(expired)=S.RND.rand(1,sum(expired))*h-h/2;
                % give new random direction if expired and dot is noise
                S.dotDirRads(expired&S.noiseDots)=S.RND.rand(1,sum(expired&S.noiseDots))*2*pi;
                S.dotAge(expired)=0;
                % If inside the motion interval [motStart--motStop>, move
                % the dots. Note, dots that have just been replaced within
                % the aperture because of life-time expirations don't need
                % to shift.
                if S.stepCounter>=S.motStartFlip && S.stepCounter<S.motStopFlip
                    dx=cos(S.dotDirRads(~expired))*S.pxPerFlip*S.freezeFlip;
                    dy=sin(S.dotDirRads(~expired))*S.pxPerFlip*S.freezeFlip;
                    x(~expired)=x(~expired)+dx;
                    y(~expired)=y(~expired)+dy;
                    % Wrap the dots around if they cross a stimulus edge
                    tooRight=x>=w/2;
                    tooLeft=x<-w/2;
                    tooHigh=y>=h/2;
                    tooLow=y<-h/2;
                    x(tooRight)=x(tooRight)-w;
                    x(tooLeft)=x(tooLeft)+w;
                    y(tooHigh)=y(tooHigh)-h;
                    y(tooLow)=y(tooLow)+h;
                    % give dots that went over an hori (verti) edge a new
                    % verti (hori) position to prevent the same pattern
                    % from repeating
                    needNewX=tooHigh|tooLow;
                    x(needNewX)=S.RND.rand(1,sum(needNewX))*S.wPx-S.wPx/2;
                    needNewY=tooRight|tooLeft;
                    y(needNewY)=S.RND.rand(1,sum(needNewY))*S.hPx-S.hPx/2;
                end
                % Copy shorthand back into the member variables
                S.dotXPx=x;
                S.dotYPx=y;
                % Flip the contrasts in case of reverse-phi motion
                if S.revphiBool
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
        function checkDotsize(S,px)
            % This can't be done in a set methbod because
            % GL_ALIASED_POINT_SIZE_RANGE is only available after the
            % presentation window has opened.
            hardwareLimit=S.scrGets.limits.GL_ALIASED_POINT_SIZE_RANGE;
            if px>max(hardwareLimit) || px<min(hardwareLimit)
                error(['[' mfilename '] dotDiamDeg results in a diameter of ' num2str(px) ' pixels, which is outside the graphics card''s range of ' num2str(min(hardwareLimit)) '--'  num2str(max(hardwareLimit)) ' pixels.']);
            end
        end
        function ok=applyTheAperture(S)
            if strcmpi(S.apert,'CIRCLE')
                r=min(S.wPx,S.hPx)/2;
                ok=hypot(S.dotXPx,S.dotYPx)<r;
            elseif strcmpi(S.apert,'RECT')
                ok=true(1,S.nDots);
            else
                error(['Unknown apert option: ' S.apert ]);
            end
        end
        function nStepsArray=makeStepArray(S,nDots,nSteps,shuffleStep)
            if ~shuffleStep
                if numel(nSteps)==1
                    nStepsArray=nSteps;
                else
                    nStepsArray=repmat(nSteps(:)',1,ceil(nDots/nSteps));
                    nStepsArray=nStepsArray(1:nDots);
                end
            else
                if numel(nSteps)==1
                    nSteps=1:nSteps+1;
                end
                stepLen=diff(nchoosek(nSteps,2),[],2);
                stepLen=stepLen(S.RND.randperm(numel(stepLen)));
                nStepsArray=repmat(stepLen(:)',1,ceil(nDots/numel(stepLen)));
                nStepsArray=nStepsArray(1:nDots);
            end
            nStepsArray=nStepsArray(S.RND.randperm(numel(nStepsArray))); % decorrelate with other parameretes (e.g. RGBA)
        end
        function nStepsArray=matchNStepsArrayToShuffle(S)
            % Special case in which the signal strength of straight
            % limited lifetime motion is matched to that of shuffle
            % motion with the same limited lifetime
            if numel(S.nSteps)~=1
                error('Matching straight motion to shuffle step motion only works with a single nStep');
            end
            % K is the number of correlations between dots from one
            % frame to the next
            % Ksignal=nchoosek(S.nSteps+1,2);
            % Kall=S.nSteps*nchoosek(2*S.nSteps,2);
            fopRate=(S.nSteps-1)/S.nSteps;
            nFop=round(fopRate*S.nDots);
            fop=[false(1,nFop) true(1,S.nDots-nFop)];
            fop=fop(S.RND.randperm(numel(fop)));
            fop=fop(1:S.nDots);
            nStepsArray=repmat(S.nSteps,1,S.nDots); % expand the scalar nSteps to an array
            nStepsArray(fop)=0; % so we can set the fop-dots to not step
        end
        function nDots=compensateVisibleShuffleDots(S)
            % because of the shuffle-step dots only the first and
            % last instance over their lifetime are visible, the total
            % number of dots needs to be increased to achieve the requested
            % dots per square degree value
            if numel(S.nSteps)==1
                stepLen=diff(nchoosek(1:S.nSteps+1,2),[],2);
            else
                stepLen=diff(nchoosek(S.nSteps,2),[],2);
            end
            nVisible=2*numel(stepLen);
            nSimulated=sum(stepLen+1);
            nInvisible=nSimulated-nVisible;
            factor=1+nInvisible/nSimulated;
            nDots=round(S.nDots*factor);
        end
    end
    methods
        function set.motType(S,value)
            if ~ischar(value)
                error('motType should be a string containing phi or iph, straight or shuffle');
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
         function set.nSteps(S,value)
            [b,str]=dpxIsWholeNumber(value);
            if ~b
                error(['nSteps should be ' str ]);
            end
            S.nSteps=value;
        end
    end
end


