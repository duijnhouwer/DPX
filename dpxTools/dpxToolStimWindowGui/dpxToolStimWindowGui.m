function varargout = dpxToolStimWindowGui(varargin)
    % dpxToolStimWindowGui
    % Jacob 2014-05-29
    % Type dpxToolStimWindowGui and press Help button for instructions.
    
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
        handles.stimWin = dpxCoreWindow;
    elseif isobject(varargin{1})
        handles.stimWin = varargin{1};
    end
    handles.unitSpace='mm';
    displaySetup(hObject, eventdata, handles);
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
    displaySetup(hObject, eventdata, handles);
end

function testButton_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
    handles.stimWin.open;
    textRGBA=[1 1 1 1];
    if all(handles.stimWin.backRGBA==textRGBA)
        textRGBA=[1-handles.stimWin.backRGBA(1:3) 1];
    end
    closingTime=false;
    while ~closingTime
        closingTime=dpxDisplayText(handles.stimWin.windowPtr ...
            ,'D P X\nEscape: close this window\nSpace: remove the text' ...
            ,'rgba',textRGBA ...
            ,'rgbaback',handles.stimWin.backRGBA ...
            ,'forceAfterSec',Inf,'fadeInSec',1/3,'fadeOutSec',1/2);
        if ~closingTime
            % Space is pressed. This solid window can be used to measure the
            % luminance of the screen. Convenient for finding liniarized gamma!
            FlushEvents([],[],'keyDown');
            pause(0.05);
            closingTime=dpxDisplayText(handles.stimWin.windowPtr ...
                ,'' ...
                ,'rgbaback',handles.stimWin.backRGBA ...
                ,'forceAfterSec',Inf,'fadeInSec',0,'fadeOutSec',0);
        end
    end
    handles.stimWin.close;
end

function dispButton_Callback(hObject, eventdata, handles)
    parms=dpxGetSetables(handles.stimWin);
    fields=fieldnames(parms);
    vals=struct2cell(parms);
    str='E.window.set(';
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
            error(['Can''t handle objects of class ' k.class]);
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
    %msgbox('The settings string is displayed in the command window','Info');
end

function helpButton_Callback(hObject, eventdata, handles)
    info={'dpxToolStimWindowGui',' ' ...
        ,'2014-05-29, Jacob Duijnhouwer',' ' ...
        ,['Graphical tool to edit and inspect settings of ' handles.stimWin.type ' objects.'] ...
        ,' ','BUTTONS:'...
        ,'Edit: edit the settings' ...
        ,'Test: attempt to open the stimulus window' ...
        ,'Disp: display the settings in the command window, paste this string into your experiment file' ...
        ,' ','USAGE:,' ...
        ,['This editor can be opened from the command line by typing "dpxToolStimWindowGui" or by calling the "gui" method of existing ' handles.stimWin.type ' objects.'] ...
        ,' ','TIPS:'...
        ,'On Windows, make sure your stimulus screen is the "primary display" using the "This is my main monitor" check box in the Displays Control Panel.' ...
        ,'Settings "rectPx" and/or "widHeiMm" can be left empty to let ' handles.stimWin.type ' attempt to determine those automatically.'};
    uiwait(msgbox(info,'Help','modal'));
end


function unitMmButton_Callback(hObject, eventdata, handles)
    handles.unitSpace='mm';
    displaySetup(hObject, eventdata, handles);
    guidata(hObject,handles);
end
function unitPxButton_Callback(hObject, eventdata, handles)
    handles.unitSpace='px';
    displaySetup(hObject, eventdata, handles);
    guidata(hObject,handles);
end
function unitDegButton_Callback(hObject, eventdata, handles)
    handles.unitSpace='deg';
    displaySetup(hObject, eventdata, handles);
    guidata(hObject,handles);
end


function displaySetup(hObject, eventdata, handles)
    % handles.setupSchematic('box','on','axis','off')
    h=handles.setupSchematic;
    s=handles.stimWin;
    cla(h);
    hold on
    if std(s.backRGBA(1:3))==0
        linecolor='b';
        textcolor='r';
    else
        linecolor=1-s.backRGBA(1:3);
        textcolor=1-s.backRGBA(1:3);
    end
    unitStr=handles.unitSpace;
    eyeRadiusPx=s.interEyePx/2.7;
    % plot the screen
    x=[-1 1 1 -1]*s.widPx/2;
    y=[-1 -1 1 1]*s.heiPx/2;
    z=[0 0 0 0];
    fill3(z,x,y,s.backRGBA(1:3),'LineWidth',2,'EdgeColor',linecolor,'FaceAlpha',.5);
    % plot the cyclopean viewline
    x=[0 0];
    y=[0 0];
    z=[0 -s.distPx];
    plot3(z,x,y,'k-','LineWidth',2,'Color',linecolor);
    % plot the ocular axis
    x=[-s.interEyePx s.interEyePx];
    y=[0 0];
    z=[-s.distPx -s.distPx];
    plot3(z,x,y,'k-','LineWidth',2,'Color',linecolor);
    % plot the eyeballs
    [x,y,z]=sphere(11);
    xLeft=x*eyeRadiusPx-s.interEyePx;
    xRite=x*eyeRadiusPx+s.interEyePx;
    y=y*eyeRadiusPx;
    z=z*eyeRadiusPx-s.distPx;
    mesh(z,xLeft,y,'EdgeColor',linecolor,'FaceColor','w','FaceAlpha',.5,'EdgeAlpha',.5);
    mesh(z,xRite,y,'EdgeColor',linecolor,'FaceColor','w','FaceAlpha',.5,'EdgeAlpha',.5);
    % annotate
    switch handles.unitSpace
        case 'px'
            text(-eyeRadiusPx,s.widPx/3,s.heiPx/3,[' ' num2str(round(s.widPx)) ' x ' num2str(s.heiPx,'%.0f') ' ' unitStr],'Color',textcolor);
            text(-s.distPx/2,s.interEyePx/2,s.interEyePx/2,[' ' num2str(round(s.distPx),'%.0f') ' ' unitStr],'Color',textcolor);
            text(-s.distPx,s.interEyePx/2,s.interEyePx/2,[' ' num2str(round(s.interEyePx),'%.0f') ' ' unitStr],'Color',textcolor);
        case 'deg'
            text(-eyeRadiusPx,s.widPx/3,s.heiPx/3,[' ' num2str(round(s.widPx*10/s.deg2px)/10) ' x ' num2str(round(s.heiPx*10/s.deg2px)/10) ' ' unitStr],'Color',textcolor);
            text(-s.distPx/2,s.interEyePx/2,s.interEyePx/2,[' ' num2str(round(s.distPx*10/s.deg2px)/10) ' ' unitStr],'Color',textcolor);
            text(-s.distPx,s.interEyePx/2,s.interEyePx/2,[' ' num2str(round(s.interEyePx*10/s.deg2px)/10) ' ' unitStr],'Color',textcolor);
        case 'mm'
            text(-eyeRadiusPx,s.widPx/3,s.heiPx/3,[' ' num2str(round(s.widPx/s.mm2px)) ' x ' num2str(s.heiPx/s.mm2px,'%.0f') ' ' unitStr],'Color',textcolor);
            text(-s.distPx/2,s.interEyePx/2,s.interEyePx/2,[' ' num2str(round(s.distPx/s.mm2px)) ' ' unitStr],'Color',textcolor);
            text(-s.distPx,s.interEyePx/2,s.interEyePx/2,[' ' num2str(round(s.interEyePx/s.mm2px)) ' ' unitStr],'Color',textcolor);
        otherwise
            error(['Unknown spatial unit: ' handles.unitSpace]);
    end
    % view options
    view(3);
    rotate3d on
    axis equal;
    lims=axis;
    text(mean(lims(1:2)),lims(3),lims(5),'z','Color',textcolor);
    text(min(lims(1:2)),0,lims(5),'x','Color',textcolor);
    text(min(lims(1:2)),lims(3),0,'y','Color',textcolor);
    box on;
    set(gca,'XTick',[],'YTick',[],'ZTick',[])
end