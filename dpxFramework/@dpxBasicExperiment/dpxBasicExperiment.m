classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxBasicExperiment < hgsetget 
    
    properties (Access=public)
        physScr;
        nRepeats=10;
        conditions=[];
        txtStart='Press and release a key to start';
        txtPause='I N T E R M I S S I O N\n\nPress and release a key to start';
        txtPauseNrTrials=5;
    end
    properties (Access=protected)
        trials=struct('condition',[],'respNum',[],'respSecs',[],'startSecs',[],'stopSecs',[]);
    end
    methods (Access=public)
        function E=dpxBasicExperiment
            E.physScr=dpxStimWindow;
            E.conditions=dpxBasicCondition;
            E.nRepeats=10;
            E.txtStart='Press and release a key to start';
            E.txtPause='I N T E R M I S S I O N\n\nPress and release a key to start';
            E.txtPauseNrTrials=20;
        end
        function run(E)
            E.physScr.open;
            conditionList=mod(randperm(E.nRepeats*numel(E.conditions)),numel(E.conditions))+1;
            for tr=1:numel(conditionList)
                if tr==1
                    showStartScreen;
                elseif mod(tr,E.txtPauseNrTrials)==0
                    %dpxSaveExperiment(E,'intermediate');
                    showPauseScreen;
                end
                condNr=conditionList(tr);
                E.physScr.clear;
                [esc]=E.conditions(condNr).init(get(E.physScr));
                if esc
                    fprintf('\nEscape pressed during init\n');
                    break; % stop the experiment
                end
                [esc]=E.conditions(condNr).show;
                if esc
                    fprintf('\nEscape pressed during show\n');
                    break; % stop the experiment
                end
                E.trials(tr).condition=condNr;
                %E.trials(tr).respNum=resp.number;
                %E.trials(tr).respSecs=resp.timeSecs;
                %E.trials(tr).startSecs=timing.startSecs;
                %E.trials(tr).stopSecs=timing.stopSecs;
            end
            E.physScr.close;
        end
        function addCondition(E,C,CnameStr)
            if nargin==2
                CnameStr=C.type;
            end
            E.conditions{end+1}=C;
            E.conditionNames{end+1}=CnameStr;
        end
        function fullScreen(E)
             E.physScr.winRectPx=[];
        end
        function windowed(E,win)
            if nargin==1
                win=[10 20 500 375];
            end
             E.physScr.winRectPx=win;
        end
    end
    methods (Access=private)
        function showStartScreen(E)
            dpxDisplayText(E.physScr.windowPtr,E.txtStart,'rgbaback',E.physScr.backRGBA*E.physScr.whiteIdx);
        end
        function showPauseScreen(E)
            dpxDisplayText(E.physScr.windowPtr,E.txtPause,'rgbaback',E.physScr.backRGBA*E.physScr.whiteIdx);
        end
    end
end