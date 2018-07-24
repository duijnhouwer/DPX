function varargout = dpxUIgetFiles(varargin)
    
    % dpxUIgetFiles
    %
    % GUI to select multiple files from multiple directories. It is possible to select
    % files from folder including subfolder, filter on extention, and use
    % simple inclusion and exclusion filtering on filenames.
    %
    % EXAMPLE:
    % dpxUIgetFiles('folder',pwd,'title','Select files...','extensions',{'*.txt','*.*'});
    
   % TODO: implement regexp filtering
        
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @dpxUIgetFiles_OpeningFcn, ...
        'gui_OutputFcn',  @dpxUIgetFiles_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
   % End initialization code - DO NOT EDIT
end


% --- Executes just before dpxUIgetFiles is made visible.
function dpxUIgetFiles_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to dpxUIgetFiles (see VARARGIN)
    
    % Choose default command line output for dpxUIgetFiles
    handles.output.filenames = {};
    %
    % Handle the vargin input
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParamValue('rootfolder',dpxCache('get',[mfilename '_workdir'],pwd),@ischar) % the start folder to look in
    p.addParamValue('title',mfilename,@ischar);
    p.addParamValue('extensions',{'*.mat','*.m'},@(x)iscell(x)||ischar(x)); % *.* will always be added
    p.parse(varargin{:});
    %
    %set(handles.traverseSubfolderCheckBox,'Value',dpxCache('get',[mfilename '_traverseSubfolderCheckBox'],false));
    set(handles.traverseSubfolderCheckBox,'Value',false); % always set false because can take forever in case rootfolder is deep
    %
    set(handles.extensionPopupmenu,'String',[cellstr(p.Results.extensions), '*.*']);
    set(handles.figure1,'Name',p.Results.title);
    set(handles.folderEditText,'String',p.Results.rootfolder);
        % in case the path is excluded from search and hidden (nice for
    % clarity) keep a shadow list for use when copying the files into the
    % output list (which always shows the paths)
    handles.shadowPathList={};
    handles = setInputList(hObject, handles); % 20180724 now returns handles so that shadowPathList is updated
    % Update handles structure
    guidata(hObject, handles);
    % Make the figure wait until resume() is called somewhere. At the time of writing this
    % is done in where the cancel button and the ok button are pressed. After resume the
    % program jumps to 'dpxUIgetFiles_OutputFcn'. This function is also reached upon
    % closing the window with the X in the top-right corner (identical to Cancel)
    uiwait(handles.figure1);
end

function dpxUIgetFiles_CloseRequestFcn(hObject, eventdata, handles) %#ok<*INUSD>
    uiresume();
end


function varargout = dpxUIgetFiles_OutputFcn(hObject, eventdata, handles)
    if isstruct(handles) && isfield(handles,'output')
        varargout{1}=handles.output.filenames;
        varargout{2}=handles.folderEditText.String;
        delete(hObject);
        drawnow;
    else
        % close-X in top-left corner must have been pressed
        varargout{1}={};
    end
end


function folderEditText_Callback(hObject, folder, handles)
    % Hints: get(hObject,'String') returns contents of folderEditText as text
    %        str2double(get(hObject,'String')) returns contents of folderEditText as a double
    if ischar(folder) % comes from select folder button
        set(hObject,'String',folder);
    else
        folder=get(hObject,'String');
    end
    if ~exist(folder,'file')
        msg=['Folder ''' folder ''' does not exist'];
        uiwait(errordlg(msg,mfilename,'modal'));
        return
    else
        guidata(hObject, handles);
        setInputList(hObject, handles);
    end
end


function browseFolderButton_Callback(hObject, eventdata, handles)
    folder=get(handles.folderEditText,'String');
    if exist(folder,'file')
        try
        folder=uigetdir(folder, 'Select a folder');
        catch me
            disp([me.message ': ' folder]);
             folder=uigetdir(pwd, 'Select a folder');
        end
    else
        folder=uigetdir(pwd, 'Select a folder');
    end
    if folder==0 % 0 if pressed cancel
        return;
    end
    %  folderEditText_Callback(hObject, folder, handles)
    set(handles.folderEditText,'String',folder);
    setInputList(hObject, handles);
end


function addToOutputButton_Callback(hObject, eventdata, handles) % >>
    
    allfiles=handles.inputListBox.String; % cell of strings
    if isempty(allfiles)
        return;
    end
    if ~handles.includePathCheckBox.Value
        allfiles=fullfile(handles.shadowPathList(:),allfiles(:));
    end
    selectedfiles=allfiles(handles.inputListBox.Value); % limit to selection
    if isempty(selectedfiles)
        return;
    end
    outputList=cellstr(handles.outputListBox.String); % current outputlist
    outputList=[selectedfiles(:); outputList(:)]; % add the selected files to the output list
    outputList=unique(outputList); % remove duplicates
    outputList=outputList(~cellfun(@isempty,outputList)); % remove empty strings
    handles.outputListBox.String=outputList;
    handles.outputListBox.Value=1:numel(outputList);
    updateOutputInfoText(hObject, eventdata, handles);                          
end


function removeFromOutput_Callback(hObject, eventdata, handles) % []<
    outputList=cellstr(get(handles.outputListBox,'String'));
    if numel(outputList)>0
        hilited=get(handles.outputListBox,'Value');
        outputList(hilited)=[];
        set(handles.outputListBox,'String',outputList);
        set(handles.outputListBox,'Value',1:max(1,numel(outputList)));
        updateOutputInfoText(hObject, eventdata, handles);
    end
end


% --- Executes on button press in traverseSubfolderCheckBox.
function traverseSubfolderCheckBox_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of traverseSubfolderCheckBox
    setInputList(hObject, handles);
end

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
    uiresume();
end

% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
    % Store the selected folder as the starting folder for next time
    dpxCache('set',[mfilename '_workdir'],get(handles.folderEditText,'String'));
    dpxCache('set',[mfilename '_traverseSubfolderCheckBox'],get(handles.traverseSubfolderCheckBox,'Value'));
    handles.output.filenames=cellstr(get(handles.outputListBox,'String'));
    if numel(handles.output.filenames)==1 && strcmp(handles.output.filenames,'')
        % OK must have been pressed on an empty selection. Make output identical to
        % output obtained with cancel or "close-window cross".
        handles.output.filenames={}; % instead of {''}
    end
    guidata(hObject, handles);
    uiresume();
end

function updateOutputInfoText(hObject, eventdata, handles)
    outputList=cellstr(get(handles.outputListBox,'String'));
    [folderStrs]=cellfun(@fileparts,outputList,'UniformOutput',false);
    nFiles=numel(folderStrs);
    nFolders=numel(unique(folderStrs));
    info=['Press OK to select ' num2str(nFiles) ' file' popS(nFiles) ' from ' num2str(nFolders) ' folder' popS(nFolders)];
    set(handles.outputInfoText,'String',info);
    function s=popS(n)
        if n==1
            s='';
        else
            s='s';
        end
    end
end



%--- This function populates the current selection listbox
function handles=setInputList(hObject, handles)
    if ~exist(handles.folderEditText.String,'file')
        handles.folderEditText.String=uigetdir(pwd,'Pick a folder ...');   
    end
    oldPointer=get(gcf,'Pointer');
    set(gcf,'Pointer','watch'); drawnow;
    if get(handles.traverseSubfolderCheckBox,'Value')
        folders=dpxGetFolders(handles.folderEditText.String,'recursive','includeroot');
    else
        folders={handles.folderEditText.String};
    end
    fileNames={};
    handles.shadowPathList={};
    ext=get(handles.extensionPopupmenu,'String');
    if iscell(ext)
        ext=ext{get(handles.extensionPopupmenu,'Value')}; % e.g. '*.mat'
    end
    exclStrCell=regexp(get(handles.excludeStringEdit,'String'),':','split'); % ':' is fine because it's an illegal character in filenames (at least in windows)
    inclStrCell=regexp(get(handles.includeStringEdit,'String'),':','split');
    exclStrCell(cellfun(@isempty,exclStrCell))=[]; % remove '' from cell array that would...
    inclStrCell(cellfun(@isempty,inclStrCell))=[]; % ... typically occur when field is empty
    I=intersect(exclStrCell,inclStrCell);
    if ~isempty(I)
        set(gcf,'Pointer','arrow'); drawnow;
        msg={'Require string(s) and Exclude string(s) both contain:', sprintf('      %s\n',I{:})};
        uiwait(errordlg(msg,mfilename,'modal'));
        return
    else
        nTotalFiles=0; % nr of files included hidden-by-filtering ones
        for i=1:numel(folders)
            stringsToAddCell = dir(fullfile(folders{i},ext));
            for a=1:numel(stringsToAddCell)
                if stringsToAddCell(a).isdir
                    continue;
                else
                    if handles.includePathCheckBox.Value
                        thisFileName=fullfile(folders{i},stringsToAddCell(a).name);
                    else
                        thisFileName=stringsToAddCell(a).name;
                    end
                    nTotalFiles=nTotalFiles+1;
                    if ~isempty(exclStrCell) && contains(thisFileName,exclStrCell)
                        continue;
                    end
                    if ~isempty(inclStrCell) && ~contains(thisFileName,inclStrCell)
                        continue;
                    end
                    fileNames{end+1}=thisFileName; %#ok<AGROW>
                    handles.shadowPathList{end+1}=folders{i};
                end
            end
        end
        % change high-lighted selection to prevent Warning: Multiple-selection 'listbox' control requires that 'Value' be an integer within String range
        set(handles.inputListBox,'Value',max(1,numel(fileNames)))
        set(handles.inputListBox,'String',fileNames);
    end
    set(gcf,'Pointer',oldPointer);
    guidata(hObject, handles); % to update (at least) handles.shadowPathList
    %
    % update the inputInfoText field
    EXT=upper(ext(3:end)); % remove *. 
    handles.inputInfoText.String=sprintf('Showing %d %s-file%s in %d folder%s (%d filtered out)',numel(fileNames),EXT,pops(numel(fileNames)),numel(folders),pops(numel(folders)),nTotalFiles-numel(fileNames));
    function s=pops(n)
        s='s'; if n==1, s=''; end
    end
end


function includeStringEdit_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of includeStringEdit as text
    %        str2double(get(hObject,'String')) returns contents of includeStringEdit as a double
    setInputList(hObject, handles);
end

function excludeStringEdit_Callback(hObject, eventdata, handles)
    setInputList(hObject, handles);
end


% --- Executes on button press in includePathCheckBox.
function includePathCheckBox_Callback(hObject, eventdata, handles)
    setInputList(hObject, handles);
end


% --- Executes on selection change in extensionPopupmenu.
function extensionPopupmenu_Callback(hObject, eventdata, handles)
    setInputList(hObject, handles);
end
