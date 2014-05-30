classdef dpxBasicStim < hgsetget
    
    properties (Access=public)
        enable=true;
        onSec=0;
        durSec=1;
        xDeg=0;
        yDeg=0;
        zDeg=0;
        wDeg=1;
        hDeg=1;
        class='dpxBasicStim';
        name=''; % defaults to class when added to condition
    end
    properties (Access=protected)
        onFlip=0;
        offFlip=0;
        xPx=0;
        yPx=0;
        zPx=0;
        wPx=0;
        hPx=0;
        winCntrXYpx=[];
        physScrVals=struct;
        flipCounter=0;
    end
    methods (Access=public)
        function S=dpxBasicStim
        end
        function init(S)
            S.flipCounter=0;
        end
        function draw(S,windowPtr) %#ok<INUSD>
            S.flipCounter=S.flipCounter+1;
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            end
        end
        function step(S)
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            end
        end
    end
    methods
        function set.enable(S,value)
            if ~islogical(value) || ~isnumeric(value)
                error('Enable should be numeric or (preferably) logical');
            end
            S.enable=logical(value);
        end
    end
end