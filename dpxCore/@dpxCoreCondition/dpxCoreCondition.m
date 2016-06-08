classdef dpxCoreCondition < hgsetget
    
    properties (Access=public)
        % Explanation of these public properties can be found in the constructor method
        % (i.e., function C=dpxCoreCondition, below)
        durSec;
        overrideBackRGBA;
        breakFixGraceSec;
    end
    properties (GetAccess=public,SetAccess=protected)
        % Cell array of stimulus objects (e.g. dpxStimDot) to be added using
        % addStimulus
        stims={};
        % Cell array of response objects (e.g. dpxRespKeyBoard) to be added using
        % addStimulus
        resps={};
        % Cell array of trial-trigger objects (e.g. dpxTriggerKey) to be added
        % using addTrialTrigger
        trigs={};
    end
    properties (Access=protected)
        % The duration of the trial in flips, calculated in init
        nFlips;
        % Structure that will hold copies of the getable values in window
        winGets=struct;
        % Counter for breakfixation grace period
        flipsSinceBreakFix;
        breakFixGraceFlips;
        % indices of visual stimuli, some things need to be done for visual stimuli only
        visualStimIndices;
    end
    methods (Access=public)
        function C=dpxCoreCondition
            % The duration of the condition in seconds. (Can be overridden using the
            % correctEndsTrialAfterSec and wrongEndsTrialAfterSec properties of the
            % dpxAbstractResp class)
            C.durSec=2;
            % The color of the background in DPX is defined in the dpxCoreExperiment class
            % so that it doesn't need to be defined for each condition. But if your
            % experiment required different background you can define overrideBackRGBA to
            % a 4-element RGBA vector (values between 0 and 1). Otherwise leave it false
            % (default).
            C.overrideBackRGBA=false;
            % A value that can be set to allow momentary break-fixations, e.g. to allow
            % for blinks during protracted adaptation intervals
            C.breakFixGraceSec=0.200; % how many seconds does a blink last??
            %
            C.visualStimIndices=[];
        end
        function init(C,winGets)
            % Initialize the dpxCoreCondition object Store a copy of the values in window,
            % do not change any of these values (I would make them read only if Matlab
            % allowed for that). Changing winGets won't change the window object from
            % which they were derived. Doing so would mess up any calculations that
            % depend on them. 
            C.winGets=winGets;
            % Calculate the duration of the trial in flips
            C.nFlips=round(C.durSec*C.winGets.measuredFrameRate);
            % Initialize all stimulus, response, and trigger objects that have been
            % added with their respecitve "add" functions (e.g. addStimulus)
            cellfun(@(x)init(x,winGets),C.stims);
            cellfun(@(x)init(x,winGets),C.resps);
            cellfun(@(x)init(x),C.trigs);
            % Initiatilize counters related to breakfixation (see eyelink plugin). This
            % should perhaps be moved to the eye link plugin somehow, not all
            % experiments require fixation, or even involve eyes...
            C.flipsSinceBreakFix=[];
            C.breakFixGraceFlips=round(C.breakFixGraceSec*C.winGets.measuredFrameRate);
        end
        function [completionStatus,timingStruct,respStruct,nrMissedFlips]=show(C)
            % This is the function called from dpxCoreExperiment as it works itself
            % through the list of trials...
            if isempty(C.winGets)
                error('dpxCoreCondition has not been initialized');
            end
            completionStatus='OK';
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
            % Figure out which stimulus (visual only) needs to be fixated, if any
            stimNumberToFixate=[];
            for s=C.visualStimIndices(:)'
                if C.stims{s}.fixWithinDeg>0
                    if ~isempty(stimNumberToFixate)
                        error('Only one stimulus can have fixWithinDeg>0!');
                    end
                    stimNumberToFixate=s;
                end
            end
            % Initialize the video-blank timer
            vbl=Screen('Flip',C.winGets.windowPtr,0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Loop over all video-flips (frames) of the trial
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            nrMissedFlips=0;
            breakKeys={'Escape','Pause'};
            f=0; % flipCounter, locks in 0 until f=1 is set after ...
            waitingForFixation=true; % ... the fixation stimulus is fixated (if eyelink is used) ...
            waitingForTriggers=true; % ... and the optional dpxTrialTriggers are all satified (typically keypress)
            while f<=C.nFlips
                % Lock in frame-0 until all trial-triggers are go. Stimuli with onSec<=0
                % will show already (e.g. fixation dot waiting for go-condition fixation
                % using eyelink)
                if f>0
                    f=f+1; % increment flip counter since lock release
                else
                    % Check all triggers, if all go, lift the trigger lock
                    waitingForTriggers=false;
                    for g=1:numel(C.trigs)
                        if ~C.trigs{g}.go
                            waitingForTriggers=true; % at least one is not ready
                            break
                        end
                    end
                end
                % Check the break keys
                keyIdx=dpxGetKey(breakKeys);
                if keyIdx>0
                    completionStatus=breakKeys{keyIdx};
                    break; % exit while f<=C.nFlips loop
                end
                % Step and draw the stimuli. The same terminology is used for visual and
                % non-visual stimuli.
                for s=numel(C.stims):-1:1
                    C.stims{s}.stepAndDraw(f);
                end
                Screen('DrawingFinished',C.winGets.windowPtr);
                % Check the gaze-fixation status
                if isempty(stimNumberToFixate)
                    % No fixation is required in this condition, so simply release the fixation
                    % lock immediately. In case fixation is the only thing keeping the trial in
                    % flip-zero, the trial will start in the next flip.
                    if f==0
                        waitingForFixation=false;
                    end
                else
                    % Fixation is required, check if the stimulus that needs fixation is indeed
                    % being looked at
                    [ok,str]=C.stims{stimNumberToFixate}.fixationStatus;
                    if ~ok
                        % Stimulus is not being looked at
                        if f==0
                            % there has been no fixation yet this trial, just keep waiting
                        elseif isempty(C.flipsSinceBreakFix)
                            % fixation interrupted, enter grace period
                            C.flipsSinceBreakFix=C.breakFixGraceFlips;
                        else
                            C.flipsSinceBreakFix=C.flipsSinceBreakFix-1;
                            if C.flipsSinceBreakFix<0
                                % fixation NOT restored in within the grace period window, stop the trial
                                completionStatus=str;
                                break;
                            end
                        end
                    else
                        % Stimulus is being looked at
                        if f==0 
                            % release the fixation-lock. In case fixation is the only thing keeping the
                            % trial in flip-zero, the trial will start in the next flip.
                            waitingForFixation=false;
                        else
                            if f==1
                                Eyelink('Message', 'STARTTRIAL'); % set a time-stamp in the EDF file on the Eyelink computer (this function takes ~0.000091 seconds on a 2008 iMac)
                            end
                            % fixation was restored within the graceperiod
                            C.flipsSinceBreakFix=[];
                        end
                    end
                end
                if f==0 && ~waitingForTriggers && ~waitingForFixation
                    f=1; % start the trial, timestamp collected after flip below (will correspond to STARTTRIAL in EDF if eyelink is used
                end
                % Handle the cell-array of response measure objects
                for r=1:numel(C.resps)
                    if ~C.resps{r}.given
                        C.resps{r}.getResponse(f);
                        % store when answer is given
                        if C.resps{r}.given
                            respStruct.(C.resps{r}.name)=C.resps{r}.resp;
                            % Set the new end time of the trial. This is useful for example to make a response way stop
                            % the trial. Or add a time-out period after an incorrect answer for example.
                            if C.resps{r}.endsTrialAfterFlips<Inf % endsTrialAfterFlips is Inf by default
                                C.nFlips=f+C.resps{r}.endsTrialAfterFlips;
                            end
                            % Check if we need to enable any feedback stimuli
                            for fbs=1:numel(C.resps{r}.nameOfFeedBackStim)
                                fbStimHandle=C.getStimNamed(C.resps{r}.nameOfFeedBackStim{fbs});
                                if ~isempty(fbStimHandle)
                                    % Enable this feedback stimulus, i.e., the stimulus
                                    % that is triggered by the response. It's timing
                                    % (onSec) will be relative to the current flip
                                    fbStimHandle.enabled=true;
                                end
                            end
                            % Check if this response has been set up to necessitate a redo of the
                            % condition. For example in experiments in which the subjects (typically
                            % animals) were not allowed to respond before the end of the stimulus and the
                            % trial was prematurely ended because they did. It is up to definition of
                            % the response class to set this depending on the logic of the condition
                            % (see dpxRespArduinoPulse for an example)
                            if ~strcmpi(C.resps{r}.redoTrial,'never')
                                if strcmpi(C.resps{r}.redoTrial,'immediately')
                                    completionStatus='REDOTRIALNOW';
                                elseif strcmpi(C.resps{r}.redoTrial,'sometime')
                                    completionStatus='REDOTRIAL';
                                else
                                    error(['illegal redoTrial string: ' C.resps{r}.redoTrial]);
                                end
                            end   
                        elseif f==C.nFlips
                            % If answer hasn't been given at the end of the trial, store the resp
                            % struct too. This is particularly useful (useful for recordings of
                            % continuous responses)
                            respStruct.(C.resps{r}.name)=C.resps{r}.resp;
                        end
                    end
                end
                % Wait until it's time, then flip the video buffer. The 0.85 value means
                % that we assume that 15% of the frameduration should be enoughg to flip
                % the frame, which is a conservative estimate (probable much faster). If
                % we start running into trouble with not making the flip deadline, we
                % could consider upping it to .9 or .95 for example, see what that does.
                [vbl,~,~,dDeadlineSecs]=Screen('Flip',C.winGets.windowPtr,vbl+0.85/C.winGets.measuredFrameRate);
                % Collect start or stop time of the trial in seconds. (Right after the flip
                % for accuracy)
                if f==1 % begin of condition
                    timingStruct.startSec=GetSecs;
                elseif f==C.nFlips
                    timingStruct.stopSec=GetSecs;
                    break;
                end
                % If this flip missed the deadline, increase the nrMissedFlips counter.
                % Note that the 'Screen flip?' documentation of Psychtoolbox states that
                % "... The automatic detection of deadline-miss is not fool-proof ..."
                if dDeadlineSecs>0
                    nrMissedFlips=nrMissedFlips+1;
                end
            end % while f<=C.nFlips
            % The trial is now complete, clear all stim and resp objects
            cellfun(@(x)clear(x),C.stims);
            cellfun(@(x)clear(x),C.resps);
        end  
        function addStimulus(C,S)
            % Add a stimulus object to the condition
            % Check that S is a response object
            if ~strncmp(class(S),'dpxStim',7)
                error('a:b','The object you are trying to add is not a valid stimulus object.\nIt''s classname does not start with ''dpxStim''.');
            end
            % Store all values of the public (interface) variables of the stimulus so
            % the condition can be reset during init before a repeat of the same
            % conditon is shown;
            S.lockInitialPublicState;
            C.stims{end+1}=S;
            % Check that all stimuli have unique names, this is important for the
            % output format (DPXD)
            nameList=cellfun(@(x)get(x,'name'),C.stims,'UniformOutput',false);
            if numel(nameList)~=numel(unique(nameList))
                disp(nameList);
                error('All stimuli in a condition need unique names');
            end
            % Keep a index-list of all stimuli in the stim array that are visual
            % stimuli. This will be used to iterate over stimuli to call methods or
            % check properties that only visual have
            if isprop(S,'visible')
                C.visualStimIndices(end+1)=numel(C.stims);
            end
        end
        function addResponse(C,R)
            % Add a response object to the condition
            % Check that R is a response object
            if ~strncmp(class(R),'dpxResp',7)
                error('a:b','The object you are trying to add is not a valid response object.\nIt''s classname does not start with ''dpxResp''.');
            end
            % Generate a name if none is provided (default to classname)
            if isempty(R.name)
                R.name=class(R); 
            end
            C.resps{end+1}=R;
            % Check that the name is not 'none', this is an reserved name
            if strcmpi(R.name,'none')
                error(['Reponse object name cannot be ''' R.name '''.']);
            end
            % Check that all responses have unique names, this is important for the
            % output format (DPXD)
            nameList=cellfun(@(x)get(x,'name'),C.resps,'UniformOutput',false);
            if numel(nameList)~=numel(unique(nameList))
                disp(nameList);
                error('All responses in a condition need unique names');
            end
        end
        function addTrialTrigger(C,G)
            % Add a trial-trigger object to the condition
            if isempty(G.name)
                G.name=class(G); % no name provided default to classname
            end
            C.trigs{end+1}=G;
            % Check that all trialTriggers have unique names, this is important for the
            % output format (DPXD)
            nameList=cellfun(@(x)get(x,'name'),C.trigs,'UniformOutput',false);
            if numel(nameList)~=numel(unique(nameList))
                disp(nameList);
                error('All TrialTriggers in a condition need unique names');
            end
        end
    end
    methods (Access=protected)
        function stimHandle=getStimNamed(C,name)
            % Returns a handle to the stimulus whose name field corresponds to the
            % string in name
            stimHandle=[];
            if isempty(name)
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
            end
            C.durSec=value;
        end
    end
end
