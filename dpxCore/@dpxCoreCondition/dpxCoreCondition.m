classdef dpxCoreCondition < hgsetget
    
    properties (Access=public)
        % The duration of this condition (unless prematurely ended by
        % a response, see below)
        durSec=2;
        % Leave this 'false' to use the backRGBA defined in the
        % dpxCoreWindow class, or set it to a 4-element RGBA vector. The
        % advantage of this design is that the RGBA for the background
        % doesn't have to be defined for each condition as most of the time
        % the background will be the same for all conditions
        overrideBackRGBA=false; 
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
        % Structure that will hold copies of the getable values in scr
        scrGets=struct;
    end
    methods (Access=public)
        function C=dpxCoreCondition
        end
        function init(C,scrGets)
            % Initialize the dpxCoreCondition object Store a copy of the
            % values in scr, do not change any of these values, I would
            % make them read only if Matlab allowed me. Changing
            % scrGets won't change the scr object from which they were
            % derived. Doing so would mess up any calculations that depend
            % on them.
            C.scrGets=scrGets;
            % Calculate the duration of the trial in flips
            C.nFlips=round(C.durSec*C.scrGets.measuredFrameRate);
            % Initialize all stimulus objects that have been added using
            % calls to addStim in the experiment script.
            for s=1:numel(C.stims)
                C.stims{s}.init(scrGets);
            end
            % Initialize all response objects that have been added using
            % calls to addStim in the experiment script.
            for r=1:numel(C.resps)
                C.resps{r}.init(scrGets);
            end
        end
        function [completionStatus,timingStruct,respStruct,nrMissedFlips]=show(C)
            if isempty(C.scrGets)
                error('dpxCoreCondition has not been initialized');
            end
            winPtr=C.scrGets.windowPtr;
            completionStatus='ok';
            stopTrialEarlyFlip=Inf;
            % Initialize the timing struct
            timingStruct.startSec=-1;
            timingStruct.stopSec=-1;
            % Initialize the responses with the null response
            if numel(C.resps)==0
                respStruct=[];
            else
                for r=1:numel(C.resps)
                    respStruct.(C.resps{r}.name)=C.resps{r}.resp;
                end
            end
            % Initialize the video-blank timeer
            vbl=Screen('Flip',winPtr);
            % Loop over all video-flips (frames) of the trial
            nrMissedFlips=0;
            for f=1:C.nFlips
                % Check the esc key (only every Nth flip to save overhead)
                if mod(f,5)==0
                    if dpxGetEscapeKey
                        completionStatus='esc';
                        break;
                    elseif dpxGetPauseKey
                        completionStatus='pause';
                        break;
                    end 
                end
                % Step the stimuli (e.g., update random dot positions)
                for s=1:numel(C.stims)
                    C.stims{s}.step;
                end
                % Draw the stimuli
                for s=numel(C.stims):-1:1
                    % draw stims in reverse order so stims{1} is on top
                    C.stims{s}.draw;
                end
                Screen('DrawingFinished',winPtr);
                % Get the response(s)
                for r=1:numel(C.resps)
                    if ~C.resps{r}.given
                        C.resps{r}.getResponse;
                        if C.resps{r}.given || f==C.nFlips % (at final flip always store, useful for continous resp recordings)
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
                                stimHandle.init(C.scrGets);
                                stimHandle.visible=true;
                            end
                        end
                    end
                end
                % Wait until it's time, then flip the video buffer
                [vbl,~,~,dDeadlineSecs]=Screen('Flip',winPtr,vbl+0.85/C.scrGets.measuredFrameRate);
                % If this flip missed the deadline, increase the
                % nrMissedFlips counter. Note that the 'Screen flip?'
                % documentation states that "... The automatic detection of
                % deadline-miss is not fool-proof ..."
                if dDeadlineSecs>0
                    nrMissedFlips=nrMissedFlips+1; 
                end
                % Collect start or stop time of the trial in seconds, right
                % after the flip for accuracy.
                if f==1
                    timingStruct.startSec=GetSecs;
                elseif f==C.nFlips
                    timingStruct.stopSec=GetSecs;
                    break;
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
                % in the output DPXD struct
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
            % for the readability of the final output format (DPXD)
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
            ok=(islogical(value) && value==false) || dpxIsRGBAfrac(value);
            if ~ok
                error('overrideBackRGBA needs to be false or a 4-element vector of numerical values between 0 and 1');
            else
                C.overrideBackRGBA=value;
            end
        end
        function set.durSec(C,value)
            if ~isnumeric(value)
                error('Condition duration (durSec) has to be a numeric value');
            elseif value<=0
                error('Condition duration (durSec) has to be longer than zero');
            elseif value>3600*24*7
                % user probably defined the duration to be infinite (Inf)
                % and uses the response to quit the trials. The for-loop in
                % show does not take end-values larger than intmax without
                % complaining with a warning. Therefore, silently truncate
                % the value here to a week in seconds, likely enough for
                % any experiment.
                value=3600*24*7;
            end
            C.durSec=value;
        end
    end
end
