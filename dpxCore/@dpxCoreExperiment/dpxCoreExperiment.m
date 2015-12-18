classdef dpxCoreExperiment < hgsetget
    
    properties (Access=public)
        paradigm; % a string, changed from expName on 2015-11-29
        expName; % kept for backward compatibility, will be removed on dpxBridgeBurningDay
        window; % a dpxCoreWindow (or derived) object, changed from 'scr' on 2015-11-30
        scr; % kept for backward compatibility, will be removed on dpxBridgeBurningDay
        nRepeats;
        conditionSequence;
        conditions;
        conduits;
        txtStart;
        txtPause;
        txtPauseNrTrials;
        txtEnd;
        txtRBGAfrac;
        breakFixTimeOutSec;
        outputFolder;
        backupFolder; % 2015-11-12
        backupStaleDays; % 2015-11-12
        plugins;
        startKey;
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
            % Part of DPX: An experiment preparation system
            % http://duijnhouwer.github.io/DPX/
            % Jacob Duijnhouwer, 2014
            try
                E.window=dpxCoreWindow;
            catch me
                disp(me.message);
                error('a:b',['An error occured in dpxCoreWindow: ' me.message '\nHas Psychtoolbox-3 been installed? (http://psychtoolbox.org/download/)']);
            end 
            E.plugins={dpxPluginComments}; % "Comments-plugin" is loaded for all experiments, more can be added (e.g., Eyelink, Arduino)
            E.conditions={};
            E.conduits={}; % a mechanism to transfer information between trials, e.g. for staircase procedures
            E.nRepeats=2;
            E.conditionSequence='shufflePerBlock';
            E.paradigm='dpxCoreExperiment';
            E.subjectId='0';
            E.startKey='space';
            E.txtStart='Press and release $STARTKEY to start'; % if txtStart is 'DAQ-pulse', start is delayed until startpulse is detected on DAQ, otherwise txtStart is shown ...
            E.txtPause='I N T E R M I S S I O N';
            E.txtPauseNrTrials=Inf;
            E.txtEnd='[-: The End :-]'; % if 'DAQ-pulse', stop is delayed until stoppulse is detected on DAQ, otherwise txtStart is shown ...
            E.txtRBGAfrac=[1 1 1 1];
            E.outputFolder='';
            E.backupFolder=fullfile(tempdir,'dpxBackups',datestr(now,'yyyy-mm-dd'));
            E.backupStaleDays=28;
            E.breakFixTimeOutSec=0.5; % blank interval after fixation interruption
        end
        function run(E)
            try
                % This is the last function to call in your experiment script, it starts
                % the experiment and saves it when finished.
                if numel(E.conditions)==0
                    dpxDispFancy('No conditions have been defined. Use dpxCoreExperiment''s ''addCondition'' method to include condition objects (typically: dpxCoreCondition).',[],[],[],'Error');
                    return;
                end
                commandwindow; % set matlab focus on command window, to prevent accidentally messing up matlab files when in fullscreen mode
                E.startTime=now;
                E.unifyConditions;
                E.createConditionSequence;
                E.sysInfo=dpxSystemInfo;
                E.createFileName; % this function also asks for subject and experimenter IDs
                E.cleanOldBackups; % this function may ask for user interaction too
                E.window.open;
                for i=1:numel(E.plugins)
                    E.plugins{i}.start(get(E));
                end
                E.showStartScreen;
                % Set the trial counter to zero
                tr=0;
                while tr<numel(E.internalCondSeq) % while, not for. we must be able to change list as we go
                    tr=tr+1; % increment the trial counter
                    cNr=E.internalCondSeq(tr);
                    CC=E.conditions{cNr}; % CC is the current conditions. Only for legibility
                    E.showProgressCli(tr); % command line interface progress information
                    % Show the intermission screen if appropriate (and make an intermediate
                    % backup save)
                    if E.txtPauseNrTrials>0 && mod(tr,E.txtPauseNrTrials)==0 && tr<numel(E.internalCondSeq)
                        E.showSaveScreen;
                        E.saveDpxd;
                        E.showIntermissionScreen;
                    end
                    % Initialize this condition, this needs information about the screen. We
                    % pass it the values using get, not the object itself because we don't want
                    % the condition to be able to (inadvertently) make changes to the screen
                    % object.
                    CC.init(get(E.window));
                    % Technically backRGBA is a condition property, but to save the need to
                    % define it for all conditions I keep it in the window class, with an
                    % optional override in the condition class in case a different background
                    % color is needed. Here we deal with that override:
                    if numel(CC.overrideBackRGBA)==4
                        defaultBackRGBA=E.window.backRGBA;
                        E.window.backRGBA=CC.overrideBackRGBA;
                        E.window.clear;
                    end
                    % If there are any conduits added to the experiment, iterate over them now
                    % and update the condition settings according to how the conduit is defined
                    % and on information store at the end of the previous trial (see below). If
                    % this is the first trial the conduit will know about that and either do
                    % nothing or initialize itself, depending on how it is defined. See
                    % dpxConduitTest and dpxConduitQuest for examples.
                    for i=1:numel(E.conduits)
                        CC=E.conduits{i}.fromPreviousTrial(CC);
                    end
                    % Now present this condition until its duration has passed (or until escape
                    % is pressed, fixation is broken ...)
                    [completionStr,timing,resp,nrMissedFlips]=CC.show;
                    % Handle the completion status of the trial
                    if strcmpi(completionStr,'Escape')
                        % The Escape button was pressed. Stop the experiment
                        break;
                    elseif strcmpi(completionStr,'Pause')
                        % The pause button was pressed. The current trials is lost, it can be
                        % recognized in the data file by stopSec==-1
                        newTr=tr+ceil(rand*(numel(E.internalCondSeq)-tr)); % pick a new trial number for this condition to be tried again
                        E.internalCondSeq=[E.internalCondSeq(1:newTr-1) cNr E.internalCondSeq(newTr:end)];
                        E.showPauseScreen; % Show the pause screen (with plugin UIs)
                    elseif strcmpi(completionStr,'BreakFixation')
                        % Fixation ouside required area.The current trials is lost, it can be
                        % recognized in the data file by stopSec==-1
                        newTr=tr+ceil(rand*(numel(E.internalCondSeq)-tr)); % pick a new trial number for this condition to be tried again
                        E.internalCondSeq=[E.internalCondSeq(1:newTr-1) cNr E.internalCondSeq(newTr:end)];
                        E.showBreakFixScreen; % Show the eyelink options
                    elseif strcmpi(completionStr,'RedoTrial')
                        newTr=tr+ceil(rand*(numel(E.internalCondSeq)-tr)); % pick a new trial number for this condition to be tried again
                        E.internalCondSeq=[E.internalCondSeq(1:newTr-1) cNr E.internalCondSeq(newTr:end)];
                    elseif strcmpi(completionStr,'RedoTrialNow')
                        newTr=tr+1;
                        E.internalCondSeq=[E.internalCondSeq(1:newTr-1) cNr E.internalCondSeq(newTr:end)];
                    elseif ~strcmpi(completionStr,'OK')
                        error(['Unknown completion status: ''' completionStr '''.']);
                    end
                    % Store the condition number, the start and stop time, and the response
                    % output (which may be empty if no response is required).
                    E.trials(tr).trialnr=tr;
                    E.trials(tr).condition=cNr;
                    E.trials(tr).startSec=timing.startSec;
                    E.trials(tr).stopSec=timing.stopSec;
                    E.trials(tr).resp=resp;
                    E.trials(tr).nrMissedFlips=nrMissedFlips;
                    % If there are any conduits added to the experiment, iterate over them now
                    % and get the information it is allowed to have to change settings of a
                    % future (typically next) condition (see above)
                    for i=1:numel(E.conduits)
                        E.conduits{i}.toNextTrail(CC.stims,E.trials(tr));
                    end
                    % If an overriding RGBA has been defined in this condition, reset the
                    % window object's backRGBA to its default,
                    if numel(CC.overrideBackRGBA)==4
                        E.window.backRGBA=defaultBackRGBA;
                    end
                end
                E.stopTime=now;
                for i=1:numel(E.plugins)
                    E.plugins{i}.stop;
                end
                E.showFinalSaveScreen;
                E.saveDpxd;
                E.showEndScreen;
                E.window.close;
                r=input('Run dpxToolCommentEditor? [y|N] > ','s');
                if strcmpi(strtrim(r),'y')
                    absFileName=fullfile(E.outputFolder,E.outputFileName);
                    dpxToolCommentEditor('filename',absFileName);
                end
            catch me
                sca; % screen reset
                ListenChar(0);
                rethrow(me);
            end
        end
        function addCondition(E,C)
            if ~isobject(C) || isempty(strfind(class(C),'Condition')) || strncmp(class(C),'dpx',numel('dpx'))==0
                error('Argument should be an object whose class-name contains ''Condition'', typically ''dpxCoreCondition''.');
            end
            E.conditions{end+1}=C;
        end
        function addConduit(E,U)
            if ~isobject(U) || strncmp(class(U),'dpxConduit',numel('dpxConduit'))==0
                error('Argument should be an object whose class-name starts with ''dpxConduit''.');
            end
            E.conduits{end+1}=U;
        end
        function addPlugin(E,P)
            % note, the dpxPluginComments is loaded by default
            if ~isobject(P) || strncmp(class(P),'dpxPlugin',numel('dpxPlugin'))==0
                error('Argument should be an object whose class-name starts with ''dpxPlugin''.');
            end
            E.plugins{end+1}=P; % e.g. dpxPluginEyelink
        end
    end
    methods (Access=protected)
        function saveDpxd(E)
            % Convert the data
            D.exp=get(E);
            D.exp=rmfield(D.exp,{'window','conditions','plugins','outputFileName','outputFolder','backupFolder','backupStaleDays','trials'});
            if isfield(D.exp,'expName')
                if now>dpxBridgeBurningDay && strcmpi(dpxGetUserName,'jacob')
                    warning('Property ''expName'' should be removed from dpxCoreExperiment class');
                end
                D.exp=rmfield(D.exp,'expName');
            end
            if isfield(D.exp,'scr')
                if now>dpxBridgeBurningDay && strcmpi(dpxGetUserName,'jacob')
                    warning('Property ''scr'' should be removed from dpxCoreExperiment class');
                end
                D.exp=rmfield(D.exp,'scr');
            end
            D.window=dpxGetSetables(E.window);
            if isfield(D.window,'winRectPx')
                if now>dpxBridgeBurningDay && strcmpi(dpxGetUserName,'jacob')
                    warning('Property ''winRectPx'' should be removed from dpxCoreWindow class');
                end
                D.window=rmfield(D.window,'winRectPx');
            end
            D.window.measuredFrameRate=E.window.measuredFrameRate;
            D=dpxFlattenStruct(D);
            % Format the conditions
            for c=1:numel(E.conditions)
                for s=1:numel(E.conditions{c}.stims)
                    stimname=E.conditions{c}.stims{s}.name;
                    % this is why unique stimulus names are required
                    TMP.(stimname)=dpxGetSetables(E.conditions{c}.stims{s});
                    TMP.(stimname)=rmfield(TMP.(stimname),'name');
                end
                for s=1:numel(E.conditions{c}.trigs)
                    trigname=E.conditions{c}.trigs{s}.name;
                    TMP.trialtrigger.(trigname)=dpxGetSetables(E.conditions{c}.trigs{s});
                    TMP.trialtrigger.(trigname)=rmfield(TMP.trialtrigger.(trigname),'name');
                end
                if c==1
                    % preallocate
                    C(1:numel(E.conditions))=dpxFlattenStruct(TMP);
                else
                    % insert in preallocated array
                    C(c)=dpxFlattenStruct(TMP); %#ok<AGROW>
                end
            end
            % Format the conduits
            clear TMP;
            if numel(E.conduits)==0
                CNDT=struct; % empty struct
            else
                for c=1:numel(E.conduits)
                    name=E.conduits{c}.name;
                    % this is why unique trialtrigger names are required
                    TMP.(name)=dpxGetSetables(E.conduits{c});
                    TMP.(name)=rmfield(TMP.(name),'name');
                    if c==1
                        % preallocate
                        CNDT(1:numel(E.conduits))=dpxFlattenStruct(TMP);
                    else
                        % insert in preallocated array
                        CNDT(c)=dpxFlattenStruct(TMP); %#ok<AGROW>
                    end
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
                end
                P=dpxFlattenStruct(TMP);
                clear TMP;
            end
            % Get the settings for all trials
            DPXD=cell(1,numel(E.trials));
            for t=1:numel(E.trials)
                TMP=dpxFlattenStruct(E.trials(t));
                condNr=TMP.condition;
                DPXD{t}=dpxMergeStructs({D,P,CNDT,TMP,C(condNr)},'overwrite');
                DPXD{t}=dpxStructMakeSingleValued(DPXD{t});
                DPXD{t}.N=1;
            end
            DPXD=dpxdMerge(DPXD); %#ok<NASGU>
            % Save the data
            absFileName=fullfile(E.outputFolder,E.outputFileName);
            save(absFileName,'DPXD','-v7.3');
            if ~isempty(E.backupFolder)
                save(fullfile(E.backupFolder,E.outputFileName),'DPXD','-v7.3');
            end
            dpxDispFancy(['Data has been saved to: ''' absFileName ''''],[],[],[],'*Comment');  
        end
        function showStartScreen(E)
            if strcmpi(E.txtStart,'DAQ-pulse')
                % magic value for E.txtStart, wait for pulse on DAQ device
                str=['Waiting for ' E.txtStart ' ... '];
                dpxDispFancy(str);
                dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',4,'resetCounter',false,'maxWaitSeconds',Inf);
                E.txtStart=[E.txtStart ' @ ' num2str(seconds,'%12f')];
            else
                dpxDisplayText(E.window.windowPtr,E.txtStart,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'key',E.startKey);
            end
        end
        function showSaveScreen(E)
            str=[E.txtPause '\n\nSaving data ...'];
            dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
        end
        function showIntermissionScreen(E)
            str=[E.txtPause '\n\nPress and release $STARTKEY to continue'];
            dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'fadeInSec',-1);
        end
        function showPauseScreen(E)
            if numel(E.plugins)>0
                str='P A U S E D';
                for i=1:numel(E.plugins)
                    for o=1:numel(E.plugins{i}.pauseMenuKeyStrCell)
                        str=[str '\n' E.plugins{i}.pauseMenuKeyStrCell{o} ' - ' E.plugins{i}.pauseMenuInfoStrCell{o}]; %#ok<AGROW>
                    end
                end
                dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'fadeInSec',0,'forceAfterSec',0,'fadeOutSec',-1);
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
            str=['P A U S E D\n\nPress and release $STARTKEY to continue'];
            dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'fadeInSec',-1,'key',E.startKey);
        end
        function showBreakFixScreen(E)
            disp('Gaze fixation lost ... ');
            dpxDisplayText(E.window.windowPtr,'','rgba',E.window.backRGBA,'rgbaback',E.window.backRGBA,'fadeInSec',0,'fadeOutSec',0,'forceAfterSec',E.breakFixTimeOutSec,'commandWindowToo',true);
        end
        function showFinalSaveScreen(E)
            if strcmpi(E.txtEnd,'DAQ-pulse')
                % magic value for E.txtStart, wait for pulse on DAQ device
                maxWaitSec=60;
                str=['Waiting for ' E.txtEnd ' (max ' num2str(maxWaitSec) ' seconds) ... '];
                dpxDispFancy(str);
                dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',0,'resetCounter',false,'maxWaitSeconds',maxWaitSec);
                E.txtEnd=[E.txtEnd ' @ ' num2str(seconds,'%.12f')];
            end
            str=[E.txtEnd '\n\nSaving data ...\n\n\n\n'];
            dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
        end
        function showEndScreen(E)
            str=[E.txtEnd '\n\nData has been saved to:\n' E.outputFolder '\\n' E.outputFileName '\n\n(Press $STARTKEY to continue)'];
            dpxDisplayText(E.window.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.window.backRGBA,'fadeOutSec',-1,'commandWindowToo',false,'key',E.startKey);
        end
        function createFileName(E)
            if ~exist(E.outputFolder,'file')
                try mkdir(E.outputFolder);
                catch me, error([me.message ' mkdir ' E.outputFolder]);
                end
            end
            E.subjectId=dpxInputValidId('Subject ID > ');
            E.experimenterId=dpxInputValidId('Experimenter ID > ');
            E.outputFileName=[E.paradigm '-' E.subjectId '-' datestr(now,'yyyymmddHHMMSS') '.mat'];
            % Test if this filename can be saved.
            testfile=fullfile(E.outputFolder,E.outputFileName);
            
            dummydata=666; %#ok<NASGU>
            if exist(testfile,'file')
                % Extremely rare/impossible because of date+time in name
                error(['A file with name ' testfile ' already exists.']);
            end
            try % test saving to the file before running the experiment
                save(testfile,'dummydata','-v7.3');
                delete(testfile);
            catch me
                error([me.message ' : ' testfile]);
            end
            if ~isempty(E.backupFolder)
                testbackupfile=fullfile(E.backupFolder,E.outputFileName);
                try
                    if ~exist(E.backupFolder,'dir')
                        mkdir(E.backupFolder);
                    end
                    save(testbackupfile,'dummydata','-v7.3');
                    delete(testbackupfile);
                catch me
                    error([me.message ' : ' testbackupfile]);
                end
            end
        end
        function cleanOldBackups(E)
            % Check if there are backups in the currently defined backup location
            % (E.backupFolder) that are older than E.backupStaleDays. If so, offer to
            % delete them. 2015-11-12
            if isempty(E.backupFolder)
                return;
            end
            folderparts=regexp(E.backupFolder,filesep,'split');
            allbackupfolders=dpxGetFolders(fullfile(folderparts{1:end-1}));
            tooOld=false(size(allbackupfolders));
            for i=1:numel(allbackupfolders)
                folderparts=regexp(allbackupfolders{i},filesep,'split');
                tooOld(i)=now-datenum(folderparts{end},'yyyy-mm-dd')>abs(E.backupStaleDays);
            end
            if any(tooOld)
                if E.backupStaleDays>0
                    disp(['There are stale backups (>' num2str(E.backupStaleDays) ' days) in your tempdir (''' fullfile(folderparts{1:end-1}) ''').']);
                    doDelete=~strcmpi(strtrim(input('Delete stale backups? [y|N] >> ','s')),'n');
                else
                    doDelete=true; % delete stale backups without prompting
                end
                if doDelete
                    for i=find(tooOld(:)')
                        try
                            rmdir(allbackupfolders{i},'s');
                        catch me
                            warning([me.message ' : ' allbackupfolders{i}]);
                        end
                    end
                end
            end
        end
        function unifyConditions(E)
            % Before we start running the experiment, make sure all conditions have the
            % same stimuli, this is required for the output format (DPXD). If one or
            % more conditions have been defined without the same stimuli (as defined by
            % the stimulus name) ADD placeholder stimuli with default values BUT SET
            % their visibility and durSec fields to 0. (Setting either to 0 would
            % suffice but doing both for clarity.) Prior to the introduction of this
            % function it was necessary to define all stimuli for all conditions, even
            % when the stimuli were not used in that condition.
            
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
                    dummy.enabled=false;
                    dummy.visible=false;
                    E.conditions{i}.addStimulus(dummy);
                end
            end
        end
        function createConditionSequence(E)
            % If the user defined E.conditionSequence as a list of numbers, use this as
            % the condition sequence. Otherwise, if E.conditionSequence is an
            % option-string, create a list on the option provided.
            if all(dpxIsWholeNumber(E.conditionSequence))
                % a predefined order list is given
                E.internalCondSeq=E.conditionSequence(:)';
            elseif strcmpi(E.conditionSequence,'shufflePerBlock')
                seq=[];
                for i=1:E.nRepeats
                    seq=[seq randperm(numel(E.conditions))]; %#ok<AGROW>
                end
                E.internalCondSeq=seq;
            elseif strcmpi(E.conditionSequence,'notShuffled')
                E.internalCondSeq=repmat(1:numel(E.conditions),1,E.nRepeats);
            else
                error('Illegal conditionSequence option');
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
            maxDigits=floor(log10(N))+1;
            numformat=['%.' num2str(maxDigits) 'd'];
            tStr=datestr(now,'HH:MM:SS');
            relTStr=datestr(now-E.startTime,'HH:MM:SS');
            str=sprintf(['Trial: ' numformat '/' numformat ' (%.3d %%); Condition: ' numformat '; Start: %s (%s).\n'], tr,N,fix(tr/N*100),E.internalCondSeq(tr),tStr,relTStr);
            fprintf('%s',str);
        end
    end
    methods
        function set.expName(E,value)
            daysleft=floor(dpxBridgeBurningDay-now)-10;
            if daysleft>=0
                warning('a:b',['The property ''expName'' has been renamed to ''paradigm''.\nYou should update your script within ' num2str(daysleft) ' days or this warning will turn into an error']);
            else
                warning('a:b',['The property ''expName'' has been renamed to ''paradigm''.\nPlease update your script.']);
            end
            E.paradigm=value; %#ok<MCSUP>
        end
        function set.scr(E,value) %#ok<INUSD>
            error('a:b','The property ''scr'' has been renamed to ''window'' since 2015-11-30.\nPlease update your script.');
        end
        function set.paradigm(E,value)
            if ~ischar(value) || isempty(value)
                error('The property ''paradigm'' must be a (non-empty) string');
            elseif any(E.paradigm=='-')
                error('The ''paradigm'' string can''t contain ''-''');
                % DPX uses - to split filesnames into paradigm, subject, and start-time.
            elseif ~all(isstrprop(E.paradigm,'alphanum'))
            else
                E.paradigm=value;
            end
        end
        function set.outputFolder(E,value)
            if isempty(value)
                if IsWin
                    userhomedir=[getenv('HOMEDRIVE') getenv('HOMEPATH')];
                    value=fullfile(userhomedir,'dpxData');
                elseif IsOSX || IsLinux
                    value='~/dpxData';
                else
                    error('Unsupported OS!');
                end
            end
            error(dpxTestFolderNameValidity(value));
            E.outputFolder=value;
        end
        function set.conditionSequence(E,value)
            strOpts={'shufflePerBlock','notShuffled'};
            if any(strcmpi(value,strOpts)) || all(dpxIsWholeNumber(value))
                E.conditionSequence=value;
                % call the creation function to further test the validity of value, the
                % creation function will be called for real in the E.run method
                createConditionSequence(E);
            else
                str=sprintf(' ''%s''',strOpts{:});
                error(['conditionSequence should be list of whole numbers, or any of:' str '.']);
            end
        end
        function set.startKey(E,value)
            [ok,str]=dpxIsKbName(value);
            if ok
                E.startKey=value;
            else
                error(['dpxCoreExperiment.startKey should be ' str]);
            end
        end
        function set.backupStaleDays(E,value)
            if isnumeric(value) && round(value)-value==0
                E.backupStaleDays=value;
            else
                error('backupStaleDays must be an integer. Negative values denote delete backups older than (abs(backupStaleDays)) without prompting');
            end
        end
    end
end