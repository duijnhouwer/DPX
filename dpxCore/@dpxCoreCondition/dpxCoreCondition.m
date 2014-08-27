classdef (CaseInsensitiveProperties=true ...
        ,Description='a' ...
        ,DetailedDescription='ab') ...
        dpxCoreCondition < hgsetget
    
    
    properties (Access=public)
        % The duration of this condition (unless prematurely ended by
        % a response, see below)
        durSec=2;
        overrideBackRGBA=false; %
    end
    properties (SetAccess=protected,GetAccess=public)
        % Cell array of stimulus objects (e.g. dpxStimFix) to be added using addStim
        stims={};
        % Cell array of response objects (e.g. dpxCoreResponse) to be added using addStim
        resps={};
    end
    properties (Access=protected)
        % The duration of the trial in flips, calculated in init
        nFlips;
        % Structure that will hold copies of the getable values in physScr
        physScrVals=struct;
    end
    methods (Access=public)
        function C=dpxCoreCondition
        end
        function init(C,physScrVals)
            % Initialize the dpxCoreCondition object Store a copy of the
            % values in physScr, do not change any of these values, I would
            % make them read only if Matlab allowed me. Changing
            % physScrVals won't change the physScr object from which they
            % were derived, thus messing up any calculations that depend on
            % them.
            C.physScrVals=physScrVals;
            % Calculate the duration of the trial in flips
            C.nFlips=round(C.durSec*C.physScrVals.measuredFrameRate);
            % Initialize all stimulus objects that have been added using
            % calls to addStim in the experiment script.
            for s=1:numel(C.stims)
                C.stims{s}.init(physScrVals);
            end
            % Initialize all response objects that have been added using
            % calls to addStim in the experiment script.
            for r=1:numel(C.resps)
                C.resps{r}.init(physScrVals);
            end
        end
        function [escPressed,timingStruct,respStruct]=show(C)
            if isempty(C.physScrVals)
                error('dpxCoreCondition has not been initialized');
            end
            winPtr=C.physScrVals.windowPtr;
            escPressed=false;
            stopTrialEarlyFlip=Inf;
            % Initialize the responses with the null response
            if numel(C.resps)==0
                respStruct=[];
            else
                for r=1:numel(C.resps)
                    respStruct.(C.resps{r}.name)=C.resps{r}.resp;
                end
            end
            vbl=Screen('Flip',winPtr);
            % loop over all video-flips (frames) of the trial
            for f=1:C.nFlips
                % Check the esc key (only every Nth flip to save overhead)
                if mod(f,5)==0
                    escPressed=dpxGetEscapeKey;
                    if escPressed
                        break;
                    end
                end
                % Step the stimuli (e.g., move the random dots)
                for s=1:numel(C.stims)
                    C.stims{s}.step;
                end
                % Draw the stimuli
                for s=numel(C.stims):-1:1
                    % draw stim in reverse order so stim1 is on top
                    C.stims{s}.draw;
                end
                % Wait until it's time, then flip the video buffer
                vbl=Screen('Flip',winPtr,vbl+0.75/C.physScrVals.measuredFrameRate);
                % Collect start or stop time of the trial in seconds, right
                % after the flip for accuracy.
                if f==1
                    timingStruct.startSec=GetSecs;
                elseif f==C.nFlips
                    timingStruct.stopSec=GetSecs;
                    break;
                end
                % Get the response(s)
                for r=1:numel(C.resps)
                    if ~C.resps{r}.given
                        C.resps{r}.getResponse;
                        if C.resps{r}.given
                            respStruct.(C.resps{r}.name)=C.resps{r}.resp;
                            % Set the new end time of the trial. This way
                            % giving the response can stop the trial. If
                            % the new time exceeds the original stop time,
                            % this has no effect and the trial lasts the
                            % set initially amount.
                            stopTrialEarlyFlip=f+C.resps{r}.endsTrialAfterFlips;
                            stimHandle=C.getStimNamed(C.resps{r}.nameOfFeedBackStim);
                            if ~isempty(stimHandle)
                                % Initialize the feedback stimulus so it
                                % will be visible from now until
                                % now+durSec. Because of this only simple
                                % stimuli that do not require a lot of time
                                % for initialization can be used. If this
                                % is a problem a slight redesign of the
                                % feedback system will be required.
                                stimHandle.init(C.physScrVals);
                                stimHandle.visible=true;
                            end
                        end
                    end
                end
                % If the response ends the trial, that happens here
                if f>=stopTrialEarlyFlip
                    timingStruct.stopSec=GetSecs;
                    break;
                end
            end
            for s=1:numel(C.stims)
                % call the clear of (all) the stimulus object(s)
                C.stims{s}.clear;
            end
            for r=1:numel(C.resps)
                % call the clear of (all) the response object(s)
                C.resps{r}.clear;
            end
        end
        function addStim(C,S)
            % add a stimulus object to the condition
            if isempty(S.name)
                % If no name is provided (not recommended) use the class
                % name of the object as the stimulus name that will show up
                % in the output dpxTbl struct
                S.name=class(S);
            end
            % Store all values of the public (interface) variables of the stimulus so
            % the condition can be reset during init before a repeat of the same
            % conditon is shown;
            S.lockInitialPublicState;
            C.stims{end+1}=S;
            % Check that the name is not 'none', this is reserved name (see
            % dpxCoreResponse)
            if strcmpi(S.name,'none')
                error(['Reponse object name cannot be ''' R.name '''.']);
            end
            % Check that all stimuli have unique names
            nameList=cellfun(@(x)get(x,'name'),C.stims,'UniformOutput',false);
            if numel(nameList)~=numel(unique(nameList))
                disp(nameList);
                error('All stimuli in a condition need unique name fields');
            end
        end
        function addResp(C,R)
            % add a response object to the condition
            if isempty(R.name)
                R.name=class(R);
            end
            C.resps{end+1}=R;
            % Check that the name is not 'none', this is an reserved name
            if strcmpi(R.name,'none')
                error(['Reponse object name cannot be ''' R.name '''.']);
            end
            % Check that all responses have unique names, this is important
            % for the readability of the final output format (dpxTbl)
            nameList=cellfun(@(x)get(x,'name'),C.resps,'UniformOutput',false);
            if numel(nameList)~=numel(unique(nameList))
                disp(nameList);
                error('All stimuli in a condition need unique name fields');
            end
        end
    end
    methods (Access=protected)
        function stimHandle=getStimNamed(C,name)
            % Returns a handle to the stimulus whose name field corresponds
            % to the string in name
            stimHandle=[];
            if strcmpi(name,'none')
                return;
            end
            for s=1:numel(C.stims)
                if strcmpi(C.stims{s}.name,name)
                    stimHandle=C.stims{s};
                    return;
                end
            end
            error(['No stimulus named ''' name ''' exists.']);
        end
    end
    methods
        function set.overrideBackRGBA(C,value)
            ok=(islogical(value) && value==false) || (isnumeric(value) && numel(value)==4 && all(value<=1) && all(value>=0));
            if ~ok
                error('overrideBackRGBA needs to be false or a 4-element vector of numerical values between 0 and 1');
            else
                C.overrideBackRGBA=value;
            end
        end
    end
end
