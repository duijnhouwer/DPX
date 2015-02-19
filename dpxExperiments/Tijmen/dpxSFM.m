classdef dpxSFM < dpxAbstractStim
    
    properties (Access=public)
        %RGBAfrac; % A four element vector of values between [0..1] representing red-green-blue-opacity of the rectangle
        dotsPerSqrDeg;
        dirDeg; 
        speedDps
        apert; 
        cohereFrac;
        dotDiamDeg;
        dotRBGAfrac; 
        veloSinus; 
        veloDecline; 
        kFrac;
        pxStepsize 
        dt; 
    end
    
    properties (Access=protected)
        nDots;
        dotXPx;
        dotYPx; 
        dotDirDeg;
        pxPerFlip; 
        dotDiamPx;
        dotsRGBA;
        k; 
        x0; 
    end
    
    methods (Access=public)
        function S=dpxSFM
            S.dirDeg=0;
            S.wDeg=2;
            S.hDeg=2;
            S.dotsPerSqrDeg=pi* S.hDeg.^2; 
            S.speedDps = 1;     %not really important anymore, use pxStepSize to raise speed
            S.pxStepsize = 1/100; 
            S.apert='circle';
            S.cohereFrac=1; 
            S.dotDiamDeg=.1;
            S.kFrac = .5;       % direction coherence
            S.dotRBGAfrac=[1 1 1 1];
            S.veloSinus = 0; 
            S.veloDecline=.95;  % decline: the velocity at the edges is 10% of the velocity at x=0
            S.dt=0; 
        end
    end
    
    methods (Access=protected)
        function myInit(S)
            D2P=S.scrGets.deg2px; % xDeg * D2P = xPix
            F2I=S.scrGets.whiteIdx;
            S.nDots=max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            N=S.nDots;
            S.dotXPx = S.RND.rand(1,N) * S.wPx-S.wPx/2;
            S.x0 = S.dotXPx;
            S.dotYPx = S.RND.rand(1,N) * S.hPx-S.hPx/2;
            S.dotDirDeg = ones(1,N) * S.dirDeg;
            
            if S.cohereFrac<0, S.dotDirDeg = S.dotDirDeg + 180; end % negative coherence flips directions
            [S.dotDiamPx,wasoutofrange]=dpxClip(S.dotDiamDeg*S.scrGets.deg2px,S.scrGets.limits.GL_ALIASED_POINT_SIZE_RANGE);
            if wasoutofrange
                S.dotDiamDeg=S.dotDiamPx/S.scrGets.deg2px;
                warning(['S.dotDiamDeg was out of range for this computer, capped at the limit of ' num2str(S.dotDiamDeg) ' degrees.']);
            end
            
            if S.veloSinus  
                idx = S.RND.rand(1,N)<S.kFrac;
                S.k = zeros(1,N); 
                S.k(:, idx) = 1; 
                S.k(:, ~idx)=-1;  
            end
          
            S.pxPerFlip = S.speedDps .* D2P / S.scrGets.measuredFrameRate;
            S.dotsRGBA(:,1:N) = repmat(S.dotRBGAfrac(:)*F2I,1,N); 
        end
        
        function myDraw(S)
            ok=applyTheAperture(S);
            if ~any(ok), return; end
            xy=[S.dotXPx(:)+S.xPx S.dotYPx(:)+S.yPx]';
            Screen('DrawDots',S.scrGets.windowPtr,xy(:,ok),S.dotDiamPx,S.dotsRGBA(:,ok),S.winCntrXYpx,1);
        end
        function myStep(S)            
            x=S.dotXPx;
            y=S.dotYPx;
            w=S.wPx;
            h=S.hPx;
            R=min(h,w)/2; 
            B = sqrt(R.^2-y.^2); 
            C = R.*cos((pi/(2*R)).*y); 
            increment = S.pxStepsize*S.pxPerFlip*ones(1,S.nDots);
            
            S.dt = S.dt+increment; 
            omega = (2*pi)./4; 
            phi = acos(S.x0./R); 
            x = B.*cos(omega.*S.dt.*S.k + phi); 
            
%             decline = pi/asin(S.veloDecline); 
%             dx =((C)./(pi*S.pxPerFlip*2)).*(sin(((pi)./(decline*B)).*(x+S.k.*increment)) - sin((pi./(decline*B)).*x)); 
%             dy =0*S.pxPerFlip;
%             
%             
%               x=x+dx;        
%               y=y+dy; 
%               B = sqrt(R^2 - y.^2);  
%               r=hypot(x,y);
%               
%                 if x(abs(x)>=B)
%                    S.k(abs(x)>=B) = -1*S.k(abs(x)>=B); 
%                end

             S.dotXPx=x;
             S.dotYPx=y;
        end       
    end 
end
% --- HELP FUNCTION ------------------------------------------------------
function ok=applyTheAperture(S)
    if strcmpi(S.apert,'CIRCLE')
        r=min(S.wPx,S.hPx)/2;
        ok=hypot(S.dotXPx,S.dotYPx)<=r;
    elseif strcmpi(S.apert,'RECT')
        % no need to do anythingSC
    else
        error(['Unknown apert option: ' S.apert ]);
    end
end