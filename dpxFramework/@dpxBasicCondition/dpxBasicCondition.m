classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxBasicCondition < hgsetget
    
    properties (Access=public)
        stims={};
        stimNames={};
        durSecs=3;
    end
    properties (Access=private)
        nFlips;
        measuredFramerate=[];
        windowPtr=[];
        type='dpxBasicCondition';
    end
    methods (Access=public)
        function C=dpxBasicCondition
            C.stims{1}=dpxFixMarker;
            C.stimNames{1}='fixMarker';
        end
        function [esc]=init(C,physScr)
            for s=1:numel(C.stims)
                C.stims{s}.init(physScr);
                C.measuredFramerate=physScr.measuredFramerate;
                C.windowPtr=physScr.windowPtr;
                C.nFlips=round(C.durSecs*C.measuredFramerate);
                esc=dpxGetEscapeKey;
                if esc
                    break;
                end
            end
        end
        function [esc]=show(C)
            if isempty(C.windowPtr)
                error('dpxBasicCondition has not been init-ed');
            end
            vbl=Screen('Flip',C.windowPtr);
            for f=1:C.nFlips
                if mod(f,5)==0
                    esc=dpxGetEscapeKey;
                    if esc
                        break;
                    end
                end
                for s=numel(C.stims):-1:1
                    % draw first last so is on top
                    C.stims{s}.draw(C.windowPtr);
                end
                vbl=Screen('Flip',C.windowPtr,vbl+0.75*(1/C.measuredFramerate));
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