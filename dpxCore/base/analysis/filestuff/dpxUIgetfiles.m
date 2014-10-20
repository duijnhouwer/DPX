function fullnames=dpxUIgetfiles(varargin)
    
    % fullnames=dpxUIgetfiles(varargin) Get multiple filesnames. Extends
    % standard uigetfile in that you can get multiple files from multiple
    % directories. Filterspec is the file type (e.g. *.txt) and can be a cell array
    % of filetype strings. dialogtitle is the string to display on the dialog and dir is
    % the directory where to start browsing from. If file is not specified, the
    % global last used directory is opened as stored by dpxSetLastDirStr. Jacob
    %    p.addParamValue('filterspec','*.*',@ischar);
    %    p.addParamValue('dialogtitle','Selected files',@ischar);
    %    p.addParamValue('dir',dpxGetLastDirStr,@ischar);
    %    p.addParamValue('reload',false,@(x)islogical(x) || x==1 || x==0); % previous selection as default
    % Duijnhouwer 2009. See also: uigetfile
    
    global OPTIONS;
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParameter('filterspec','*.*',@ischar);
    p.addParameter('dialogtitle','Select files',@ischar);
    p.addParameter('dir',dpxGetLastDirStr,@ischar);
    p.addParameter('reload',false,@(x)islogical(x) || x==1 || x==0); % previous selection as default
    p.addParameter('multifolder',true,@(x)islogical(x) || x==1 || x==0); % interactively and iteratively select from multiple folders
    p.parse(varargin{:});
    OPTIONS=p.Results;
    
    if ~p.Results.reload
        fullnames=makeNewSelection;
    else
        % Load previous selection, i.e. variables filenames, fullnames, pathnames
        % And ask user if he wants to reload those or select from scratch
        try
            load('.matlabDpxUIgetfilesLastSelection.mat','fullnames','pathnames','filenames')
        catch ME
            disp(ME);
            filenames=[];
        end
        n=length(filenames);
        if n==0
            fullnames=makeNewSelection;
        else
            qstr=cell(0);
            qstr{1}=[pathnames{1} ' ...'];
            qstr{end+1}=['...' filesep filenames{1}];
            for i=2:n
                if ~strcmp(pathnames{i},pathnames{i-1})
                    qstr{end+1}=[pathnames{i} ' ...'];
                end
                qstr{end+1}=['...' filesep filenames{i}];
            end
            qstr{end+1}='';
            if n>1
                qstr{end+1}=['Previously these ' num2str(n) ' files were selected. Keep this selection?'];
            else
                qstr{end+1}=['Previously this files were selected. Keep this selection?'];
            end
            BT1='Yes, keep selection';
            BT2='No, let me select manually';
            astr=questdlg(qstr,'Selected file(s)',BT1,BT2,BT1);
            if strcmp(astr,BT1)
                % Keeping previous selection
                return;
            else
                fullnames=makeNewSelection(pathnames{1});
            end
        end
    end
end

function fullnames=makeNewSelection(startdir)
    global OPTIONS;
    filterspec=OPTIONS.filterspec;
    dialogtitle=OPTIONS.dialogtitle;
    if nargin==0
        startdir=OPTIONS.dir;
    end
    fullnames={};
    pathnames={};
    filenames={};
    while 1
        [newnames pathname]=uigetfile(filterspec,dialogtitle,startdir,'MultiSelect', 'on');
        if ischar(newnames) % only one file selected
            pathnames{end+1}=pathname;
            filenames{end+1}=newnames;
            fullnames{end+1}=[pathname newnames];
            dpxSetLastDirStr(pathname);
        elseif iscell(newnames)
            for i=1:length(newnames)
                pathnames{end+1}=pathname;
                filenames{end+1}=newnames{i};
                fullnames{end+1}=[pathname newnames{i}];
            end
            dpxSetLastDirStr(pathname);
        elseif newnames==0
            % user pressed cancel in filedialog, don't save last dir either
            % fullnames={};
        end
        %
        if ~OPTIONS.multifolder
            return;
        end
        %
        n=length(filenames);
        if n==0
            qstr='No file selected. Select files?';
            BT1='Yes, select files';
            BT2='No, cancel';
            BT3='';
            astr=BT2;
            % astr=questdlg(qstr,'Select file(s)',BT1,BT2,BT2);
        elseif n==1
            qstr=cell(0);
            qstr{1}=fullnames{1};
            qstr{end+1}='';
            qstr{end+1}='One file selected. Select more files?';
            BT1='Select more';
            BT2='Done';
            BT3='Clear list, start over';
            astr=questdlg(qstr,'Selected file(s)',BT1,BT2,BT3,BT2);
        else
            qstr=cell(0);
            qstr{1}=[pathnames{1} ' ...'];
            qstr{end+1}=['...' filesep filenames{1}];
            for i=2:n
                if ~strcmp(pathnames{i},pathnames{i-1})
                    qstr{end+1}=[pathnames{i} ' ...'];
                end
                qstr{end+1}=['...' filesep filenames{i}];
            end
            qstr{end+1}='';
            qstr{end+1}=[num2str(n) ' files selected. Select more files?'];
            BT1='Select more';
            BT2='Done';
            BT3='Clear list, make new selection';
            astr=questdlg(qstr,'Selected file(s)',BT1,BT2,BT3,BT2);
        end
        if strcmp(astr,BT3) % 'Clear list, make new selection';
            pathnames=cell(0);
            filenames=cell(0);
            fullnames=cell(0);
        elseif strcmp(astr,BT2) % 'No, done';
            % Save the selection in a cache to provide default values for when this funtion gets called again
            p=regexp(userpath,';','split');
            fname=fullfile(p{1},'.matlabDpxUIgetfilesLastSelection.mat');
            save(fname,'fullnames','pathnames','filenames');
            return;
        elseif strcmp(astr,BT1) % Yes, select more'
            % do this while loop once more
        else
            error(['Unexpected return value: ' astr '.']);
        end
        pause(.01); % process user interupt (e.g. CTRL-C)
    end
end
