classdef dpxStimDynDotQrt < dpxBasicStim
    
    properties (Access=public)
        dXsDeg;
        dYsDeg;
        delayOnsSec;
        delayOffsSec;
        diamsDeg;
        cycleDurSec;
        RGBAsFrac;
    end
    properties (Access=protected)
        nDisks;
        rectsPx; % rectangles containing the disks in pixels
        diamsPx;
        isVisibles;
        RGBAs;
        diamPx;
        flipInCycle;
    end
    methods (Access=public)
        function S=dpxStimDynDotQrt
            % Dynamic Dot Quartet stimulus for Ahmed
            % Part of DPX toolkit
            % Type: get(dpxStimDynDotQrt) for more info
            % Type: edit dpxStimDynDotQrt for full info
            % Jacob Duijnhouwer, 2014-09-08   
            S.dXsDeg=[-2 2 2 -2];
            S.dYsDeg=[-2 -2 2 2];
            S.delayOnsSec=[0 .25 0 .25];
            S.delayOffsSec=[.25 .5 .25 .5];
            S.diamsDeg=[2 2 2 2];
            S.cycleDurSec=.5;
            S.RGBAsFrac={[1 1 1 1],[1 1 1 1],[1 1 1 1],[1 1 1 1]};
        end
    end
    methods (Access=protected)
        function myInit(S)
            D2P=S.physScrVals.deg2px; % xDeg * D2P = xPix
            %
            S.nDisks=numel(S.dXsDeg); % typically 4 but could be any integer
            S.isVisibles=false(1,S.nDisks);
            S.diamPx=S.diamsDeg * D2P; % to optimize Screen('FillOval')
            for i=1:S.nDisks
                % calculate the rectangle into which to draw this disk
                topleftx=S.winCntrXYpx(1) + S.xPx + S.dXsDeg(i)*D2P - S.diamPx(i)/2;
                toplefty=S.winCntrXYpx(2) + S.yPx + S.dYsDeg(i)*D2P - S.diamPx(i)/2;
                botritex=S.winCntrXYpx(1) + S.xPx + S.dXsDeg(i)*D2P + S.diamPx(i)/2;
                botritey=S.winCntrXYpx(2) + S.yPx + S.dYsDeg(i)*D2P + S.diamPx(i)/2;
                S.rectsPx{i}=[topleftx toplefty botritex botritey];
                % scale the colors to this computer's whiteindex
                S.RGBAs{i}=S.RGBAsFrac{i} * S.physScrVals.whiteIdx;
            end
            S.flipInCycle=0;
        end
        function myDraw(S)
            for i=1:S.nDisks
                if S.isVisibles(i)
                    Screen('FillOval', S.physScrVals.windowPtr, S.RGBAs{i}, S.rectsPx{i}, S.diamPx(i));
                end
            end
        end
        function myStep(S)
            S2F=S.physScrVals.measuredFrameRate;
            S.flipInCycle=S.flipInCycle+1;
            for i=1:S.nDisks
                S.isVisibles(i)=S.flipInCycle>=S.delayOnsSec(i)*S2F && S.flipInCycle<S.delayOffsSec(i)*S2F;
            end
            if S.flipInCycle>=round(S.cycleDurSec*S2F)
                S.flipInCycle=0;
            end
        end
    end
end

