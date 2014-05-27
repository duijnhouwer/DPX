classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxFixMarker < dpxBasicStim
    
    properties (Access=public)
        shape='dot';
        wDeg=.25;
        hDeg=.25;
        RGBAfrac=[1 0 0 1];
    end
    properties (Access=private)
        xyPx;
        wPx;
        hPx;
        onFlip;
        offFlip;
        flipCounter=0;
    end
    methods
        function S=dpxFixMarker
        end
        function init(S,physScr)
            if nargin~=2 || ~isobject(physScr)
                error('Needs dpxStimWindow object');
            end
            S.type='dpxFixMarker';
            S.xyPx = [S.xDeg S.yDeg] + [physScr.widPx/2 physScr.heiPx/2];
            S.rgba = S.RGBAfrac * physScr.whiteIdx;
            S.wPx = S.wDeg * physScr.deg2px;
            S.hPx = S.hDeg * physScr.deg2px;
            S.onFlip = S.onSecs * physScr.measuredFrameRate;
            S.offFlip = (S.onSecs + S.durSecs) * physScr.measuredFrameRate;
            S.flipCounter=0;
        end
        function draw(S,windowPtr)
            S.flipCounter=S.flipCounter+1;
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            else
                if strcmpi(S.shape,'dot')
                    diam=max(S.wPx,S.hPx);
                    Screen('DrawDots',windowPtr,S.xyPx(:),diam,S.rgba(:),[],2); 
                elseif strcmpi(S.shape,'cross')
                    error('To be implemented');
                else
                    error(['Unknown shape ''' S.shape '''.']);
                end
            end
        end
    end
end
