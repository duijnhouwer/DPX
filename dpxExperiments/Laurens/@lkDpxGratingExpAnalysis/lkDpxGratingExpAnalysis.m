classdef lkDpxGratingExpAnalysis < hgsetget
    properties (Access=public)
        % name of todoListFile, This should be a text-file that ends in
        % todo.txt that should contain the filenames including absolute
        % paths to the the merged LasAF and DPX datafiles as created using
        % lkDpxGratingExpAddResponse. I've included an example todoListFile
        % called 'example_todo.txt' that contains more comments that
        % explain in more detail how the items in that file should be
        % organized.
        todoListFileName;
        analFunc;
        analOptions;
        pause;
        showPlots;
    end
    properties (GetAccess=public,SetAccess=private)
        % The file and corresponding neuron todo lists can be viewed by the
        % user, but can not be set directly, only through loading a
        % todoListFile.
        filesToDo;
        neuronsToDo;
    end
    methods (Access=public)
        function A=lkDpxGratingExpAnalysis(todoFile)
            % This function gets called whenever the lkDpxGratingExpAnalysis is
            % executed in the command window or in a function or script.
            % We use it now to set default values for the public and
            % private properties of this analysis
            if nargin==0
                todoFile='';
            end
            A.pause='perCell'; % 'perCell', 'perFile', 'never'
            A.todoListFileName=todoFile; % note: this calls the function "set.todoListFileName"
            A.analFunc='DirectionTuningCurve';
            A.analOptions={};
            A.showPlots=true;
        end
        function output=run(A)
            if isempty(A.todoListFileName)
                dpxDispFancy('The string "todoListFileName" is empty, no data files to run analyses on.');
                return;
            elseif numel(A.filesToDo)==0
                dpxDispFancy('A todo-list was loaded, but appears to contain no data files to run analyses on.');
                return
            end
            for f=1:numel(A.filesToDo)
                dpxd=dpxdLoad(A.filesToDo{f}); % dpxd is now an DPX-Data structure
                nList=parseNeuronsToDoList(A.neuronsToDo{f},getNeuronNrs(dpxd));
                calcCommandString=['calc' A.analFunc]; % e.g. 'calcDirectionTuningCurve'
                plotCommandString=['plot' A.analFunc]; % e.g. 'plotDirectionTuningCurve'
                tel=0;
                for c=1:numel(nList)
                    tel=tel+1;
                    output{tel}=eval([calcCommandString '(dpxd,nList(c),A.analOptions{:});']); %#ok<AGROW>
                    eval([plotCommandString '(output{tel});']);
                    dpxTilefigs;
                    if strcmpi(A.pause,'perCell')
                        input('<< any key to continue>>');
                        close all;
                    end
                end
                if strcmpi(A.pause,'perFile')
                    input('<< any key to continue>>');
                    close all;
                end
            end
        end         
    end
    methods % set and get functions
        function set.todoListFileName(A,value)
            if isempty(value)
                [filename,pathname]=uigetfile({'*todo.txt'},'Select a todo-list file ...');
                if ~ischar(filename) && filename==0
                    dpxDispFancy('User canceled selecting todo-list file.');
                    A.todoListFileName='';
                    return;
                end
                value=fullfile(pathname,filename);
            end
            if ~exist(value,'file')
                error(['No such file: ''' value '''']);
            end
            A.todoListFileName=value;
            [A.filesToDo,A.neuronsToDo]=loadTodoList(A.todoListFileName); %#ok<MCSUP>
        end
        function set.pause(A,value)
            try
                options={'perCell','perFile','never'};
                if ~any(strcmpi(value,options))
                   error; % skip to catch block
                end
                A.pause=value;
            catch me
                error(['pause should be one of: ' dpxCellOptionsToStr(options) '.']);
            end
        end
        function set.showPlots(A,value)
            if value~=0 && value~=1
                error('showPlots must be true or false or 1 or 0');
            end
            A.showPlots=value;
        end
    end
end
