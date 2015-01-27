function varargout = dpxdMergeGUI(varargin)
    % Tool to merge datafiles using a GUI
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @dpxdMergeGUI_OpeningFcn, ...
        'gui_OutputFcn',  @dpxdMergeGUI_OutputFcn, ...
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
    
    
    % --- Executes just before dpxdMergeGUI is made visible.
function dpxdMergeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to dpxdMergeGUI (see VARARGIN)
    
    % Choose default command line output for dpxdMergeGUI
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes dpxdMergeGUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = dpxdMergeGUI_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    
    % --- Executes on selection change in fileToMergeList.
function fileToMergeList_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns fileToMergeList contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from fileToMergeList
    
    
    % --- Executes during object creation, after setting all properties.
function fileToMergeList_CreateFcn(hObject, eventdata, handles)
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    % --- Executes on button press in butAddFiles.
function butAddFiles_Callback(hObject, eventdata, handles)
    list=cellstr(get(handles.fileToMergeList,'String'));
    fullnames=dpxUIgetfiles('filterspec','*.mat', 'dialogtitle','Select DPXD files ...','multifolder',get(handles.chkMultiFolder,'Value'));
    list=[list(:);fullnames(:)];
    list=list(~cellfun(@isempty,list)); % remove empty strings
    list=unique(list); % remove duplicates
    set(handles.fileToMergeList,'String',list,'FontName','fixed','Min',0,'Max',numel(list));
    
    
    
    % --- Executes on button press in butRemove.
function butRemove_Callback(hObject, eventdata, handles)
    list=cellstr(get(handles.fileToMergeList,'String'));
    selectedIdx=get(handles.fileToMergeList,'Value');
    notSelectedIdx=~ismember(1:numel(list),selectedIdx);
    list=list(notSelectedIdx);
    set(handles.fileToMergeList,'String',list,'Value',[]);%,'Min',1,'Max',numel(list));
    
    
    % --- Executes on button press in chkMultiFolder.
function chkMultiFolder_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of chkMultiFolder
    
    
    % --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    win=get(hObject,'Position');
    
    
    % --- Executes on selection change in listCommonFields.
function listCommonFields_Callback(hObject, eventdata, handles)
    % hObject    handle to listCommonFields (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns listCommonFields contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from listCommonFields
    
    
    % --- Executes during object creation, after setting all properties.
function listCommonFields_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listCommonFields (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
    
    % --- Executes on button press in butMergeAndSave.
function butMergeAndSave_Callback(hObject, eventdata, handles)
    handles=loadTheFiles(hObject,handles);
    [commonFields,unCommonFields]=getCommonFields(handles.dpxdCell);
    set(handles.listCommonFields,'String',commonFields,'FontName','fixed','Min',0,'Max',1);
    set(handles.listUncommonFields,'String',unCommonFields,'FontName','fixed','Min',0,'Max',numel(commonFields));
    if numel(unCommonFields)>0
        warndlg('Can''t merge the files because of inconsistencies. Make another selection, or resolve the compatibility issues and try again');
        handles=rmfield(handles,'dpxdCell');
        guidata(hObject,handles);
    else
        dpxd=dpxdMerge(handles.dpxdCell);
        oldwd=pwd;
        try
            cd(dpxGetLastDirStr);
        catch
        end
        outfile=composeFilename(dpxd);
        [filename,pathname]=uiputfile('*.mat','Save merged DPXD file as ...',outfile);
        if isnumeric(filename)
            % user pressed cancel
        else
            save(fullfile(pathname,filename),'dpxd');
            cd(oldwd);
        end
    end
    
    
function [outfile,outpath]=composeFilename(D)
    outpath=dpxGetLastDirStr;
    try
        paradigms=unique(D.exp_expName);
        if numel(paradigms)==1
            P=paradigms{1};
        elseif numel(paradigms)==2
            P=[paradigms{1} '+' paradigms{2}];
        else
            P=[num2str(numel(paradigms)) 'mergedParadigms'];
        end
        subjects=unique(D.exp_subjectId);
        if numel(subjects)>5
            S=[num2str(numel(subjects)) 'subjects'];
        else
            S=subjects{1};
            for i=2:numel(subjects)
                S=[S ',' subjects{i}];
            end
        end
        T=unique(D.exp_startTime);
        T=datestr(T,'YYYYMMDD');
        if size(T,1)>=1
            T=[T(1,:) 'to' T(end,:)];
        end
        outfile=[P '-' S '-' T];
    catch me  
        outfile='mergedDPXDs.mat';
    end
    
    
    
function handles=loadTheFiles(hObject,handles)
    list=cellstr(get(handles.fileToMergeList,'String'));
    handles.dpxdCell=cell(numel(list),1);
    for i=1:numel(list)
        set(handles.fileToMergeList,'Value',1:i); % hilite files that are loaded
        pause(0.05);
        K=load(list{i});
        flds=fieldnames(K);
        foundData=false;
        for fi=1:numel(flds)
            if dpxdIs(K.(flds{fi}))
                handles.dpxdCell{i}=K.(flds{fi});
                foundData=true;
            end
            break;
        end
        if foundData==false
            warndlg({'No DPXD data was found in file:', list{i}});
            handles.dpxdCell={};
        end
    end
    guidata(hObject,handles);
    
    
function [commonFields,unCommonFields]=getCommonFields(dpxdCell)
    if nargout==1
        commonFields=fieldnames(dpxdCell{1});
        for i=2:numel(dpxdCell)
            commonFields=intersect(commonFields,fieldnames(dpxdCell{i}));
        end
    else
        allfields={};
        commonFields=fieldnames(dpxdCell{1});
        for i=1:numel(dpxdCell)
            commonFields=intersect(commonFields,fieldnames(dpxdCell{i}));
            allfields=[allfields ; fieldnames(dpxdCell{i})]; %#ok<AGROW>
        end
        allfields=unique(allfields);
        unCommonFields=setdiff(allfields,commonFields);
    end
    
    
    
    % --- Executes on selection change in listUncommonFields.
function listUncommonFields_Callback(hObject, eventdata, handles)
    % hObject    handle to listUncommonFields (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns listUncommonFields contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from listUncommonFields
    
    
    % --- Executes during object creation, after setting all properties.
function listUncommonFields_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listUncommonFields (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on button press in butAddPlaceholder.
function butAddPlaceholder_Callback(hObject, eventdata, handles)
    list=cellstr(get(handles.listUncommonFields,'String'));
    hilited=list(get(handles.listUncommonFields,'Value'));
    if numel(hilited)>1
        doCoOccur=checkFieldnamesCoOccurInFiles(hilited,handles.dpxdCell);
        if doCoOccur
            warndlg('Can''t merge the selected fields, two or more co-occur in one or more data-files');
            return;
        end
        prompt='Pick a name for the merged fields';
        lSize=[400 16*numel(hilited)];
        [idx,ok]=listdlg('ListString',hilited,'Name','dpxdMergeGUI: pick a name' ...
            ,'PromptString',prompt,'ListSize',lSize,'SelectionMode','single');
        if ok
            name=hilited(idx);
        else
            return; % user cancelled
        end
    else
        name=hilited;
    end
    for i=1:numel(handles.dpxdCell)
        if isfield(handles.dpxdCell{i},name)
            continue;
        else
            nametochange=hilited(isfield(handles.dpxdCell{i},hilited));
            if ~isempty(nametochange)
                handles.dpxdCell{i}.(name)=handles.dpxdCell{i}.(nametochange);
                handles.dpxdCell{i}=rmfield(handles.dpxdCell{i},nametochange);
            else
                handles.dpxdCell{i}.(name)=nan(1,handles.dpxdCell{i}.N);
            end
        end
    end
    guidata(hObject, handles);
    
    
function doCoOccur=checkFieldnamesCoOccurInFiles(hilited,dpxdCell)
    doCoOccur=false;
    for i=1:numel(dpxdCell)
        f=fieldnames(dpxdCell{i});
        doCoOccur=numel(intersect(hilited,f))>1;
        if doCoOccur
            break;
        end
    end
    
    
    
    % --- Executes on button press in butPoolFields.
function butPoolFields_Callback(hObject, eventdata, handles)
    % hObject    handle to butPoolFields (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    % --- Executes on selection change in fileToMergeList.
function listbox5_Callback(hObject, eventdata, handles)
    % hObject    handle to fileToMergeList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns fileToMergeList contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from fileToMergeList
    
    
    % --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to fileToMergeList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
