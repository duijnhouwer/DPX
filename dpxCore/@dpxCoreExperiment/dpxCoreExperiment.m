classdef (CaseInsensitiveProperties=false ...
        ,Description='a' ...
        ,DetailedDescription='ab') ...
        dpxCoreExperiment < hgsetget
    
    properties (Access=public)
        expName;
        physScr;
        nRepeats;
        conditionSequence;
        conditions;
        txtStart;
        txtPause;
        txtPauseNrTrials;
        txtEnd;
        txtRBGAfrac;
        outputFolder;
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
            E.physScr=dpxCoreWindow;
            E.conditions={};
            E.nRepeats=2;
            E.conditionSequence='shufflePerBlock';
            E.expName='dpxCoreExperiment';
            E.subjectId='0';
            E.txtStart='Press and release a key to start'; % if 'DAQ-pulse', start is delayed until startpulse is detected on DAQ, otherwise txtStart is shown ...
            E.txtPause='I N T E R M I S S I O N';
            E.txtPauseNrTrials=100;
            E.txtEnd='[-: The End :-]'; % if 'DAQ-pulse', stop is delayed until stoppulse is detected on DAQ, otherwise txtStart is shown ...
            E.txtRBGAfrac=[1 1 1 1];
            E.outputFolder='';
        end
        function run(E)
            % This is the last function to call in your experiment script,
            % it starts the experiment and saves it when finished. 
            E.startTime=now;
            E.unifyConditions;
            E.createConditionSequence;
            GetSecs; % Load GetSecs' MEX into memory by calling it once so the first real call will be more accurate.
            E.physScr.open;
            E.sysInfo=dpxSystemInfo;
            E.createFileName;
            E.signalFile('save');
            E.showStartScreen;
            % Set the trial counter to zero
            tr=0;
            for cNr=E.internalCondSeq(:)'
                % increment the trial counter
                tr=tr+1;
                % Show the pause screen if appropriate (and make a
                % intermediate backup save)
                if E.txtPauseNrTrials>0 && mod(tr,E.txtPauseNrTrials)==0 && tr<E.nRepeats*numel(condList)
                    E.showSaveScreen;
                    E.save;
                    E.showPauseScreen;
                end
                % Initialize this condition, this needs information
                % about the screen. We pass it the values using get,
                % not the object itself.
                E.conditions{cNr}.init(get(E.physScr));
                % Technically backRGBA is a condition property, but to save
                % the need to define it for all conditions I keep it in
                % the window class, with an optional override in the
                % condition class. Deal with that override now.
                if numel(E.conditions{cNr}.overrideBackRGBA)==4
                    defaultBackRGBA=E.physScr.backRGBA;
                    E.physScr.backRGBA=E.conditions{cNr}.overrideBackRGBA;
                end
                E.physScr.clear;
                % Show this condition until its duration has passed, or
                % until escape is pressed
                [esc,timing,resp,nrMissedFlips]=E.conditions{cNr}.show;
                if esc
                    fprintf('\nEscape pressed during show\n');
                    break;
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
                    E.physScr.backRGBA=defaultBackRGBA;
                end
            end
            E.stopTime=now;
            E.showFinalSaveScreen;
            E.save;
            E.signalFile('delete');
            E.showEndScreen;
            E.physScr.close;
        end
        function addCondition(E,C)
            E.conditions{end+1}=C;
        end
        function windowed(E,win)
            if nargin==1 && (~islogical(win) && ~(isnumeric(win) && numel(win)==4))
                error('windowed needs a second argument that is logical or a 4-element win rect');
            end     
            if islogical(win)
                if win
                    win=[10 20 500 375];
                else
                    win=[];
                end
            end
            E.physScr.winRectPx=win;
        end
    end
    methods (Access=protected)
        function save(E)
            % Convert the data
            D.exp=get(E);
            D.exp=rmfield(D.exp,{'physScr','conditions','outputFileName','outputFolder','trials'});
            D.stimwin=dpxGetSetables(E.physScr);
            D.stimwin.measuredFrameRate=E.physScr.measuredFrameRate;
            D=dpxFlattenStruct(D);
            for c=1:numel(E.conditions)
                for s=1:numel(E.conditions{c}.stims)
                    stimname=E.conditions{c}.stims{s}.name;
                    % this is why unique stimulus names are required
                    TMP.(stimname)=dpxGetSetables(E.conditions{c}.stims{s});
                end
                if c==1
                    % preallocate
                    C(1:numel(E.conditions))=dpxFlattenStruct(TMP);
                else
                    C(c)=dpxFlattenStruct(TMP);
                end
            end
            % Get the settings for all trials
            data=cell(1,numel(E.trials));
            for t=1:numel(E.trials)
                TMP=dpxFlattenStruct(E.trials(t));
                condNr=TMP.condition;
                data{t}=dpxMergeStructs({D,TMP,C(condNr)},'overwrite');
                data{t}=dpxStructMakeSingleValued(data{t});
                data{t}.N=1;
            end
            data=dpxTblMerge(data); %#ok<NASGU>
            % Save the data
            absFileName=fullfile(E.outputFolder,E.outputFileName);
            save(absFileName,'data');
            disp(['Data has been saved to: ''' absFileName '''']);
        end
        function showStartScreen(E)
            if strcmpi(E.txtStart,'DAQ-pulse')
                % magic value for E.txtStart, wait for pulse on DAQ device
                str=['Waiting for ' E.txtEnd ' ... '];
                dpxDispFancy(str);
                dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',4,'resetCounter',false,'maxWaitSeconds',Inf);
                E.txtStart=[E.txtStart ' @ ' num2str(seconds,'%12f')];
            else
                dpxDisplayText(E.physScr.windowPtr,E.txtStart,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA);
            end
        end
        function showSaveScreen(E)
            str=[E.txtPause '\n\nSaving data ...'];
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
        end
        function showPauseScreen(E)
            str=[E.txtPause '\n\nPress and release a key to continue'];
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'fadeInSec',-1);
        end
        function showFinalSaveScreen(E)
            if strcmpi(E.txtEnd,'DAQ-pulse')
                % magic value for E.txtStart, wait for pulse on DAQ device
                maxWaitSec=120;
                str=['Waiting for ' E.txtEnd ' (max ' num2str(maxWaitSec) ' seconds) ... '];
                dpxDispFancy(str);
                dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',0,'resetCounter',false,'maxWaitSeconds',maxWaitSec);
                E.txtEnd=[E.txtEnd ' @ ' num2str(seconds,'%.12f')];
            end
            str=[E.txtEnd '\n\nSaving data ...\n\n'];
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
        end
        function showEndScreen(E)
            str=[E.txtEnd '\n\nData has been saved to:\n' E.outputFolder '\n' E.outputFileName];
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA);
        end
        function createFileName(E)
            if isempty(E.outputFolder)
                if ispc, E.outputFolder='C:\temp\dpxData';
                elseif IsOSX || isunix, E.outputFolder='/tmp/dpxData';
                else error('Unsupported OS!');
                end
            end
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
        function signalFile(E,opt)
            % handy when using shared dropbox folder as the output folder,
            % indicates that someone is running the experiment and on which
            % computer.
            if strtrim(E.subjectId)=='0'
                return; % don't signal test runs
            end
            fname=['DPX=RUNNING ' E.expName ' C-'  dpxGetUserName ' S-' E.subjectId ' X-' E.experimenterId '.mat'];
            fname=dpxSanitizeFileName(fname,'fname');
            if strcmpi(opt,'save')
                save(fullfile(E.outputFolder,fname),'');
            elseif strcmpi(opt,'delete')
                delete(fullfile(E.outputFolder,fname));
            else
                error(['Unknown signalFile option ' opt]);
            end
        end
        function unifyConditions(E)
            % Before we start running the experiment, make sure all
            % conditions have the same stimuli, this is required for the
            % output format (dpxTbl). If one or more conditions have been
            % defined without the same stimuli (as defined by the stimulus
            % name) add the missing stimuli and set their visibility and
            % durSec fields to 0. (Setting either to 0 would suffice but
            % doing both for clarity.) Prior to the introduction of this
            % function it was necessary to define all stimuli for all
            % conditions, even when the stimuli were not used in that
            % condition.
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
                    stimnamesPresent{end+1}=E.conditions{i}.stims{j}.name;
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
    end
    methods
        function set.outputFolder(E,value)
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