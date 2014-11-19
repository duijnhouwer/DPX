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
        analFunction;
        oneAtATime;
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
            A.oneAtATime=true;
            A.todoListFileName=todoFile;
            A.analFunction='DirectionTuningCurve';
        end
        function run(A)
            for f=1:numel(A.filesToDo)
                load(A.filesToDo{f}); % load 'data' into  memory
                nList=parseNeuronsToDoList(A.neuronsToDo{f},data.N);
                calcCommandString=['calc' A.analFunction]; % e.g. 'calcDirectionTuningCurve'
                plotCommandString=['plot' A.analFunction]; % e.g. 'plotDirectionTuningCurve'
                for c=1:numel(nList)
                    KALK=eval([calcCommandString '(data,nList(c));']);
                    eval([plotCommandString '(KALK);']);
                end
            end
        end         
    end
    methods % set and get functions
        function set.todoListFileName(A,value)
            if isempty(value)
                [filename,pathname]=uigetfile({'*todo.txt'},'Select a todo-list file ...');
                value=fullfile(pathname,filename);
            end
            if ~exist(value,'file')
                error(['No such file: ''' value '''']);
            end
            A.todoListFileName=value;
            [A.filesToDo,A.neuronsToDo]=loadTodoList(A.todoListFileName); %#ok<MCSUP>
        end
    end
end
