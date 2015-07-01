classdef dpxStimDynDotQrt < dpxAbstractVisualStim
    
    properties (Access=public)
        flashSec;
        pwmFrac;
        diamsDeg;
        RGBAsFrac;
        oriDeg;
        antiJump;
        bottomLeftTopRightFirst;
    end
    properties (Access=protected)
        rectsPx; % rectangles containing the disks in pixels
        diamsPx;
        showOddPair;
        RGBAs;
        diamPx;
        flipInCycle; % keep track of the number of video-flips in the DDQ cycle
    end
    methods (Access=public)
        function S=dpxStimDynDotQrt
            % Dynamic Dot Quartet stimulus for Ahmed
            % Part of DPX toolkit
            % Type: get(dpxStimDynDotQrt) for more info
            % Type: edit dpxStimDynDotQrt for full info
            %
            % Note: bottomLeftTopRightFirst nomemclature is based on oriDeg=0
            % orientation with both wDeg and hDeg positive.
            %
            % Jacob Duijnhouwer, 2014-09-08
            %
            % 2015-05-31: Added 'pwmFrac' property. For pulse width modulation. Default
            % 1: behavior identical to before addition. If, for example, .75, then
            % final 25% of flash will be invisible;
            
            S.flashSec=.25;
            S.pwmFrac=1; 
            S.diamsDeg=[1 1 1 1];
            S.RGBAsFrac={[1 1 1 1],[1 1 1 1],[1 1 1 1],[1 1 1 1]};
            S.oriDeg=0;
            S.antiJump=false;
            S.bottomLeftTopRightFirst=true;
        end
    end
    methods (Access=protected)
        function myInit(S)
            D2P=S.scrGets.deg2px; % xDeg * D2P = xPx
            %
            X=[-1 1 1 -1]/2*D2P*S.wDeg;
            Y=[1 1 -1 -1]/2*D2P*S.hDeg;
            if ~S.bottomLeftTopRightFirst
                X=-X;
            end
            if ~S.antiJump
                XY=[X(:) Y(:)];
                R=[cosd(S.oriDeg) -sind(S.oriDeg); sind(S.oriDeg) cosd(S.oriDeg)];
                XY=XY*R;
            else
                XY=[X(:) Y(:)];
                if S.bottomLeftTopRightFirst
                    a=S.oriDeg+2*atan2d(S.wDeg,S.hDeg);
                else
                    a=S.oriDeg-2*atan2d(S.wDeg,S.hDeg);
                end
                R=[cosd(a) -sind(a); sind(a) cosd(a)];
                XY=XY*R;
            end
            S.diamPx=S.diamsDeg * D2P; % to optimize Screen('FillOval')
            for i=1:4
                % calculate the rectangle into which to draw this disk
                topleftx=S.winCntrXYpx(1) + S.xPx + XY(i,1) - S.diamPx(i)/2;
                toplefty=S.winCntrXYpx(2) + S.yPx + XY(i,2) - S.diamPx(i)/2;
                botritex=S.winCntrXYpx(1) + S.xPx + XY(i,1) + S.diamPx(i)/2;
                botritey=S.winCntrXYpx(2) + S.yPx + XY(i,2) + S.diamPx(i)/2;
                S.rectsPx{i}=[topleftx toplefty botritex botritey];
                % scale the colors to this computer's whiteindex
                S.RGBAs{i}=S.RGBAsFrac{i} * S.scrGets.whiteIdx;
            end
            S.flipInCycle=0;
            S.showOddPair=true;
        end
        function myDraw(S)
            if ~S.visible
                return;
            end
            if S.showOddPair
                Screen('FillOval', S.scrGets.windowPtr, S.RGBAs{1}, S.rectsPx{1}, S.diamPx(1));
                Screen('FillOval', S.scrGets.windowPtr, S.RGBAs{3}, S.rectsPx{3}, S.diamPx(3));
            else
                Screen('FillOval', S.scrGets.windowPtr, S.RGBAs{2}, S.rectsPx{2}, S.diamPx(2));
                Screen('FillOval', S.scrGets.windowPtr, S.RGBAs{4}, S.rectsPx{4}, S.diamPx(4));
            end
        end
        function myStep(S)
            S2F=S.scrGets.measuredFrameRate;
            S.flipInCycle=S.flipInCycle+1;
            if S.flipInCycle>round(S.flashSec*2*S2F)
                S.flipInCycle=0;
            end
            S.showOddPair=S.flipInCycle<round(S.flashSec*S2F);
            %
            % Do the Pulse Width Modulation stuff (added 2015-5-31)
            if S.flipInCycle>round(S.flashSec*S.pwmFrac*S2F) && S.showOddPair
                % this is the final, blocked out part of flash1
                S.visible=false;
            elseif S.flipInCycle>round((S.flashSec+S.flashSec*S.pwmFrac)*S2F) && ~S.showOddPair
                % this is the final, blocked out part of flash2
                S.visible=false;
            else
                S.visible=true; 
            end
        end
    end
    methods
        function set.antiJump(S,value)
            if islogical(value)
                 S.antiJump=value;
            else
                error('antiJump must be logical (true or false)');
            end
        end
        function set.pwmFrac(S,value)
            if isnumeric(value) && value>=0 && value<=1
               S.pwmFrac=value; 
            else
                error('pwmFrac must be a number between 0 and 1');
            end
        end
    end
end


