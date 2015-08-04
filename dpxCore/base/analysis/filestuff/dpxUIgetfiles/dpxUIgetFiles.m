function varargout = dpxUIgetFiles(varargin)
    
    % dpxUIgetFiles
    %
    % GUI to select multiple files from multiple directories. It is possible to select
    % files from folder including subfolder, filter on extention, and use simplified and
    % full blown regexp filtering on filenames.
    %
    % TODO: implement regexp filtering
    %
    % EXAMPLE:
    % dpxUIgetFiles('folder',pwd,'title','Select files...','extensions',{'*.txt','*.*'});
    
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
function dpxUIgetFiles_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to dpxUIgetFiles (see VARARGIN)
    
    % Choose default command line output for dpxUIgetFiles
    handles.output = {};
    %
    % Handle the vargin input
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParamValue('folder',pwd,@ischar) % the start folder to look in
    p.addParamValue('title',mfilename,@ischar);
    p.addParamValue('extensions',{'*.*','*.mat','*.m'},@(x)iscell(x)||ischar(x));
    p.parse(varargin{:});
    %
    set(handles.extensionPopupmenu,'String',p.Results.extensions);
    set(handles.figure1,'Name',p.Results.title);
    set(handles.folderEditText,'String',p.Results.folder);
    setInputList(hObject, handles);
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
        varargout{1}=handles.output;
        delete(handles.figure1);
        delete(hObject);
    else
        % close-X in top-left corner must have been pressed
        varargout{1}={};
    end
end


function folderEditText_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of folderEditText as text
    %        str2double(get(hObject,'String')) returns contents of folderEditText as a double
    folder=get(hObject,'String');
    if ~exist(folder,'file')
        errordlg(['Folder ' folder ' does not exist']);
    else
        setInputList(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function folderEditText_CreateFcn(hObject, eventdata, handles)
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function browseFolderButton_Callback(hObject, eventdata, handles)
    folder=get(handles.folderEditText,'String');
    folder=uigetdir(folder, 'Select a folder');
    if folder~=0
        set(handles.folderEditText,'String',folder);
        setInputList(hObject, handles);
    end
end

function inputListBox_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns inputListBox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from inputListBox
end

function inputListBox_CreateFcn(hObject, eventdata, handles)
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function extensionPopupmenu_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns extensionPopupmenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from extensionPopupmenu
    setInputList(hObject, handles);
end

function extensionPopupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to extensionPopupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in outputListBox.
function outputListBox_Callback(hObject, eventdata, handles)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns outputListBox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from outputListBox
end

function outputListBox_CreateFcn(hObject, eventdata, handles)
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function addToOutputButton_Callback(hObject, eventdata, handles) % >>
    additional=cellstr(get(handles.inputListBox,'String')); % returns complete list in currentSelectionListBox
    hilited=get(handles.inputListBox,'Value');
    additional={additional{hilited}}; % limit to selection
    outputList=cellstr(get(handles.outputListBox,'String'));
    outputList=[additional(:); outputList(:)];
    outputList=unique(outputList); % remove duplicates
    outputList=outputList(~cellfun(@isempty,outputList)); % remove empty strings
    set(handles.outputListBox,'String',outputList);
    set(handles.outputListBox,'Value',1:numel(outputList));
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


% --- Executes on button press in selectAllButton.
function selectAllButton_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in selectNoneButton.
function selectNoneButton_Callback(hObject, eventdata, handles)
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
    handles.output=cellstr(get(handles.outputListBox,'String'));
    guidata(hObject, handles)
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
function setInputList(hObject, handles)
    startfolder=get(handles.folderEditText,'String');
    oldPointer=get(gcf,'Pointer');
    set(gcf,'Pointer','watch'); drawnow;
    if get(handles.traverseSubfolderCheckBox,'Value')
        folders=dpxGetFolders(startfolder,'walktree');
    else
        folders={startfolder};
    end
    fileNames={};
    ext=get(handles.extensionPopupmenu,'String');
    if iscell(ext)
        ext=ext{get(handles.extensionPopupmenu,'Value')}; % e.g. '*.mat'
    end
    exclStrCell=regexp(get(handles.excludeStringEdit,'String'),':','split');
    inclStrCell=regexp(get(handles.includeStringEdit,'String'),':','split');
    exclStrCell(cellfun(@isempty,exclStrCell))=[]; % remove '' from cell array that would...
    inclStrCell(cellfun(@isempty,inclStrCell))=[]; % ... typically occur when field is empty
    I=intersect(exclStrCell,inclStrCell);
    if ~isempty(I)
        set(gcf,'Pointer','arrow'); drawnow;
        errordlg({'Require string(s) and Exclude string(s) both contain:', sprintf('      %s\n',I{:})});
    else
        for i=1:numel(folders)
            stringsToAddCell = dir(fullfile(folders{i},ext));
            for a=1:numel(stringsToAddCell)
                if stringsToAddCell(a).isdir
                    continue;
                else
                    thisFileName=fullfile(folders{i},stringsToAddCell(a).name);
                    if ~isempty(exclStrCell) && dpxStrfindCell(thisFileName,exclStrCell,true)
                        continue;
                    end
                    if ~isempty(inclStrCell) && ~dpxStrfindCell(thisFileName,inclStrCell,true)
                        continue;
                    end
                    fileNames{end+1}=thisFileName; %#ok<AGROW>
                end
            end
        end
        % change high-lighted selection to prevent Warning: Multiple-selection 'listbox' control requires that 'Value' be an integer within String range
        set(handles.inputListBox,'Value',max(1,numel(fileNames)))
        set(handles.inputListBox,'String',fileNames);
    end
    set(gcf,'Pointer',oldPointer);
end





function includeStringEdit_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of includeStringEdit as text
    %        str2double(get(hObject,'String')) returns contents of includeStringEdit as a double
    setInputList(hObject, handles);
end

function includeStringEdit_CreateFcn(hObject, eventdata, handles)
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function excludeStringEdit_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'String') returns contents of excludeStringEdit as text
    %        str2double(get(hObject,'String')) returns contents of excludeStringEdit as a double
    setInputList(hObject, handles);
end

function excludeStringEdit_CreateFcn(hObject, eventdata, handles)
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end



