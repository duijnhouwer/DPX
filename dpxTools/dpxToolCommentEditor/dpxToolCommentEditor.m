function varargout = dpxToolCommentEditor(varargin)
    % DPXTOOLCOMMENTEDITOR MATLAB code for dpxToolCommentEditor.fig
    %      DPXTOOLCOMMENTEDITOR, by itself, creates a new DPXTOOLCOMMENTEDITOR or raises the existing
    %      singleton*.
    %
    %      H = DPXTOOLCOMMENTEDITOR returns the handle to a new DPXTOOLCOMMENTEDITOR or the handle to
    %      the existing singleton*.
    %
    %      DPXTOOLCOMMENTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in DPXTOOLCOMMENTEDITOR.M with the given input arguments.
    %
    %      DPXTOOLCOMMENTEDITOR('Property','Value',...) creates a new DPXTOOLCOMMENTEDITOR or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before dpxToolCommentEditor_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to dpxToolCommentEditor_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help dpxToolCommentEditor
    
    % Last Modified by GUIDE v2.5 12-Nov-2014 21:15:42
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @dpxToolCommentEditor_OpeningFcn, ...
        'gui_OutputFcn',  @dpxToolCommentEditor_OutputFcn, ...
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

% --- Executes just before dpxToolCommentEditor is made visible.
function dpxToolCommentEditor_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to dpxToolCommentEditor (see VARARGIN)
    
    % Choose default command line output for dpxToolCommentEditor
    handles.output = hObject;
    %
    p = inputParser;
    p.addParamValue('filename','',@ischar);
    p.parse(varargin{:});
    set(handles.filePanel,'Title',p.Results.filename,'ForegroundColor',[0 0 0]);
    handles.currentComment=1;
    handles.dpxd=[];
    % Update handles structure
    guidata(hObject, handles);
    %
    showComment(hObject, handles);
end



% UIWAIT makes dpxToolCommentEditor wait for user response (see UIRESUME)
%uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dpxToolCommentEditor_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end



%function commentEdit_Callback(hObject, eventdata, handles)
    % hObject    handle to commentEdit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of commentEdit as text
    %        str2double(get(hObject,'String')) returns contents of commentEdit as a double
%end

% --- Executes during object creation, after setting all properties.
%function commentEdit_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to commentEdit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
 %   if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
 %       set(hObject,'BackgroundColor','white');
 %   end
%end


% --- Executes on button press in previousCommentButton.
function previousCommentButton_Callback(hObject, eventdata, handles)
    if isempty(handles.dpxd)
        set(handles.statusBar,'String','Load DPXD data first');
        return;
    end
    if handles.currentComment==1
        return;
    else
        set(handles.commentTextField,'Style','text');
       handles.currentComment=handles.currentComment-1;
       guidata(hObject, handles);
       showComment(hObject, handles);
    end
end

% --- Executes on button press in nextCommentButton.
function nextCommentButton_Callback(hObject, eventdata, handles)
    if isempty(handles.dpxd)
        set(handles.statusBar,'String','Load DPXD data first');
        return;
    end
    if handles.currentComment==getNumberOfComments(handles)
        return;
    else
       set(handles.commentTextField,'Style','text');
       handles.currentComment=handles.currentComment+1;
       guidata(hObject, handles);
       showComment(hObject, handles);
    end
end

% --- Executes on button press in editCommentButton.
function editCommentButton_Callback(hObject, eventdata, handles)
    if isempty(handles.dpxd)
        set(handles.statusBar,'String','Load DPXD data first');
        return;
    end
    switch get(handles.commentTextField,'Style')
        case 'text'
            set(handles.commentTextField,'Style','edit');
            set(handles.commentTextField,'KeyPressFcn', @(hObject,eventdata)dpxToolCommentEditor('keyPressCommentTextField',hObject,eventdata,guidata(hObject)));
            guidata(hObject, handles);
        case 'edit'
            keyPressCommentTextField(hObject, struct('Key','return'), handles); % emulate enter press in textfield
        otherwise
            error(['commentTextField should be of style text or edit, not ' get(handles.commentTextField,'Style')]);
    end
end

function keyPressCommentTextField(hObject, eventdata, handles)
    % This function is called when a key is pressed while editing the
    % comment-text field (big box where the comments are shown). If the key
    % happens to be enter, this will end editing, and copy the new string
    % in to the DPXD. By design we keep the timestamp of the origal
    % comment, editing is supposed to be a means of clarifying comments.
    if strcmpi(eventdata.Key,'return')
        pause(0.1); % CRUCIAL! computer needs some time to get the string into the uicontrol, weird but true
        newstr=get(handles.commentTextField,'String');
        set(handles.commentTextField,'Style','text');
        set(handles.commentTextField,'String',newstr);
        for i=1:handles.dpxd.N
            handles.dpxd.plugin_comments_inputs{i}{handles.currentComment}=newstr;
        end
        set(handles.commentTextField,'KeyPressFcn',[]);
        guidata(hObject, handles);
    end
end

% --- Executes on button press in addCommentButton.
function addCommentButton_Callback(hObject, eventdata, handles)
    if isempty(handles.dpxd)
        set(handles.statusBar,'String','Load DPXD data first');
        return;
    end
    switch get(handles.commentTextField,'Style')
        case 'text'
            handles.currentComment=getNumberOfComments(handles)+1;
            time=now;
            for i=1:handles.dpxd.N
                handles.dpxd.plugin_comments_inputs{i}{handles.currentComment}='';
                handles.dpxd.plugin_comments_secs{i}{handles.currentComment}=time;
            end
            set(handles.commentTextField,'Style','edit');
            set(handles.commentTextField,'KeyPressFcn', @(hObject,eventdata)dpxToolCommentEditor('keyPressCommentTextField',hObject,eventdata,guidata(hObject)));
            guidata(hObject, handles);
            showComment(hObject, handles);
        case 'edit'
            keyPressCommentTextField(hObject, struct('Key','return'), handles); % emulate enter press in textfield
        otherwise
            error(['commentTextField should be of style text or edit, not ' get(handles.commentTextField,'Style')]);
    end
end

% --- Executes on button press in deleteCommentButton.
function deleteCommentButton_Callback(hObject, eventdata, handles)
    if getNumberOfComments(handles)<=0
        return;
    end
    for i=1:handles.dpxd.N
        handles.dpxd.plugin_comments_inputs{i}(handles.currentComment)=[];
        handles.dpxd.plugin_comments_secs{i}(handles.currentComment)=[];
    end
    handles.currentComment=min(handles.currentComment,getNumberOfComments(handles));
    guidata(hObject, handles);
    showComment(hObject, handles);
end

% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
    set(handles.statusBar,'String','Browsing for DPXD file ...');
    try
        [filestr, pathstr]=uigetfile('*.mat','Select a DPXD file ...',pwd);
        if filestr==0 % user canceled
            set(handles.statusBar,'String','User canceled "Open file ..."','ForegroundColor',[0 0 0]);
            return;
        end
        ff=fullfile(pathstr,filestr);
        set(handles.filePanel,'Title',ff,'ForegroundColor',[0 0 0]);
        handles.dpxd=loadDPXD(handles);
        handles.currentComment=1;
        guidata(hObject, handles);
        showComment(hObject, handles);
        set(handles.statusBar,'String','');
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
end

function showComment(hObject, handles)
    if isempty(handles.dpxd)
        handles.dpxd=loadDPXD(handles);
        if isempty(handles.dpxd)
            return;
        end
    end
    nrComments=getNumberOfComments(handles);
    if nrComments==0
        set(handles.commentTextField,'String','');
        set(handles.commentTime,'String','');
        set(handles.commentTextPanel,'Title','No comments');
    else
        allComments=handles.dpxd.plugin_comments_inputs(1);
        allTimes=handles.dpxd.plugin_comments_secs(1);
        set(handles.commentTextField,'String',allComments{1}{handles.currentComment});
        set(handles.commentTime,'String',datestr(allTimes{1}{handles.currentComment},'YYYY/mm/DD\nHH:MM:SS'));
        set(handles.commentTextPanel,'Title',['Comment ' num2str(handles.currentComment) ' of ' num2str(nrComments)]);
    end
    guidata(hObject, handles);
end

function dpxd=loadDPXD(handles)
    dpxd=[];
    try
        tmp=load(get(handles.filePanel,'Title'));
        fns=fieldnames(tmp);
        nDPDXstructs=0;
        idx=[];
        for i=1:numel(fns)
            if dpxdIs(tmp.(fns{i}))
                nDPDXstructs=nDPDXstructs+1;
                idx=i;
            end
        end
        if nDPDXstructs>1
            error('A DPXD-file must contain a single DXPD-struct (and arbitray other variable) but this file contains more');
        end
        dpxd=tmp.(fns{idx});
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
end

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
    % retrieve the original variable name, could be 'data' (which is was
    % always in the beginning), or it could be dpxd (my later preference),
    % or who knows. For what it's worth, this way the name of the variable
    % in the DPXD file is flexible.
    try
        fname=get(handles.filePanel,'Title');
        tmp=load(get(handles.filePanel,'Title'));
        fns=fieldnames(tmp);
        % There can be multiple arbitrary variables in a DPXD file, but
        % only one dxpd struct.
        for i=1:numel(fns)
            if dpxdIs(tmp.(fns{i}))
                dpxdIdx=i;
                break;
            end
        end
        % load the variables as ordinary variable, not as fields of a struct (by omitting output variable)
        load(get(handles.filePanel,'Title'));
        eval([fns{dpxdIdx} '=handles.dpxd;']);
        save(fname,fns{:});
        set(handles.statusBar,'String',['Saved to file ''' fname '''']);
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
end

function N=getNumberOfComments(handles)
    if ~isfield(handles.dpxd,'plugin_comments_inputs')
        N=0;
    else
        N=numel(handles.dpxd.plugin_comments_inputs{1});
    end
end
