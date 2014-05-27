classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxBasicStim < hgsetget
    
    properties (Access=public)
        enable=true;
        onSecs=0;
        durSecs=1;
        xDeg=0;
        yDeg=0;
        zDeg=0;
        wDeg=1;
        hDeg=1;
        type='dpxBasicStim';
        name='';
    end
    properties (Access=protected)
        onFlips=0;
        offFlips=0;
        xPx=0;
        yPx=0;
        zPx=0;
        wPx=0;
        hPx=0;
        winCntrXYpx=[];
        physScrVals=struct;
        flipCounter=0;
    end
    methods
        function S=dpxBasicStim
        end
        function init(S)
        end
        function draw(S,windowPtr)
        end
        function step(S)
        end
    end
end