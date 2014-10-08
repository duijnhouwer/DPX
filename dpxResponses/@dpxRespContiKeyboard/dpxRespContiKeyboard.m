classdef dpxRespContiKeyboard < dpxAbstractResp
    
    properties (Access=public)
        % A comma separated list of keys-names that are valid responses To
        % find out the name of key press type 'KbName('UnifyKeyNames')' on
        % the command line and press Enter. Then, type 'KbName' followed by
        % Enter and, after a second, press the key you want to use.
        kbNames='LeftArrow,RightArrow';
    end
    properties (Access=protected)
        figHandle;
        nResponses;
        keyWasDownPrevFlip;
    end
    methods (Access=protected)
        function myInit(R)
            R.resp.keyNr{1}=-1;
            R.resp.keyName{1}='';
            R.resp.keySec{1}=-1;
            KbName('UnifyKeyNames');
            R.kbNamesCell=strtrim(regexp(R.kbNames,',','split'));
            %R.figHandle=dpxCreateInvisibleEditBoxToInterceptKeypresses;
            R.nResponses=0;
            R.keyWasDownPrevFlip=false;
        end
        function myGetResponse(R)
            [keyIsDown,keyTime,keyCode]=KbCheck(-1);
            if keyIsDown 
                if ~R.keyWasDownPrevFlip
                    for i=1:numel(R.kbNamesCell)
                        if keyCode(KbName(R.kbNamesCell{i}));
                            % A defined key was pressed, parcel it in the resp
                            % structure for output to the caller function
                            R.nResponses=R.nResponses+1;
                            R.resp.keyNr{1}(R.nResponses)=i;
                            R.resp.keyName{1}=strtrim([ R.resp.keyName{1} ' ' R.kbNamesCell{i} ]);
                            R.resp.keySec{1}(R.nResponses)=keyTime;
                            
                           % i
                            %666
                            break;
                        end
                    end
                    R.keyWasDownPrevFlip=true; % key is being held
                end
            else
                R.keyWasDownPrevFlip=false; % no longer holding key
            end
        end
        function myClear(R)
            close(R.figHandle);
        end
    end
end