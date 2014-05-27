classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxBasicStim < hgsetget
    
    properties (Access=public)
        enable=true;
        onSecs=0;
        durSecs=1;
        xDeg=0;
        yDeg=0;
        zDeg=0;
        type='dpxBasicStim';
    end
    properties (Access=private)
        xCenterPx;
        yCenterPx;
        zCenterPx;
        scrCenterXYpx=[];
    end
    methods
        function S=dpxBasicStim
        end
        function init(S)
        end
        function draw(S,windowPtr)
        end
        function step(S,physScrValues)
        end
    end
end