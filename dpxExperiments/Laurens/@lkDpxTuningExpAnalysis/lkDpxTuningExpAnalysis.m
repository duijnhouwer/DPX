classdef lkDpxTuningExpAnalysis < hgsetget
    properties (Access=public)
        % name of todoListFile,
        % organized.
        todoListFileName;
        anaFunc;
        anaOpts;
        doPlot;
        outputFolder;
    end
    properties (Access=protected)
        filesToDo;
        neuronsToDo;
    end
    methods (Access=public)
        function A=lkDpxTuningExpAnalysis(neurotodoFile)
            % lkDpxTuningExpAnalysis
            % Analysis class for lkDpxTuningExp
            %
            % PROPERTIES:
            %  todoListFileName = the absolute path to a NeuroTodoFile.
            %    A NeuroTodoFile is a text-file that ends in
            %    "todo.txt" that should contain the filenames including
            %    absolute paths to the the merged LasAF and DPX datafiles
            %    as created using lkDpxTuningExpAddResponse. You can
            %    create a NeuroTodoFile using 'createNeuroTodoFile' (see
            %    METHODS).
            %  anaFunc = name of analysis. All analysis are programmed to
            %    run on a cell to cell basis. This class is basically a
            %    wrapper to call them on the set of cells selected in the
            %    NeuroTodoFile. The analysis function can be found in the
            %    private folder within the "@lkDpxTuningExpAnalysis" class
            %    folder. They come in two separate functions, for an anaFunc
            %    named XXX these would be calcXXX.m and plotXXX.m (the names
            %    should be self-explanatory). It's always a good idea to keep
            %    the calculations of your analysis and the visualization of
            %    your data as separate as possible. At the time of writing
            %    (2014-12-1) there's only one anaFunc
            %    "DirectionTuningCurve". We will make more as needed.
            %  anaOpts = cell array of options that are passed to
            %    calcXXX.m if XXX is your anaFunc
            %    "calcDirectionTuningCurve" doesnt do anything with those
            %    (at the moment).
            %  doPlot = show plots or not [true] | false
            %
            % METHODS:
            %  run =
            %    Once you have set the properties to your liking, run the
            %    analysis by excecuting
            %       A=lkDpxTuningExpAnalysis('X:\YourNeuroTodo.txt');
            %       A.run
            %    Tip: you can at any time interupt the analysis with CTRL-C,
            %    followed optionally by 'cf' to close the figures.
            %  createNeuroTodoFile =
            %    Brings up a file selection dialog that you can use to make
            %    a NeuroTodoFile and save it afterward. This is a text-file
            %    that will include additional instruction (how to select
            %    cells and exclude files etc.)
            %
            %
            % OUTPUT:
            % A dpxd struct with N being the number of cells. The format of
            % this struct will depend on the calcXXX.m function that was
            % used, but N will always be the number of cells analysed. So
            % for "DirectionTuningCurve" this will contain, among other
            % things, a DirectionTuningCurve for each cell.
            %
            
            if nargin==0
                neurotodoFile='';
            end
            A.doPlot=true;
            A.todoListFileName=neurotodoFile; % note: this calls the function "set.todoListFileName"
            A.anaFunc='DirectionTuningCurve';
            A.anaOpts={};
            A.outputFolder='<<auto>>';
        end
        function createNeuroTodoFile(A)
            files=dpxUIgetFiles;
            if isempty(files)
                return;
            end
            [filename,pathname]=uiputfile({'*todo.txt','NeuroTodoFile (*todo.txt)'; '*.*','All Files (*.*)'},'Save NeuroTodoFile as ...', 'NeuroTodo.txt');
            if isnumeric(filename)
                return;
            end
            outputFileName=fullfile(pathname,filename);
            fid=fopen(outputFileName,'wt');
            if fid==-1
                error(['Could not open ''' outputFileName ''' for saving.']);
            end
            fprintf(fid,'%s\n','% Neuro-selection list example file, to be used with lkDpxTuningExpAnalysis');
            fprintf(fid,'%s\n','%');
            fprintf(fid,'%s\n','% Selection of files to analyze followed by a line with cell numbers to analyze.');
            fprintf(fid,'%s\n','% The list of numbers should be either a single zero, or all negative numbers, or all positive');
            fprintf(fid,'%s\n','% Example cell number lists : with interpretation ....');
            fprintf(fid,'%s\n','% 0 :  analyze all cells, ');
            fprintf(fid,'%s\n','% -1 -10 -12 : analyze all except 1 10 12,');
            fprintf(fid,'%s\n','% 1 14 : analyze cell 1 and 14');
            fprintf(fid,'%s\n','%');
            fprintf(fid,'%s\n','% Empty lines (or containing nothing but whitespace) and lines starting with ''%'' will be ignored');
            fprintf(fid,'%s\n','% Use ''%'' to make comments like this');
            fprintf(fid,'%s\n\n',['% Created using ' mfilename '.createNeuroTodoFile on ' datestr(now) ]);
            for i=1:numel(files)
                fprintf(fid,'%s\n0\n',files{i});
            end
            fclose(fid);
            A.todoListFileName=outputFileName;
        end
        function output=run(A)
            % Reload the files and cells per file, file may have been
            % edited since it was loaded first.
            [A.filesToDo,A.neuronsToDo]=loadTodoList(A.todoListFileName);
            %
            if isempty(A.todoListFileName)
                dpxDispFancy('The string "todoListFileName" is empty, no data files to run analyses on.');
                return;
            elseif numel(A.filesToDo)==0
                dpxDispFancy('A todo-list was loaded, but appears to contain no data files to run analyses on.');
                return
            end
            infoRequest=[A.calcCommandString '(''info'')']; % e.g. 'calcDirectionTuningCurve('info')'
            I=eval(infoRequest);
            if strcmpi(I.per,'cell')
                output=A.runPerCell();
            elseif strcmpi(I.per,'file')
                output=A.runPerFile();
            else
                error([infoRequest ' returned an invalid ''per'' option: ''' I.per ''' (should be ''cell'' or ''file'').']);
            end
            if ~isempty(A.outputFolder)
                if strcmpi(strtrim(A.outputFolder),'<<auto>>')
                    outputName=fullfile(fileparts(A.todoListFileName),[mfilename '_output.mat']);
                end
                try
                    save(outputName,'output');
                catch me
                    warning(['Could not save ''' outputName ''':']);
                    warning(me.message);
                end    
            end
        end
    end
    methods (Access=protected)
        function str=calcCommandString(A)
            str=['calc' A.anaFunc]; % e.g. 'calcDirectionTuningCurve'
        end
        function str=plotCommandString(A)
            str=['plot' A.anaFunc]; % e.g. 'calcDirectionTuningCurve'
        end
        function output=runPerCell(A)
            celTel=0;
            for f=1:numel(A.filesToDo)
                fprintf('Working on file %d of %d (%s) ...\n',f,numel(A.filesToDo),A.filesToDo{f});
                dpxd=dpxdLoad(A.filesToDo{f}); % dpxd is now an DPX-Data structure
                cellNumList=parseNeuronsToDoList(A.neuronsToDo{f},getNeuronNrs(dpxd)); % cell number list
                for c=1:numel(cellNumList)
                    celTel=celTel+1;
                    cmd=[A.calcCommandString '(dpxd,cellNumList(c),A.anaOpts{:});']; % e.g. calcDirectionTuningCurveSfTfContrast(dpxd,cellNumList(c),A.anaOpts{:});
                    output{celTel}=eval(cmd); %#ok<AGROW>
                    % add filename and cell number to each subset (nr 1 is all data, the
                    % optional next ones are the individual sessions that were merged)
                    for ss=1:numel(output{celTel})
                        output{celTel}{ss}.file=cellstr(repmat(A.filesToDo{f},output{celTel}{ss}.N,1))';
                        output{celTel}{ss}.cellNumber=repmat(cellNumList(c),1,output{celTel}{ss}.N);
                        output{celTel}{ss}.fileCellId=repmat(f+1i*cellNumList(c),1,output{celTel}{ss}.N);
                    end
                    if A.doPlot
                        [pad,filen]=fileparts(A.filesToDo{f});
                        figName=[fullfile(pad,filen) '_c' num2str(cellNumList(c),'%.3d')];
                        figHandle=dpxFindFig(figName);
                        cmd=[A.plotCommandString '(output{celTel},A.anaOpts{:});'];
                        eval(cmd);
                        drawnow;
                        if ~isempty(A.outputFolder)
                            try
                                print(figHandle,figName,'-dpng'); % save the figure to file
                            catch me
                                warning(['Could not print ''' figName ''':']);
                                warning(me.message);
                            end
                            
                        end
                        close(figHandle);
                    end
                    % Now that the plotting of the complete and the
                    % sub-sets has been done, only maintain the complete
                    output{celTel}=output{celTel}{1}; %#ok<AGROW>
                end
            end
            % Merge all the outputs into a single DPXD
            output=dpxdMerge(output);
        end
        function output=runPerFile(A) %#ok<STOUT,MANU>
            error('not implemented yet')
        end
    end
    methods % set and get functions
        function set.todoListFileName(A,value)
            if isempty(value)
                [filename,pathname]=uigetfile({'*todo.txt'},'Select a NeuroTodoFile ...');
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
        function set.doPlot(A,value)
            if ~islogical(value)
                error('doPlot should be true or false');
            else
                A.doPlot=value;
            end
        end
        function set.anaFunc(A,value)
            anaFuncFolder=[fileparts(mfilename('fullpath')) filesep 'private' filesep];
            calcs={};
            plots={};
            K=dir(anaFuncFolder);
            dispAnaFuncFolder=anaFuncFolder;
            dispAnaFuncFolder(dispAnaFuncFolder=='\')='/';
            for i=1:numel(K)
                if numel(K(i).name)<4+1+2 % calc + at least one letter + .m
                    continue;
                elseif strncmp(K(i).name,'calc',4)
                    calcs{end+1}=K(i).name(5:end-2); %#ok<AGROW>
                elseif strncmp(K(i).name,'plot',4)
                    plots{end+1}=K(i).name(5:end-2); %#ok<AGROW>
                end
            end
            % Check that the calc and plot functions are defined
            errstr='';
            if ~any(strcmp(value,calcs)) && ~isempty(value)
                errstr=['Illegal anaFunc option: ''' value ''', because: '];
                errstr=[errstr '\n   The file ''' dispAnaFuncFolder 'calc' value '.m'''' does not exist.'];
            end
            if ~any(strcmp(value,plots)) && ~isempty(value)
                if isempty(errstr)
                    errstr=['Illegal anaFunc option: ''' value ''', because: '];
                end
                errstr=[errstr '\n   The file ''' dispAnaFuncFolder 'plot' value '.m'''' does not exist.'];
            end
            if ~isempty(errstr) || isempty(value)
                OK=intersect(calcs,plots);
                if numel(OK)>0
                    errstr=[errstr '\nValid options are:'];
                    for i=1:numel(OK)
                        errstr=[errstr '\n   ' num2str(i)  ' ''' OK{i} '''']; %#ok<AGROW>
                    end
                end
                while true
                    fprintf(errstr);
                    fprintf('\n');
                    N=str2double(input('Pick a method >> ','s'));
                    if any(N==1:numel(OK))
                        A.anaFunc=calcs{N};
                        break;
                    end
                end
            else
                A.anaFunc=value;
            end
        end
    end
end
