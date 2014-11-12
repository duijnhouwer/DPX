classdef dpxCoreExperiment < hgsetget
    
    properties (Access=public)
        expName;
        scr;
        nRepeats;
        conditionSequence;
        conditions;
        txtStart;
        txtPause;
        txtPauseNrTrials;
        txtEnd;
        txtRBGAfrac;
        breakFixTimeOutSec;
        outputFolder;
        plugins;
    end
    properties (Access=protected)
        outputFileName='undefined.mat';
        internalCondSeq; % ordered list of condition numbers
    end
    properties (GetAccess=public,SetAccess=protected)
        subjectId;
        experimenterId;
        startTime;
        stopTime;
        trials=struct('condition',[],'startSec',[],'stopSec',[],'resp',[]);
        sysInfo;
    end
    methods (Access=public)
        function E=dpxCoreExperiment
            % dpxCoreExperiment
            % Part of DPX framework
            % http://tinyurl.com/dpxlink
            % Jacob Duijnhouwer, 2014
            E.scr=dpxCoreWindow;
            E.plugins={dpxPluginComments}; % Comments plugin loaded for all experiments, more can be added (e.g., Eyelink plugin)
            E.conditions={};
            E.nRepeats=2;
            E.conditionSequence='shufflePerBlock';
            E.expName='dpxCoreExperiment';
            E.subjectId='0';
            E.txtStart='Press and release SPACE to start'; % if 'DAQ-pulse', start is delayed until startpulse is detected on DAQ, otherwise txtStart is shown ...
            E.txtPause='I N T E R M I S S I O N';
            E.txtPauseNrTrials=Inf;
            E.txtEnd='[-: The End :-]'; % if 'DAQ-pulse', stop is delayed until stoppulse is detected on DAQ, otherwise txtStart is shown ...
            E.txtRBGAfrac=[1 1 1 1];
            E.outputFolder='';
            E.breakFixTimeOutSec=0.5; % blank interval after fixation interruption
        end
        function run(E)
            try
                % This is the last function to call in your experiment script,
                % it starts the experiment and saves it when finished.
                if numel(E.conditions)==0
                    disp('No conditions have been defined. Use dpxCoreExperiment''s ''addCondition'' method to include condition objects (typically: dpxCoreCondition).');
                    return;
                end
                commandwindow; % set matlab focus on command window, to prevent accidentally messing up matlab files when in fullscreen DPX mode
                E.startTime=now;
                E.unifyConditions;
                E.createConditionSequence;
                E.sysInfo=dpxSystemInfo;
                E.createFileName; % this function also asks for subject and experimenter IDs
                E.scr.open;
                for i=1:numel(E.plugins)
                    E.plugins{i}.start(get(E));
                end
                E.showStartScreen;
                % Set the trial counter to zero
                tr=0;
                while tr<numel(E.internalCondSeq)
                    % not for, must be able to change list as we go
                    % increment the trial counter
                    tr=tr+1;
                    cNr=E.internalCondSeq(tr);
                    E.showProgressCli(tr);
                    % Show the itnermission screen if appropriate (and make an
                    % intermediate backup save)
                    if E.txtPauseNrTrials>0 && mod(tr,E.txtPauseNrTrials)==0 && tr<numel(E.internalCondSeq)
                        E.showSaveScreen;
                        E.save;
                        E.showIntermissionScreen;
                    end
                    % Initialize this condition, this needs information
                    % about the screen. We pass it the values using get,
                    % not the object itself.
                    E.conditions{cNr}.init(get(E.scr));
                    % Technically backRGBA is a condition property, but to save
                    % the need to define it for all conditions I keep it in
                    % the window class, with an optional override in the
                    % condition class. Here we deal with that override:
                    if numel(E.conditions{cNr}.overrideBackRGBA)==4
                        defaultBackRGBA=E.scr.backRGBA;
                        E.scr.backRGBA=E.conditions{cNr}.overrideBackRGBA;
                    end
                    % Show this condition until its duration has passed, or
                    % until escape is pressed
                    [completionStr,timing,resp,nrMissedFlips]=E.conditions{cNr}.show;
                    % Handle the completion status of the trial
                    if strcmpi(completionStr,'Escape')
                        break;
                    elseif strcmpi(completionStr,'Pause')
                        newTr=tr+ceil(rand*(numel(E.internalCondSeq)-tr));
                        E.internalCondSeq=[E.internalCondSeq(1:newTr-1) cNr E.internalCondSeq(newTr:end)];
                        E.showPauseScreen;                  
                        % the skipped trial can be recognized by stopSec==-1
                    elseif strcmpi(completionStr,'BreakFixation')
                        newTr=tr+ceil(rand*(numel(E.internalCondSeq)-tr));
                        E.internalCondSeq=[E.internalCondSeq(1:newTr-1) cNr E.internalCondSeq(newTr:end)];
                        E.showBreakFixScreen;
                        % the skipped trial can be recognized by stopSec==-1
                    elseif ~strcmpi(completionStr,'OK')
                        error(['Unknown completion status: ''' completionStr '''.']); 
                    end
                    % Store the condition number, the start and stop time,
                    % and the response output (which may be empty if no
                    % response is required).
                    E.trials(tr).trialnr=tr;
                    E.trials(tr).condition=cNr;
                    E.trials(tr).startSec=timing.startSec;
                    E.trials(tr).stopSec=timing.stopSec;
                    E.trials(tr).resp=resp;
                    E.trials(tr).nrMissedFlips=nrMissedFlips;
                    % If an overriding RGBA has been defined in this condition,
                    % reset the window object's backRGBA to its default,
                    if numel(E.conditions{cNr}.overrideBackRGBA)==4
                        E.scr.backRGBA=defaultBackRGBA;
                    end
                end
                E.stopTime=now;
                for i=1:numel(E.plugins)
                    E.plugins{i}.stop;
                end
                E.showFinalSaveScreen;
                E.save;
                E.showEndScreen;
                E.scr.close;
            catch me
                sca; % screen reset
                ListenChar(0);
                rethrow(me)
            end
        end
        function addCondition(E,C)
            E.conditions{end+1}=C;
        end
        function addPlugin(E,P)
            % note, the dpxPluginComments is loaded by default
            E.plugins{end+1}=P; % e.g. dpxPluginEyelink
        end
    end
    methods (Access=protected)
        function save(E)
            % Convert the data
            D.exp=get(E);
            D.exp=rmfield(D.exp,{'scr','conditions','plugins','outputFileName','outputFolder','trials'});
            D.scr=dpxGetSetables(E.scr);
            D.scr.measuredFrameRate=E.scr.measuredFrameRate;
            D=dpxFlattenStruct(D);
            % Format the conditions
            for c=1:numel(E.conditions)
                for s=1:numel(E.conditions{c}.stims)
                    stimname=E.conditions{c}.stims{s}.name;
                    % this is why unique stimulus names are required
                    TMP.(stimname)=dpxGetSetables(E.conditions{c}.stims{s});
                    
                end
                for s=1:numel(E.conditions{c}.trigs)
                    trigname=E.conditions{c}.trigs{s}.name;
                    % this is why unique trialtrigger names are required
                    TMP.(trigname)=dpxGetSetables(E.conditions{c}.trigs{s});
                    TMP.(trigname)=rmfield(TMP.(trigname),'name');
                end
                if c==1
                    % preallocate
                    C(1:numel(E.conditions))=dpxFlattenStruct(TMP);
                else
                    % insert in preallocated array
                    C(c)=dpxFlattenStruct(TMP); %#ok<AGROW>
                end
            end
            % Format the plugins
            clear TMP;
            if numel(E.plugins)==0
                P=struct; % empty struct
            else
                for p=1:numel(E.plugins)
                    TMP.plugin.(E.plugins{p}.name)=dpxGetSetables(E.plugins{p});
                    TMP.plugin.(E.plugins{p}.name)=rmfield(TMP.plugin.(E.plugins{p}.name),{'name','pauseMenuKeyStrCell','pauseMenuInfoStrCell'});
                    if p==1
                        % preallocate
                        P(1:numel(E.plugins))=dpxFlattenStruct(TMP);
                    else
                        % insert in preallocated array
                        P(c)=dpxFlattenStruct(TMP);
                    end
                end
            end
            % Get the settings for all trials
            data=cell(1,numel(E.trials));
            for t=1:numel(E.trials)
                TMP=dpxFlattenStruct(E.trials(t));
                condNr=TMP.condition;
                data{t}=dpxMergeStructs({D,P,TMP,C(condNr)},'overwrite');
                data{t}=dpxStructMakeSingleValued(data{t});
                data{t}.N=1;
            end
            data=dpxdMerge(data); %#ok<NASGU>
            % Save the data
            absFileName=fullfile(E.outputFolder,E.outputFileName);
            save(absFileName,'data','-v7.3');
            dpxDispFancy(['Data has been saved to: ''' absFileName '''']);
        end
        function showStartScreen(E)
            if strcmpi(E.txtStart,'DAQ-pulse')
                % magic value for E.txtStart, wait for pulse on DAQ device
                str=['Waiting for ' E.txtStart ' ... '];
                dpxDispFancy(str);
                dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',4,'resetCounter',false,'maxWaitSeconds',Inf);
                E.txtStart=[E.txtStart ' @ ' num2str(seconds,'%12f')];
            else
                dpxDisplayText(E.scr.windowPtr,E.txtStart,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA);
            end
        end
        function showSaveScreen(E)
            str=[E.txtPause '\n\nSaving data ...'];
            dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
        end
        function showIntermissionScreen(E)
            str=[E.txtPause '\n\nPress and release SPACE to continue'];
            dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'fadeInSec',-1);
        end
        function showPauseScreen(E)
            if numel(E.plugins)>0
                str='P A U S E D';
                for i=1:numel(E.plugins)
                    for o=1:numel(E.plugins{i}.pauseMenuKeyStrCell)
                        str=[str '\n' E.plugins{i}.pauseMenuKeyStrCell{o} ' - ' E.plugins{i}.pauseMenuInfoStrCell{o}]; %#ok<AGROW>
                    end
                end
                dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'fadeInSec',0,'forceAfterSec',0,'fadeOutSec',-1);
                choiceIsMade=false;
                while ~choiceIsMade
                    for i=1:numel(E.plugins)
                        choiceIsMade=E.plugins{i}.pauseMenuFunction;
                        if choiceIsMade
                            break;
                        end
                    end
                end
            end
            str='P A U S E D\n\nPress and release SPACE to continue';
            dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'fadeInSec',-1);
        end
        function showBreakFixScreen(E)
            disp('Gaze fixation interrupted ... ');
            dpxDisplayText(E.scr.windowPtr,'','rgba',E.scr.backRGBA,'rgbaback',E.scr.backRGBA,'fadeInSec',0,'fadeOutSec',0,'forceAfterSec',E.breakFixTimeOutSec,'commandWindowToo',true);
        end
        function showFinalSaveScreen(E)
            if strcmpi(E.txtEnd,'DAQ-pulse')
                % magic value for E.txtStart, wait for pulse on DAQ device
                maxWaitSec=60;
                str=['Waiting for ' E.txtEnd ' (max ' num2str(maxWaitSec) ' seconds) ... '];
                dpxDispFancy(str);
                dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',0,'resetCounter',false,'maxWaitSeconds',maxWaitSec);
                E.txtEnd=[E.txtEnd ' @ ' num2str(seconds,'%.12f')];
            end
            str=[E.txtEnd '\n\nSaving data ...\n\n'];
            dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
        end
        function showEndScreen(E)
            str=[E.txtEnd '\n\nData has been saved to:\n' E.outputFolder '\n' E.outputFileName];
            dpxDisplayText(E.scr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.scr.backRGBA,'fadeOutSec',-1,'commandWindowToo',false);
        end
        function createFileName(E)
            if ~exist(E.outputFolder,'file')
                try mkdir(E.outputFolder);
                catch me, error([me.message ' mkdir ' E.outputFolder]);
                end
            end
            E.subjectId=dpxGetValidId('Subject ID > ');
            E.experimenterId=dpxGetValidId('Experimenter ID > ');
            E.outputFileName=[E.expName '-' E.subjectId '-' datestr(now,'yyyymmddHHMMSS') '.mat'];
            testfile=fullfile(E.outputFolder,E.outputFileName);
            if exist(testfile,'file')
                % Extremely rare/impossible because of date+time in name
                error(['A file with name ' testfile ' already exists.']);
            end
            try % test saving to the file before running the experiment
                save(testfile);
                delete(testfile);
            catch me
                error([me.message ' : ' testfile]);
            end
        end
        function unifyConditions(E)
            % Before we start running the experiment, make sure all
            % conditions have the same stimuli, this is required for the
            % output format (DPXD). If one or more conditions have been
            % defined without the same stimuli (as defined by the stimulus
            % name) ADD placeholder stimuli with default values BUT SET
            % their visibility and durSec fields to 0. (Setting either to 0
            % would suffice but doing both for clarity.) Prior to the
            % introduction of this function it was necessary to define all
            % stimuli for all conditions, even when the stimuli were not
            % used in that condition.
            % Step 1: get a list of unique stimulus names and classes
            stimnames={};
            classnames={};
            for i=1:numel(E.conditions)
                for j=1:numel(E.conditions{i}.stims)
                    thisstimname=E.conditions{i}.stims{j}.name;
                    if isempty(intersect(stimnames,thisstimname))
                        stimnames{end+1}=thisstimname; %#ok<AGROW>
                        classnames{end+1}=class(E.conditions{i}.stims{j}); %#ok<AGROW>
                    end
                end
            end
            % Step 2: see which trial miss what and add a dummy-stim
            for i=1:numel(E.conditions)
                stimnamesPresent={};
                for j=1:numel(E.conditions{i}.stims)
                    stimnamesPresent{end+1}=E.conditions{i}.stims{j}.name; %#ok<AGROW>
                end
                stimnamesMissing=setxor(stimnamesPresent,stimnames);
                for j=1:numel(stimnamesMissing)
                    theClassName=classnames{strcmp(stimnamesMissing{j},stimnames)};
                    dummy=eval(theClassName);
                    dummy.name=stimnamesMissing{j};
                    dummy.durSec=0;
                    dummy.visible=false;
                    E.conditions{i}.addStim(dummy);
                end
            end
        end
        function createConditionSequence(E)
            % If the user defined E.conditionSequence as a list of numbers,
            % use this as the condition sequence. Otherwise, if
            % E.conditionSequence is an option-string, create a list on the
            % option provided.
            if isnumeric(E.conditionSequence)
                % a predefined order list is given
                E.internalCondSeq=E.conditionSequence(:)';
            elseif strcmpi(E.conditionSequence,'shufflePerBlock')
                seq=[];
                for i=1:E.nRepeats
                    seq=[seq randperm(numel(E.conditions))]; %#ok<AGROW>
                end
                E.internalCondSeq=seq;
            else
                error(['Unknown conditionSequence option: ' E.conditionSequence ]);
            end
            % Check the validity of the condition numbers in the list
            if any([E.internalCondSeq<1 E.internalCondSeq>numel(E.conditions)])
                error(['One or more elements of the conditionSequence exceed limits [1 ... ' num2str(numel(E.conditions))]);
            elseif any(E.internalCondSeq-round(E.internalCondSeq))
                error('All elements of the conditionSequence should be integers');
            end
        end
        function showProgressCli(E,tr)
            if Screen('Preference', 'Verbosity')==0
                return;
            end
            N=numel(E.internalCondSeq);
            maxDigits=ceil(log10(N));
            numformat=['%.' num2str(maxDigits) 'd'];
            tstr=datestr(now-E.startTime,'HH:MM:SS');
            str=sprintf(['Trial: ' numformat '/' numformat ' (%.3d %%); Condition: ' numformat '; Start: %s in.\n'], tr,N,fix(tr/N*100),E.internalCondSeq(tr),tstr);
            fprintf('%s',str);
        end
    end
    methods
        function set.expName(E,value)
            if ~ischar(value) || isempty(value)
                error('expName must be a string');
            elseif any(E.expName=='-')
                error('expName can''t contain ''-''');
                % DPX uses - to split filesnames into expName, subject, and start-time.
            else
                E.expName=value;
            end
        end
        function set.outputFolder(E,value)
            if isempty(value)
                if IsWin, value='C:\temp\dpxData';
                elseif IsOSX || IsLinux, value='~/dpxData';
                else error('Unsupported OS!');
                end
            end
            error(dpxTestFolderNameValidity(value));
            E.outputFolder=value;
        end
        function set.conditionSequence(E,value)
            E.conditionSequence=value;
            % call the creation function to test the validity of value, the
            % creation function will be called for real in the E.run method
            createConditionSequence(E);
        end
    end
end