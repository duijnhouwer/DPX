classdef (CaseInsensitiveProperties=true ...
        ,Description='a' ...
        ,DetailedDescription='ab') ...
        dpxCoreExperiment < hgsetget
    
    properties (Access=public)
        expName;
        physScr;
        nRepeats;
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
            E.sysInfo=dpxSystemInfo;
            E.createFileName;
            E.signalFile('save');
            E.physScr.open;
            E.showStartScreen;
            tr=0;
            for r=1:E.nRepeats
                condList=randperm(numel(E.conditions));
                for c=1:numel(condList)
                    tr=tr+1;
                    if E.txtPauseNrTrials>0 && mod(tr,E.txtPauseNrTrials)==0 && tr<E.nRepeats*numel(condList) 
                        E.showSaveScreen;
                        E.save;
                        E.showPauseScreen;
                    end
                    condNr=condList(c);
                    E.physScr.clear;
                    E.conditions{condNr}.init(get(E.physScr));
                    [esc,timing,resp]=E.conditions{condNr}.show;
                    if esc
                        break;
                    end
                    E.trials(tr).condition=condNr;
                    E.trials(tr).startSec=timing.startSec;
                    E.trials(tr).stopSec=timing.stopSec;
                    E.trials(tr).resp=resp;
                end
                if esc
                    fprintf('\nEscape pressed during show\n');
                    break;
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
                    % this is why unique stimuli names are required
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
                str=['Waiting for ' E.txtEnd ];
                dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',0,'resetCounter',false,'maxWaitSeconds',Inf);
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
                str=['Waiting for ' E.txtEnd ' (max ' num2str(maxWaitSec) ' seconds'];
                dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA,'forceAfterSec',0,'fadeOutSec',-1);
                seconds=dpxBlockUntilDaqPulseDetected('delaySeconds',0,'resetCounter',false,'maxWaitSeconds',60);
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
            % handy when using shared dropbox folder, indicates that someone is
            % running the experiment and on which computer.
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
    end
    methods
        function set.outputFolder(E,value)
            if ~ischar(value)
                error('outputFolder should be a string');
            end
            E.outputFolder=value;
        end
    end
end