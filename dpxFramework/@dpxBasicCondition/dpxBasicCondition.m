classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxBasicCondition < hgsetget
    
    properties (Access=public)
        stims={};
        stimNames={};
        durSecs=3;
    end
    properties (Access=private)
        nFlips;
        physScrVals=struct;
        type='dpxBasicCondition';
    end
    methods (Access=public)
        function C=dpxBasicCondition
            C.stims{1}=dpxStimFix;
            C.stimNames{1}='fixMarker';
        end
        function [esc]=init(C,physScrVals)
            for s=1:numel(C.stims)
                C.stims{s}.init(physScrVals);
                C.physScrVals=physScrVals;
                C.nFlips=round(C.durSecs*C.physScrVals.measuredFrameRate);
                esc=dpxGetEscapeKey;
                if esc
                    break;
                end
            end
        end
        function [esc]=show(C)
            winPtr=C.physScrVals.windowPtr;
            if isempty(winPtr)
                error('dpxBasicCondition has not been init-ed');
            end
            vbl=Screen('Flip',winPtr);
            for f=1:C.nFlips
                if mod(f,5)==0
                    esc=dpxGetEscapeKey;
                    if esc
                        break;
                    end
                end
                for s=numel(C.stims):-1:1
                    % draw first last so is on top
                    C.stims{s}.draw(winPtr);
                end
                vbl=Screen('Flip',winPtr,vbl+0.75/C.physScrVals.measuredFrameRate);
                for s=1:numel(C.stims)
                    C.stims{s}.step;
                end
            end
        end
        function addStim(C,S,SnameStr)
            if nargin==2
                SnameStr=S.type;
            end
            C.stims{end+1}=S;
            C.stimNames{end+1}=SnameStr;
        end
    end
end