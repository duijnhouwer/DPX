classdef dpxStimFix < dpxBasicStim
    
    properties (Access=public)
        shape;
        RGBAfrac;
    end
    properties (Access=private)
        RGBA;
    end
    methods
        function S=dpxStimFix
            S.class='dpxStimFix';
            S.shape='dot';
            S.wDeg=.25;
            S.hDeg=.25;
            S.RGBAfrac=[1 0 0 1];
            S.durSec=2;
        end
    end
    methods (Access=protected)
        function myInit(S)
            %if nargin~=2 || ~isstruct(physScrVals)
            %    error('Needs get(dpxStimWindow-object) struct');
            %end
            %S.winCntrXYpx = [physScrVals.widPx/2 physScrVals.heiPx/2];
            %S.xPx = S.xDeg * physScrVals.deg2px;
            %S.yPx = S.yDeg * physScrVals.deg2px;
            S.RGBA = S.RGBAfrac * S.physScrVals.whiteIdx;
            %S.wPx = S.wDeg * physScrVals.deg2px;
            %S.hPx = S.hDeg * physScrVals.deg2px;
            %S.onFlip = S.onSec * physScrVals.measuredFrameRate;
            %S.offFlip = (S.onSec + S.durSec) * physScrVals.measuredFrameRate;
            %S.physScrVals = physScrVals;
            %S.flipCounter=0;
        end
        function myDraw(S)
            %S.flipCounter=S.flipCounter+1;
            %if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
            %    return;
            %end
            if strcmpi(S.shape,'dot')
                drawDot(S);
            elseif strcmpi(S.shape,'cross')
                error('To be implemented');
            else
                error(['Unknown shape ''' S.shape '''.']);
            end
        end
    end
end

function drawDot(S)
    wPtr=S.physScrVals.windowPtr;
    diam=max(1,max(S.wPx,S.hPx));
    if strcmpi(S.physScrVals.stereoMode,'mono')
        Screen('DrawDots',wPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
    elseif strcmpi(S.physScrVals.stereoMode,'mirror')
        for buffer=0:1
            Screen('SelectStereoDrawBuffer', wPtr, buffer);
            Screen('DrawDots',wPtr,[S.xPx;S.yPx],diam,S.RGBA(:),S.winCntrXYpx,2);
        end
    else
        error(['Unknown stereoMode ''' S.stereoMode '''.']);
    end
end
