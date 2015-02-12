classdef lkDpxGratingExpAnalysis < hgsetget
    properties (Access=public)
        % name of todoListFile,
        % organized.
        todoListFileName;
        anaFunc;
        anaOpts;
        pause;
    end
    properties (GetAccess=private,SetAccess=private)
        % The file and corresponding neuron todo lists can be viewed by the
        % user, but can not be set directly, only through loading a
        % todoListFile.
        filesToDo;
        neuronsToDo;
    end
    methods (Access=public)
        function A=lkDpxGratingExpAnalysis(neurotodoFile)
            % lkDpxGratingExpAnalysis
            % Analysis class for lkDpxGratingExp
            %
            % PROPERTIES:
            % todoListFileName = the absolute path to a NeuroTodoFile.
            %    A NeuroTodoFile is a text-file that ends in
            %    "todo.txt" that should contain the filenames including
            %    absolute paths to the the merged LasAF and DPX datafiles
            %    as created using lkDpxGratingExpAddResponse. I've included
            %    an example todoListFile called 'example_todo.txt' that
            %    contains more comments that explain in more detail how the
            %    items in that file should be.
            % anaFunc = name of analysis. All analysis are programmed to
            %    run on a cell to cell basis. This class is basically a
            %    wrapper to call them on the set of cells selected in the
            %    NeuroTodoFile. The analysis function can be found in the
            %    private folder within the "@lkDpxGratingExpAnalysis" class
            %    folder. They come in two separate functions, for an anaFunc
            %    named XXX these would be calcXXX.m and plotXXX.m (the names
            %    should be self-explanatory). It's always a good idea to keep
            %    the calculations of your analysis and the visualization of
            %    your data as separate as possible. At the time of writing
            %    (2014-12-1) there's only one anaFunc
            %    "DirectionTuningCurve". We will make more as needed.
            % anaOpts = cell array of options that are passed to
            %    calcXXX.m if XXX is your anaFunc
            %    "calcDirectionTuningCurve" doesnt do anything with those
            %    (at the moment).
            % pause = when to plot and wait for key to continue. Can be
            %    either 'perCell', 'perFile', or 'never'. If 'never', no plots
            %    are shown.
            %
            % METHODS:
            % Once you have set the properties to your liking, run the
            % analysis by excecuting
            %    A.run
            % Tip: you can like always in matlab interupt the analysis
            %    by typing CTRL-C, followed optionally by cf to close the
            %    figures
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
            A.pause='perFile'; % 'perCell', 'perFile', 'never'
            A.todoListFileName=neurotodoFile; % note: this calls the function "set.todoListFileName"
            A.anaFunc='DirectionTuningCurve';
            A.anaOpts={};
        end
        function output=run(A)
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
        end
    end
    methods (Access=private)
        function str=calcCommandString(A)
            str=['calc' A.anaFunc]; % e.g. 'calcDirectionTuningCurve'
        end
        function str=plotCommandString(A)
            str=['plot' A.anaFunc]; % e.g. 'calcDirectionTuningCurve'
        end
        function output=runPerCell(A)
            for f=1:numel(A.filesToDo)
                dpxd=dpxdLoad(A.filesToDo{f}); % dpxd is now an DPX-Data structure
                nList=parseNeuronsToDoList(A.neuronsToDo{f},getNeuronNrs(dpxd));
                tel=0;
                for c=1:numel(nList)
                    tel=tel+1;
                    output{tel}=eval([A.calcCommandString '(dpxd,nList(c),A.anaOpts{:});']); %#ok<AGROW>
                    % add filename and cell numer
                    output{tel}.file{1}=A.filesToDo{f}; %#ok<AGROW>
                    output{tel}.cellNumber=nList(c); %#ok<AGROW>
                    if ~strcmpi(A.pause,'never')
                        figHandle=dpxFindFig([A.filesToDo{f} ' c' num2str(nList(c),'%.3d')]);
                        eval([A.plotCommandString '(output{tel});']);
                    end
                    if strcmpi(A.pause,'perCell')
                        dpxTileFigs;
                        [~,filestem]=fileparts(A.filesToDo{f});
                        disp(['Showing ' A.plotCommandString ' of cell ' num2str(nList(c)) ' (' num2str(c) '/' num2str(numel(nList)) ') in file ''' filestem ''' (' num2str(f) '/' num2str(numel(A.filesToDo))]);
                        input('<<Any key to continue>>');
                        close(figHandle);
                    end
                end
                if strcmpi(A.pause,'perFile')
                    dpxTileFigs;
                    [~,filestem]=fileparts(A.filesToDo{f});
                    disp(['Showing ' A.plotCommandString ' of all cells in file ''' filestem ''' (' num2str(f) '/' num2str(numel(A.filesToDo)) ').']);
                    input('<<Any key to continue>>');
                    close all;
                end
                % Merge all the outputs into a single DPXD
                output=dpxdMerge(output);
            end
            function output=runPerFile(A)
            end
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
                    calcs{end+1}=K(i).name(5:end-2);
                elseif strncmp(K(i).name,'plot',4)
                    plots{end+1}=K(i).name(5:end-2);
                end
            end
            hasCalc=any(strcmp(value,calcs));
            hasPlot=any(strcmp(value,plots));
            errstr='';
            if ~any(strcmp(value,calcs))
                errstr=['Illegal anaFunc option: ''' value ''', because: '];
                errstr=[errstr '\n   The file ''' dispAnaFuncFolder 'calc' value '.m'''' does not exist.'];
            end
            if ~any(strcmp(value,plots));
                if isempty(errstr)
                    errstr=['Illegal anaFunc option: ''' value ''', because: '];
                end
                errstr=[errstr '\n   The file ''' dispAnaFuncFolder 'plot' value '.m'''' does not exist.'];
            end
            if ~isempty(errstr)
                OK=intersect(calcs,plots);
                if numel(OK)>0
                    errstr=[errstr '\nValid options are:'];
                    for i=1:numel(OK)
                        errstr=[errstr '\n   ''' OK{i} '''']; %#ok<AGROW>
                    end
                end
                error('arbitrary:messageid',errstr);
            else
                A.anaFunc=value;
            end
        end
    end
end
