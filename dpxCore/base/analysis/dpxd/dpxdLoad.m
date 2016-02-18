function [DPXD,auxData]=dpxdLoad(filename,compat)

    % [dpxd,theRest]=dpxdLoad(filename,compat) 
    % Load a DPX-data file.
    %
    % DPXD files are simply MAT files, so they can be loaded with
    %   load(filename)
    % But that would instantiate the DPXD struct with whatever name it was saved
    % (typically 'data' but it could also be 'dpxd', or to whatever it might have been
    % named at some point). Standard matlab
    %   D=load(filename)
    % Would load the variable in the file as fields to structure D. dpxdLoad function does
    % that internally and outputs the first recognized DPXD structs into the output
    % argument DPXD. If there are more DPXDs structs in the file, the file is not a valid
    % DPXD file and an empty DPXD will be output and an warning thrown.
    %
    % A DPXD file may contain addiotional information which has to be stored in a separate
    % variable called 'auxData'. This data will be loaded into output argument auxData. 
    %
    % Optional argument 'compat' determines updates to the DPXD to update it to current
    % standards. It can be 'ignore','ramfix', or (default) 'filefix'.
    %   'ignore': don't update the DPXD
    %   'ramfix': update the loaded DPXD 
    %   'filefix': update the loaded DPXD and save it to disk (overwrites 'filename')
    %
    % EXAMPLE
    %    DPXD=dpxdLoad('yourExpDataFile.mat');
    %
    % Jacob Duijnhouwer, 2014-11-25
    %
    % 2015-12-04: added compat option
    
    if ~exist('compat','var') || isempty('compat')
        compat='filefix';
    end
    if ~any(strcmpi(compat,{'ignore','ramfix','filefix'}))
        error('Optional argument ''compat'' must be one of these strings: ''ignore'', ''ramfix'', [''filefix''].');
    end
    
    DPXD={};
    auxData=struct;
    if exist(filename,'file')
        K=load(filename);
    else
        error(['No file named ''' filename ''' exists.']);
    end
    flds=fieldnames(K);
    for i=1:numel(flds)
        if strcmp(flds{i},'auxData')
            auxData=K.(flds{i});
        elseif dpxdIs(K.(flds{i}))
            DPXD{end+1}=K.(flds{i}); %#ok<AGROW>
        else
            warning('a:b',['The file ''' filename ''' is not a DPXD.\n\tIt contains an illegal object called ''' flds{i} ''', which is not a DPXD-struct.\nA DPXD file must contain exactly one DPXD struct, and may contain one additional object called ''auxData''.']);
        end
    end
    if isempty(DPXD)
        warning(['The file ''' filename ''' did not contain a DPXD structure.']);
        DPXD=[];
        return;
    end
    if numel(DPXD)>1
        warning('a:b',['The file ''' filename ''' is not a valid DPXD-file.\nIt contains multiple (' num2str(numel(DPXD)) ') DPXD structures (with a name other than ''auxData'').\nUse regular ''load'' to access these.']);
        DPXD=[];
        return;
    end
    DPXD=DPXD{1};
    if isempty(fieldnames(auxData))
        auxData=[];
    end
    if ~strcmpi(compat,'ignore')
        [DPXD,nUpdates]=compatCheck(DPXD);
        if nUpdates>0
            dpxDispFancy(['Applied ' num2str(nUpdates) ' update(s) to the DPXD loaded from ' filename ],[],[],0,'*Comment');
            if strcmpi(compat,'filefix')
            try
                if isempty(auxData)
                    save(filename,'DPXD','-v7.3');
                else
                    save(filename,'DPXD','auxData','-v7.3');
                end
                dpxDispFancy('Succesfully saved the updated DPXD.',[],[],0,'*Comment');
            catch me
                me.getReport;
                dpxDispFancy('Could not update the file.',[],[],0,'*Error');
            end
        end    
    end
    end
end

function [DPXD,nUpdates]=compatCheck(DPXD)
    % Rename fields
    nUpdates=0;
    F=fieldnames(DPXD);
    % On 2015-11-30 exp_expName was renamed exp_paradigm
    if isfield(DPXD,'exp_expName') 
        F{strcmp(F,'exp_expName')}='exp_paradigm';
        nUpdates=nUpdates+1;
    end
    % On 2015-11-30 all scr_ variables were renamed window_
    for i=find(strncmp(F(:)','scr_',4))
        F{i}=['window_' F{i}(5:end)];
        nUpdates=nUpdates+1;
    end
    % On 2015-11-30 all scr_winRectPx variables were renamed window_rectPx
    if isfield(DPXD,'scr_winRectPx')
        F{strcmp(F,'window_winRectPx')}='window_rectPx';
        nUpdates=nUpdates+1;
    end
    if nUpdates>0
        % This methods of replacing fieldnames has the advantage over "a.new=a.old;
        % rmfield(a,'old')" that the order of the fields doesn't change
        DPXD=cell2struct(struct2cell(DPXD),F,1);
    end
end
    
