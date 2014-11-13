classdef dpxRespContiKeyboard < dpxAbstractResp
    
    properties (Access=public)
        % A single keyname to listen to (unlike dpxRespKeyboard that can be
        % provided a comma-separated list of key-names. To find out the
        % name of key press type 'KbName('UnifyKeyNames')' on the command
        % line and press Enter. Then, type 'KbName' followed by Enter and,
        % after a second, press the key you want to use.
        kbName='LeftArrow';
    end
    properties (Access=protected)
        nResponses;
        keyWasDownPrevFlip;
    end
    methods (Access=public)
        function R=dpxRespContiKeyboard
            % dpxRespContiKeyboard
            % Part of the DPX toolkit
            % http://tinyurl.com/dpxlink
            % Jacob Duijnhouwer, 2014-10-08
            %
            % This response class can be used to register continous
            % keypresses in a trial. A typical usage would be to register
            % perceptual flips of a bi-stable, ambiguous stimulus such as
            % the Necker-cube. If you require a single response that
            % perhaps also ends the trial, use an dpxRespKeyboard object
            % instead. If you require 2 or any small and fixed number of
            % responses, it's probably better to use multiple
            % dpxRespKeyboard objects instead of dpxRespContiKeyboard.
            %
            % dpxRespContiKeyboard also registers the moment a key is been
            % released after it has been pressed ('keyReleaseFlip', a value
            % of -1 indicates it was never released before the end of the
            % trial). Note that unlike the press-time, which is in ms or so
            % (GetSecs) precission, the release moment is flips-precission.
            %
            % To be able to register multiple keys that may be pressed and
            % released while other keys are pressed, the
            % dpxRespContiKeyboard class only listens to a single key,
            % unlike the dpxRespKeyboard class that can be provided a
            % comma-separated list of keys to listen to. So if you will
            % need as many dpxRespContiKeyboard objects as you have
            % alternative keys, each listening to one.
            %
            % See also: dpxRespKeyboard
        end
    end
    methods (Access=protected)
        function myInit(R)
            R.resp.keyName{1}='';
            R.resp.keySec{1}=-1;
            R.resp.keyFlip{1}=-1;
            R.resp.keyReleaseSec{1}=-1;
            R.resp.keyReleaseFlip{1}=-1;
            KbName('UnifyKeyNames');
            R.nResponses=0;
            R.keyWasDownPrevFlip=false;
            ListenChar(2);
        end
        function myGetResponse(R)
            [keyIsDown,keyTime,keyCode]=KbCheck(-1);
            if keyIsDown
                if ~R.keyWasDownPrevFlip
                    if keyCode(KbName(R.kbName));
                        % A defined key was pressed, parcel it in the resp
                        % structure for output to the caller function
                        R.nResponses=R.nResponses+1;
                        R.resp.keyName{1}=strtrim([ R.resp.keyName{1} ' ' R.kbName ]);
                        R.resp.keySec{1}(R.nResponses)=keyTime; % fake precission, in reality limited to flip rate! 
                        R.resp.keyFlip{1}(R.nResponses)=R.flipCounter; % (slightly) complicated to analyse
                        R.resp.keyReleaseSec{1}(R.nResponses)=-1; % not released yet (note: may not happen ...
                        R.resp.keyReleaseFlip{1}(R.nResponses)=-1; % ... before end of trial so could remain -1)
                    end
                    R.keyWasDownPrevFlip=true; % key is being held
                end
            elseif R.keyWasDownPrevFlip
                R.keyWasDownPrevFlip=false; % no longer holding key
                idx=max(1,R.nResponses); % could start trial holding the key, i.e., before a response was given
                R.resp.keyReleaseSec{1}(idx)=GetSecs; % fake precission, in reality limited to flip rate! 
                R.resp.keyReleaseFlip{1}(idx)=R.flipCounter; % (slightly) complicated to analyse
            end
        end
        function myClear(R) %#ok<MANU>
            ListenChar(0);
        end
    end
end