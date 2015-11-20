function lkUpdateFormatDpxTuningSpeedGrat0
    
    % Update some fields in older datafiles so they work with the current
    % analysis
    % Jacob 2015-11-20
    
    ButtonName=questdlg('This function will replace your files. It is recommended to make backups before proceeding.', mfilename, 'Proceed', 'Cancel', 'Cancel');
    if ~strcmpi(ButtonName,'Proceed')
        return;
    end
    
    files=dpxUIgetFiles('title','Select DpxTuningSpeedGrat0 files to replace with updates','extensions',{'*.mat','*.dpxd','*.*'});
    if isempty(files)
        return;
    end
    
    removeFields={...
        'mcc_xDeg'...
        ,'mcc_yDeg'...
        ,'mcc_zDeg'...
        ,'mcc_wDeg'...
        ,'mcc_hDeg'...
        ,'mcc_aDeg'...
        ,'mcc_fixWithinDeg'...
        };
    addFields={...
        'mask_enabled',true...
        ,'test_enabled',true...
        ,'mcc_enabled',true...
        };
    for i=1:numel(files)
        try
            [data,theRest]=dpxdLoad(files{i}); %#ok<ASGLU>
        catch me
            warning(['There was a problem LOADING file ''' files{i} ''':']);
            disp(me.message);
        end
        try
            data=rmfield(data,removeFields);
        catch
            % fieldname was probably already absent, carry on. extra fiels is not
            % really a problem anyway
        end
        try
            for afi=1:2:numel(addFields)
                data.(addFields{afi})=repmat(addFields{afi+1},1,data.N);
            end
            note=['This file was updated with ' mfilename ' on ' datestr(now) '.']; %#ok<NASGU>
            save(files{i},'data','note');
            disp(['Updated ''' files{i} ''.']);
        catch me
            warning(['There was a problem updating file ''' files{i} ''':']);
            disp(me.message);
        end
    end
end
