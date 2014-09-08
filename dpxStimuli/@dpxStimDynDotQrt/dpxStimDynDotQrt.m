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
    end
    methods (Access=public)
        function S=dpxStimDynDotQrt
            % Dynamic Dot Quartet stimulus for Ahmed
            % Part of DPX toolkit
            % Jacob Duijnhouwer, 2014-09-08
            
            S.dXsDeg=[-5 5 5 -5];
            S.dYsDeg=[-5 -5 5 5];
            S.delayOnsSec=[0 .5 0 .5];
            S.delayOffsSec=[.5 1 .5 1];
            S.diamsDeg=[2 2 2 2];
            S.cycleDurSec=1;
            S.RGBAsFrac={[1 1 1 1],[1 1 1 1],[1 1 1 1],[1 1 1 1]};
        end
    end
    methods (Access=protected)
        function myInit(S)
            D2P=S.physScrVals.deg2px; % xDeg * D2P = xPix
            %
            S.nDisks=numel(S.dXsDeg);
            for i=1:S.nDisks
                % calculate the rectangle into which to draw this disk
                topleftx=S.winCntrXYpx(1) + S.xPx + S.dXsDeg(i)*D2P - S.diamsDeg(i)*D2P/2;
                toplefty=S.winCntrXYpx(2) + S.yPx + S.dYsDeg(i)*D2P - S.diamsDeg(i)*D2P/2;
                botritex=S.winCntrXYpx(1) + S.xPx + S.dXsDeg(i)*D2P + S.diamsDeg(i)*D2P/2;
                botritey=S.winCntrXYpx(2) + S.yPx + S.dYsDeg(i)*D2P + S.diamsDeg(i)*D2P/2;
                S.rectsPx{i}=[topleftx toplefty botritex botritey];
                % scale the colors to this computer's whiteindex
                S.RGBAs{i}=S.RGBAsFrac{i} * S.physScrVals.whiteIdx;
            end
        end
        function myDraw(S)
            for i=1:S.nDisks
                if S.isVisibles(i)
                    Screen('FillOval',S.physScrVals.windowPtr,S.RGBAs{i},S.rectsPx{i});
                end
            end
        end
        function myStep(S)
            S2F=S.physScrVals.measuredFrameRate;
            cycleDurFlips=round(S.cycleDurSec * S2F);
            flipInCycle=mod(S.flipCounter,cycleDurFlips);
            for i=1:S.nDisks
                S.isVisibles(i)=flipInCycle>=S.delayOnsSec(i)*S2F && flipInCycle<S.delayOffsSec(i)*S2F;
            end
        end
    end
end

