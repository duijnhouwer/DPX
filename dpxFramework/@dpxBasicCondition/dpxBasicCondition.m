classdef dpxBasicCondition < hgsetget
    
    properties (Access=public)
        resp;
        durSec;
    end
    properties (SetAccess=protected,GetAccess=public)
        stims={};
    end
    properties (Access=protected)
        nFlips;
        physScrVals=struct;
        respAfterNrFlips;
        type='dpxBasicCondition';
    end
    methods (Access=public)
        function C=dpxBasicCondition
            C.addStim(dpxStimFix);
            C.resp=dpxBasicResponse;
            C.durSec=2;
        end
        function [esc]=init(C,physScrVals)
            for s=1:numel(C.stims)
                C.stims{s}.init(physScrVals);
                C.physScrVals=physScrVals;
                C.nFlips=round(C.durSec*C.physScrVals.measuredFrameRate);
                C.respAfterNrFlips=C.resp.allowAfterSec*C.physScrVals.measuredFrameRate;
                esc=dpxGetEscapeKey;
                if esc
                    break;
                end
            end
        end
        function [esc,timingStruct,respStruct]=show(C)
            winPtr=C.physScrVals.windowPtr;
            if isempty(winPtr)
                error('dpxBasicCondition has not been init-ed');
            end
            vbl=Screen('Flip',winPtr);
            stopEarlyFlip=Inf;
            [respGiven,respStruct]=dpxBasicResponse.getBlankResponse;
            esc=false;
            for f=1:C.nFlips
                if mod(f,5)==0 % only check escape every Nth frame
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
                if f==1
                    timingStruct.startSec=GetSecs;
                elseif f==C.nFlips
                    timingStruct.stopSec=GetSecs;
                    break;
                end
                if respGiven==false && f>=C.respAfterNrFlips
                    [respGiven,respStruct]=C.resp.getResponse;
                    if respGiven && C.resp.respEndsTrial
                        stopEarlyFlip=f;
                    end
                end
                if f==stopEarlyFlip
                    timingStruct.stopSec=GetSecs;
                    break;
                end
                for s=1:numel(C.stims)
                    C.stims{s}.step;
                end
            end
        end
        function addStim(C,S)
            if isempty(S.name)
                S.name=S.class;
            end
            C.stims{end+1}=S;
            % Check that all stimuli have unique names
            nameList=cellfun(@(x)get(x,'name'),C.stims,'UniformOutput',false);
            if numel(nameList)~=numel(unique(nameList))
                error('All stimuli in a condition need unique name fields');
            end 
        end
    end
end