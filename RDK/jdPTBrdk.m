% jdPTBrdk
% Random dot kinematogram
% Jacob Duijnhouwer, May 2014


function jdPTBrdk
    try
        [E,windowPtr]=jdPTBprepExperiment('winRect',[]);
        E=jdPTBrunExperiment(E,windowPtr,@settings2stim,@showStim);
        jdPTBsaveExperiment(E,'final',windowPtr);
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end

% --- FUNCTIONS -----------------------------------------------------------

function stim=settings2stim(C,physScr)
    try
        % C is the struct with condition parameters (from Settings-file)
        %
        % shorthands for legibility
        D2P=physScr.deg2px; % degrees to pixels
        F2S=physScr.frameDurSecs; % frames to seconds
        F2I=physScr.whiteIdx; % fraction to index (for colors)
        % Check the settings values
        if abs(C.cohereFrac)>1, jdPTBerror('cohereFrac exceeds [-1 .. 1]'); end
        if any(C.fixRGBAfrac>1 | C.fixRGBAfrac<0), jdPTBerror('fixRGBfrac exceeds [0 .. 1]'); end
        if C.stimOnSecs<0, jdPTBerror('stimOnSecs less than 0 seconds'); end
        % Convert settings to stimulus properties
        N=max(0,round(C.dotsPerSqrDeg * C.apertWdeg * C.apertHdeg));
        stim.widPx = C.apertWdeg*D2P;
        stim.heiPx = C.apertHdeg*D2P;
        stim.onFlips = round(C.stimOnSecs/F2S);
        stim.preFlips = round(C.stimOnDelaySecs/F2S);
        stim.postFlips = round(C.maxReactionTimeSecs/F2S);
        stim.apert = C.apertShape;
        stim.pospx.x = physScr.widPx/2 + C.apertXdeg*D2P;
        stim.pospx.y = physScr.heiPx/2 + C.apertYdeg*D2P;
        stim.xPx = rand(1,N) * stim.widPx-stim.widPx/2;
        stim.yPx = rand(1,N) * stim.heiPx-stim.heiPx/2;
        stim.dotdirdeg = ones(1,N) * C.dirDeg;
        stim.cohereFrac = ones(1,N) * C.cohereFrac;
        nNoiseDots = max(0,min(N,round(N * (1-abs(C.cohereFrac)))));
        stim.noiseDot = Shuffle([true(1,nNoiseDots) false(1,N-nNoiseDots)]);
        noiseDirs = rand(1,N) * 360;
        stim.cohereFrac(stim.noiseDot) = noiseDirs(stim.noiseDot);
        if C.cohereFrac<0, stim.cohereFrac = stim.cohereFrac + 180; end % negative coherence flips directions
        stim.dotsize = repmat(C.dotRadiusDeg*D2P,1,N);
        stim.dotage = floor(rand(1,N) * (C.nSteps + 1));
        stim.maxage = C.nSteps;
        stim.backRGBA = C.backgroundRGBAfrac * F2I;
        stim.pxpflip = C.speedDps*D2P*F2S;
        idx = rand(1,N)<.5;
        stim.dotcols(:,idx) = repmat(C.dotRBGAfrac1(:)*F2I,1,sum(idx));
        stim.dotcols(:,~idx) = repmat(C.dotRBGAfrac2(:)*F2I,1,sum(~idx));
        stim.fix.xy = C.fixXYdeg + [physScr.widPx/2 physScr.heiPx/2];
        stim.fix.rgba = C.fixRGBAfrac*F2I;
        stim.fix.size = C.fixRadiusDeg*D2P;
        stim.keyNamesStr = C.respKeys;
        stim.respEndsTrial = C.respEndsTrial;
        stim.feedback.respCorrect = C.feedbackCorrectResp;
        stim.feedback.durCorrectFlips = ceil(C.feedbackCorrectSecs/F2S);
        stim.feedback.durWrongFlips = ceil(C.feedbackWrongSecs/F2S);
        stim.feedback.visual.enable = C.feedbackVisual;
        stim.feedback.visual.dotCorrect.size = C.feedbackRadiusDeg*D2P;
        stim.feedback.visual.dotCorrect.rgba = C.feedbackCorrectRGBAfrac*F2I;
        stim.feedback.visual.dotWrong.size = C.feedbackRadiusDeg*D2P;
        stim.feedback.visual.dotWrong.rgba = C.feedbackWrongRGBAfrac*F2I;
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end

function drawStim(windowPtr,stim)
    try
        ok=applyTheAperture(stim.xPx,stim.yPx,stim.apert,stim.widPx,stim.heiPx);
        if ~any(ok), return; end
        xy=[stim.xPx(:) stim.yPx(:)];
        % offset the stimulus
        xy=xy';
        xy(1,:)=xy(1,:)+stim.pospx.x;
        xy(2,:)=xy(2,:)+stim.pospx.y;
        % draw the stimulus
        Screen('DrawDots',windowPtr,xy(:,ok),stim.dotsize(ok),stim.dotcols(:,ok),[],2);
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
    %
    function ok=applyTheAperture(x,y,apert,wid,hei)
        if strcmpi(apert,'CIRCLE')
            r=min(wid,hei)/2;
            ok=hypot(x,y)<r;
        elseif strcmpi(apert,'RECT')
            % no need to do anything
        else
            jdPTBerror(['Unknown apert option: ' apert ]);
        end
    end
end


function drawFixDot(windowPtr,fix)
    try
        Screen('DrawDots',windowPtr,fix.xy(:),fix.size,fix.rgba(:),[],2);
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end





function stim=stepStim(stim)
    try
        % Reposition the dots, use shorthands for clarity
        x=stim.xPx;
        y=stim.yPx;
        w=stim.widPx;
        h=stim.heiPx;
        dx=cosd(stim.cohereFrac)*stim.pxpflip;
        dy=sind(stim.cohereFrac)*stim.pxpflip;
        % Update dot lifetime
        stim.dotage=stim.dotage+1;
        expired=stim.dotage>stim.maxage;
        % give new position if expired
        x(expired)=rand(1,sum(expired))*w-w/2-dx(expired);
        y(expired)=rand(1,sum(expired))*h-h/2-dy(expired);
        % give new random direction if expired and dot is noise
        rndDirs=rand(size(x))*360;
        stim.cohereFrac(expired&stim.noiseDot)=rndDirs(expired&stim.noiseDot);
        stim.dotage(expired)=0;
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
        stim.xPx=x;
        stim.yPx=y;
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end


function [esc,timing,resp]=showStim(physScr,windowPtr,stim)
    % Resp will be either a response structure or the string 'EscPressed'
    % when escape was pressed to quit the experiment
    try
        vbl=Screen('Flip',windowPtr);
        N=stim.preFlips+stim.onFlips+stim.postFlips;
        endPrematurely=Inf;
        feedbackEnds=Inf;
        resp=jdPTBgetResponseKey([]);
        anwergiven=false;
        for f=1:N
            esc=jdPTBgetEscapeKey;
            if esc
                break;
            end
            if f>=stim.preFlips && f<stim.preFlips+stim.onFlips
                drawStim(windowPtr,stim);
            end
            drawFixDot(windowPtr,stim.fix);
            Screen('DrawingFinished',windowPtr);
            if f>=stim.preFlips && f<stim.preFlips+stim.onFlips
                stim=stepStim(stim);
            end
            if f>=stim.preFlips+stim.onFlips && ~anwergiven
                resp=jdPTBgetResponseKey(stim.keyNamesStr);
                if resp.number{1}~=-1
                    anwergiven=true;
                    [feedbackDurationFlips,stim.fix,normalfixdot]=jdPTBfeedback(resp.keyName{1},stim.feedback,stim.fix);
                    feedbackEnds=f+feedbackDurationFlips;
                    if stim.respEndsTrial
                        endPrematurely=feedbackEnds;
                    end
                end
            end
            if f==feedbackEnds
                stim.fix=normalfixdot;
            end
            if f>=endPrematurely
                break;
            end
            vbl=Screen('Flip',windowPtr,vbl+0.75*physScr.frameDurSecs);
            if f==1
                timing.startSecs=GetSecs;
            end
        end
        timing.stopSecs=GetSecs;
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end


