classdef dpxCoreExperiment < hgsetget
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
    end
    properties (Access=protected)
        outputFullFileName='./undefined.mat';
    end
    properties (SetAccess=public,GetAccess=protected)
        outputFolder;
    end
    properties (GetAccess=public,SetAccess=protected)
        subjectId;
        experimenterId;
        startTime;
        stopTime;
        trials=struct('condition',[],'startSec',[],'stopSec',[],'resp',[]);
    end
    methods (Access=public)
        function E=dpxCoreExperiment
            E.physScr=dpxCoreWindow;
            E.conditions={};
            E.nRepeats=2;
            E.expName='dpxCoreExperiment';
            E.subjectId='0';
            E.txtStart='Press and release a key to start';
            E.txtPause='I N T E R M I S S I O N\n\nPress and release a key to start';
            E.txtPauseNrTrials=100;
            E.txtEnd='[-: The End :-]';
            E.txtRBGAfrac=[1 1 1 1];
            if ispc, E.outputFolder='C:\temp\dpxData';
            elseif isosx || islinux, E.outputFolder='/tmp/dpxData';
            end
        end
        function run(E)
            % This is the last function to call in your experiment script,
            % it starts the experiment and saves it when finished.
            E.startTime=now;
            E.createFileName;
            E.physScr.open;
            conditionList=mod(randperm(E.nRepeats*numel(E.conditions)),numel(E.conditions))+1;
            E.showStartScreen;
            for tr=1:numel(conditionList)
                if mod(tr,E.txtPauseNrTrials)==0
                    E.save;
                    E.showPauseScreen;
                end
                condNr=conditionList(tr);
                E.physScr.clear;
                E.conditions{condNr}.init(get(E.physScr));
                [esc,timing,resp]=E.conditions{condNr}.show;
                if esc
                    fprintf('\nEscape pressed during show\n');
                    break;
                end
                E.trials(tr).condition=condNr;
                E.trials(tr).startSec=timing.startSec;
                E.trials(tr).stopSec=timing.stopSec;
                E.trials(tr).resp=resp;
            end
            E.stopTime=now;
            E.save;
            E.showEndScreen;
            E.physScr.close;
        end
        function addCondition(E,C)
            E.conditions{end+1}=C;
        end
        function windowed(E,win)
            if nargin==1
                error('windowed needs a logical or a 4-element win rect');
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
            N=numel(E.trials);
            data=cell(1,N);
            for t=1:N
                D.exp=get(E);
                D.exp=rmfield(D.exp,{'physScr','conditions','outputFullFileName','outputFolder','trials'});
                D.stimwin=dpxGetSetables(E.physScr);
                D.trial=E.trials(t);
                condNr=D.trial.condition;
                for s=1:numel(E.conditions{condNr}.stims)
                    stimname=E.conditions{condNr}.stims{s}.name;
                    % this is why unique stimuli names are required
                    D.(stimname)=dpxGetSetables(E.conditions{condNr}.stims{s});
                end
                D=dpxFlattenStruct(D);
                D=dpxStructMakeSingleValued(D);
                D.N=1;
                data{t}=D;
            end
            data=dpxTblMerge(data); %#ok<NASGU>
            save(E.outputFullFileName,'data');
            disp(['Data has been saved to: ''' E.outputFullFileName '''']);
        end
        function showStartScreen(E)
            str=[E.txtStart];
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA);
        end
        function showPauseScreen(E)
            str=E.txtPause;
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA);
        end
        function showEndScreen(E)
            str=[E.txtEnd '\n\nData has been saved to:\n' E.outputFullFileName];
            dpxDisplayText(E.physScr.windowPtr,str,'rgba',E.txtRBGAfrac,'rgbaback',E.physScr.backRGBA);
        end
        function createFileName(E)
            E.subjectId=strtrim(upper(input('Subject ID > ','s')));
            if isempty(E.subjectId), E.subjectId='0'; end
            E.experimenterId=strtrim(upper(input('Experimenter ID > ','s')));
            if isempty(E.experimenterId), E.experimenterId=E.subjectId; end
            E.outputFullFileName=fullfile(E.outputFolder,[E.expName '-' E.subjectId '-' datestr(now,'yyyymmddHHMMSS') '.mat']);
            if exist(E.outputFullFileName,'file')
                error(['A file with name ' E.outputFullFileName ' already exists.']); %shouyld be extremely rare/impossible because of datastr
            end
            try % test saving to the file before running the experiment
                save(E.outputFullFileName);
            catch me
                error([me.message ' : ' E.outputFullFileName]);
            end
            delete(E.outputFullFileName);
        end
    end
    methods
        function set.outputFolder(E,value)
            if ~ischar(value)
                error('outputFolder should be a string');
            end
            if ~exist(value,'file')
                try
                    mkdir(value);
                catch me
                    error([me.message ' : ' value]);
                end
            end
            E.outputFolder=value;
        end
    end
end