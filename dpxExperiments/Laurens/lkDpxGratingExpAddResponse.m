function varargout = lkDpxGratingExpAddResponse(varargin)
    
    % varargout = lkDpxGratingExpAddResponse(varargin)
    %
    % Gui to select a lkDpxGratingExp stimulus and the 'ses' output of
    % Jorrit Montijn's two-photon processing suite (mountainpro) and merge
    % them. The output file should contain all information necessary for
    % any further analysis, if something is missing, change this file
    % (notably the mergeStimResp function) so it is included.
    %
    % Jacob Duijnhouwer, 2014-08-29
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @lkDpxGratingExpAddResponse_OpeningFcn, ...
        'gui_OutputFcn',  @lkDpxGratingExpAddResponse_OutputFcn, ...
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
    
    
    % --- Executes just before lkDpxGratingExpAddResponse is made visible.
function lkDpxGratingExpAddResponse_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to lkDpxGratingExpAddResponse (see VARARGIN)
    % Choose default command line output for lkDpxGratingExpAddResponse
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = lkDpxGratingExpAddResponse_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    
    % --- Executes on button press in browseStimfileButton.
function browseStimfileButton_Callback(hObject, eventdata, handles)
    set(handles.statusBar,'String','Browsing for stimulus file ...');
    try
        currentPath=fileparts(get(handles.stimField,'String'));
        if isempty(currentPath)
            currentPath='.';
        end
        [filestr, pathstr]=uigetfile('*.mat','Select a lkDpxGratingExp output file ...',currentPath);
        if filestr==0 % user canceled
            return;
        end
        stimFullFile=fullfile(pathstr,filestr);
        set(handles.stimField,'String',stimFullFile,'ForegroundColor',[0 0 0]);
        [~,errstr]=loadStimFile(stimFullFile);
        if ~isempty(errstr)
            set(handles.stimField,'ForegroundColor',[1 0 0])
            error(errstr);
        end
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
    set(handles.statusBar,'String','');
    
    
    % --- Executes on button press in browseResponseFileButton.
function browseResponseFileButton_Callback(hObject, eventdata, handles)
    set(handles.statusBar,'String','Browsing for response file ...');
    try
        currentPath=fileparts(get(handles.respField,'String'));
        if isempty(currentPath)
            currentPath='.';
        end
        [filestr, pathstr]=uigetfile('*_ses.mat','Select a MountainPro SES file ...',currentPath);
        if filestr==0 % user canceled
            return;
        end
        respFullFile=fullfile(pathstr,filestr);
        set(handles.respField,'String',respFullFile,'ForegroundColor',[0 0 0]);
        [resp,errstr]=loadRespFile(respFullFile);
        if ~isempty(errstr)
            set(handles.respField,'ForegroundColor',[1 0 0])
            error(errstr);
        end
        set(handles.statusBar,'String',[num2str(resp.ses.int_neuron) ' units detected in response file.']);
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
    
    
    % --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
    set(handles.statusBar,'String','');
    try
        [stim,errstr]=loadStimFile(get(handles.stimField,'String'));
        error(errstr);
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
    try
        [resp,errstr]=loadRespFile(get(handles.respField,'String'));
        error(errstr);
       % set(handles.statusBar,'String',[num2str(123)]);
    catch me
        set(handles.statusBar,'String',me.message);
        return;
    end
    try
        set(handles.statusBar,'String','Merging data ...'); drawnow
        data=mergeStimResp(stim.data,resp.ses); %#ok<NASGU>
        set(handles.statusBar,'String',''); drawnow
        % get the ses-file folder
        targetfolder=fileparts(get(handles.respField,'String'));
        % get the stimulus-file name
        [~,targetfilename]=fileparts(get(handles.stimField,'String'));
        % Change the extension .mat to +response.mat
        targetfilename=[targetfilename '+Response.mat'];
        % Cache the current folder (working directory)
        oldwd=pwd;
        % Let the user select a folder and a filename to save the merged data to
        cd(targetfolder);
        set(handles.statusBar,'String','Select merge data file destination'); drawnow
        [filename, targetfolder] = uiputfile({'*.mat'}, 'Save the merged data file as ...',targetfilename);
        cd(oldwd);
        if ischar(filename)
            save(fullfile(targetfolder,filename),'data');
            set(handles.statusBar,'String',['Saved ''' fullfile(targetfolder,filename) '''.']);
        else
            set(handles.statusBar,'String','Saving canceled');
        end
    catch me
        set(handles.statusBar,'String',me.message);
        return
    end
    
function [stim,errstr]=loadStimFile(stimFullFile)
    errstr=[];
    stim=load(stimFullFile);
    if ~isfield(stim,'data')
        errstr='Not a valid DPX stimulus file.';
    end
    if isfield(stim.data,'resp_nrUnits')
        errstr='This stimulus file already had responses added.';
    end
    
function [resp,errstr]=loadRespFile(respFullFile)
    errstr=[];
    resp=load(respFullFile);
    if ~isfield(resp,'ses');
        errstr='Not a valid MountainPro SES file';
    end
    
function [S]=mergeStimResp(S,R)
    % Get the relevant response data out of R and add it to S
    %
    S.resp_nrUnits=ones(1,S.N)*R.int_neuron;
    if R.int_neuron<=0
        warndlg('No neural responses detected, nothing to add.');
        return;
    end
    % Get the timing of the start and stop pulse as recorded by the
    % dpxGratingExp computer, these are stored in the strings txtStart and
    % txtEnd that can optionally trigger 'wait for pulse' behavior (using
    % 'magic' value 'DAQ-pulse')
    startPulseSec=str2double(regexp(S.exp_txtStart{1},'[-+]?[0-9]*\.?[0-9]+.','match'));
    % Check that the pulses were actually recorded
    if isnan(startPulseSec) || startPulseSec==-1
        error('No start DAQ-pulse was found in the stimulus file!');
    end
    S.durSecTiffs=numel(R.neuron(1).dFoF)/R.samplingFreq;
    % store the microscope image file folder in S
    for tr=1:S.N
        S.resp_imagesPath{tr}=R.strImPath;
    end
    % Get the info and the respones per trial for each neuron
    for i=1:R.int_neuron
        unitstr=['resp_unit' num2str(i,'%.3d')];
        for tr=1:S.N
            S.([unitstr '_type']){tr}=R.neuron(i).type;
            S.([unitstr '_xymap']){tr}=sparse(R.neuron(i).matMask); % the location of the unit in the image
            % TODO: use the movement correction info to shift the XY over
            % time, on a trial to trial basis.
        end
        % Cut this unit's dFoF in a segment per trial
        dFoF=R.neuron(i).dFoF;
        % perform a check of the timeseries duration with respect to start
        % and stop pulses recorded by DPX
        S.([unitstr '_dFoF'])=dpxSegmentTimeSeries('timeseries',dFoF,'sampleHz',R.samplingFreq,'starts',S.startSec-startPulseSec,'stops',S.stopSec-startPulseSec);
    end

    
    
    
    
