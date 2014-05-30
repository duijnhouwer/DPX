classdef dpxBasicResponse < hgsetget
    
    properties (Access=public)
        kbNames='LeftArrow,RightArrow';
        allowAfterSec=1;
        respEndsTrial=true;
    end
    methods (Access=public)
        function R=dpxBasicResponse
        end
        function [given,resp]=getResponse(R)
            [given,resp]=dpxBasicResponse.getBlankResponse;
            keys=regexp(R.kbNames,',','split');
            KbName('UnifyKeyNames');
            [keyIsDown,keyTime,keyCode]=KbCheck;
            if keyIsDown
                for i=1:numel(keys)
                    if keyCode(KbName(strtrim(keys{i})));
                        resp.keyNr=i;
                        resp.keyName=keys{i};
                        resp.keySec=keyTime;
                        given=true;
                        break;
                    end
                end
            end
        end
    end
    methods (Static)
        function [given,resp]=getBlankResponse
            given=false;
            resp=struct('keyNr',-1,'keyName','','keySec',-1);
        end
    end
end