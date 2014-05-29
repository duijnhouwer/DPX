function varargout = dpxToolStimWindowGui(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @dpxToolStimWindowGui_OpeningFcn, ...
        'gui_OutputFcn',  @dpxToolStimWindowGui_OutputFcn, ...
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

function dpxToolStimWindowGui_OpeningFcn(hObject, eventdata, handles, varargin)
    if isempty(varargin)
        handles.stimWin = dpxStimWindow;
    elseif isobject(varargin{1})
        handles.stimWin = varargin{1};
    end
    % Keep these two lines at the end so the handles structure is updated
    handles.output = hObject;
    guidata(hObject,handles);
end

function varargout = dpxToolStimWindowGui_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end

function editButton_Callback(hObject, eventdata, handles)
    oldparams=dpxGetSetables(handles.stimWin);
    newparams=dpxGuiSetStruct(oldparams,'Edit settings');
    fn=fieldnames(newparams);
    for i=1:numel(fn)
        try
            handles.stimWin.(fn{i})=newparams.(fn{i});
        catch me
            handles.stimWin.(fn{i})=oldparams.(fn{i});
            uiwait(msgbox(me.message,['Error setting ' fn{i}],'error','modal'));
            editButton_Callback(hObject, eventdata, handles);
        end
    end
end

function testButton_Callback(hObject, eventdata, handles)
    handles.stimWin.open;
    starttt=GetSecs;
    for s={'Five','Four','Three','Two','One'}
        butPressed=dpxDisplayText(handles.stimWin.windowPtr ...
            ,[s{1} '\n\n(Any key to close)'] ...
            ,'rgbaback',handles.stimWin.backRGBA*handles.stimWin.whiteIdx ...
            ,'forceContinueAfterSecs',1,'fadeInSecs',0,'fadeOutSecs',1);
        if butPressed
            break;
        end
    end
    handles.stimWin.close;
end

function dispButton_Callback(hObject, eventdata, handles)
    parms=dpxGetSetables(handles.stimWin);
    fields=fieldnames(parms);
    vals=struct2cell(parms);
    str='E.physScr.set(';
    for i=1:numel(fields)
        v=vals{i};
        if isnumeric(v)
            if numel(v)==1
                v=num2str(v);
            else
                v=[ '[' strtrim(sprintf('%g ',vals{i})) ']' ];
            end
        elseif islogical(v)
            if v
                v='true';
            else
                v='false';
            end
        elseif ischar(v)
            v=[ '''' v ''''];
        else
            k=whos('v');
            error(['Can''t deal with objects of class ' k.class]);
        end
        str=[str '''' fields{i} ''',' v ','];
    end
    str=[str(1:end-1) '); % Generated using dpxToolStimWindowGui on '  datestr(now,'yyyy-mm-dd') ];
    helpstr='--- Copy the below string to your experiment file to use your settings: ';
    disp(' ');
    disp([helpstr repmat('-',1,numel(str)-numel(helpstr))]);disp(' ');
    disp(str);
    disp(' ');
    disp(repmat('-',1,numel(str)));
    msgbox('The settings string is displayed in the command window','Info');
end

function helpButton_Callback(hObject, eventdata, handles)
    
end