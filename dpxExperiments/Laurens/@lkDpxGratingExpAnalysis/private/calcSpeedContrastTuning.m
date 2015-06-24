function tc=calcSpeedContrastTuning(dpxd,cellNr,varargin)
    
    if nargin==1 && strcmp(dpxd,'info')
        tc.per='cell';
        return;
    end
    % This function calculates a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, its output can be plot with the
    % complementary plotSpeedContrastTuning
    
    % See how many sessions went into this dataset, could be merged data.
    % If so, plot the individual session curves as well as the merged curve
    % (merged on top and clearer line and markers)
    tc{1}=getSpeedContrastCurves(dpxd,cellNr,varargin{:}); % Nr. 1 is always all data
    thisIsMergeData=numel(unique(dpxd.exp_startTime))>1;
    if thisIsMergeData
        D=dpxdSplit(dpxd,'exp_startTime');
        for i=1:numel(D)
            tc{end+1}=getSpeedContrastCurves(D{i},cellNr,varargin{:}); %#ok<AGROW>
        end
    end
end

function tc=getSpeedContrastCurves(dpxd,cellNr,varargin)
    % Parse 'options' input
    p=inputParser;
    p.addParamValue('dirDeg','auto',@(x)strcmpi(x,'auto')||isnumeric(x)&&numel(x)==1); %#ok<NVREPL>
    p.parse(varargin{:});
    %
    % Split the data according to the direction of the test-grating.
    % Ds is the DPXD called 'dpxd' split up in a DPXD per direction (so
    % numel Ds would typically be 8). Ns is an array corrsponding to Ds
    % that contains the N of each DPXD in Ds
    if strcmpi(p.Results.dirDeg,'auto')
        dpxd=dpxdSplit(dpxd,'test_dirDeg');
        if numel(dpxd)>1
            error('The data contained more than one direction. Use options ''dirDeg'' to specify the directions (in degrees) that you wish to limit the analysis too');
        end 
    else
        dpxd=dpxdSubset(dpxd,dpxd.test_dirDeg==p.Results.dirDeg);
    end
    
    C=dpxdSplit(dpxd,'test_contrastFrac');
    tc=cell(1,numel(C));
    for i=1:numel(C)
        tc{i}=getOneSpeedCurve(C{i},cellNr);
        tc{i}.contrast=C{i}.test_contrastFrac(1);
    end
    tc=dpxdMerge(tc);
    if ~dpxdIs(tc)
        error('tc should be a dpxd struct');
    end
end


function tc=getOneSpeedCurve(C,cellNr)
    % Make a speed field
    C.test_speed=C.test_cyclesPerSecond./C.test_cyclesPerDeg;
    % Split by speed
    [Ds,Ns]=dpxdSplit(C,'test_speed');
    % Preallocate the list of directions ...
    speed=NaN(1,numel(Ds));
    % Preallocate the table of responses
    dfof=NaN(max(Ns),numel(Ds)); % rows=trials, cols=directions
    % Construct the response and time fieldnames of this cellNr
    dfofField=['resp_unit' num2str(cellNr,'%.3d') '_dFoF']; % e.g., if cellNr is 1, 'resp_unit001_dFoF'
    timeField=['resp_unit' num2str(cellNr,'%.3d') '_s']; % e.g., if cellNr is 1, 'resp_unit001_s'
    for i=1:numel(Ds) % loop over all directions
        speed(i)=Ds{i}.test_speed(1); % store this speed
        for t=1:Ds{i}.N
            % Get the dFoF trace of the entire t'th trial for this direction
            tSeries=Ds{i}.(dfofField){t};
            % Get the corresponding time axis
            tAxis=Ds{i}.(timeField){t};
            % Use tAxit to limit trace to the time the stim was on
            from=Ds{i}.test_onSec(t);
            to=from+Ds{i}.test_durSec(t);
            tSeries=tSeries(tAxis>=from & tAxis<to);
            % Store the mean of this segment, i.e., reduce trail's response to a single value
            dfof(t,i)=nanmean(tSeries); % nanmean because it ignores NaN's
        end
    end
    % put the values in the output struct 
    tc.speedDps{1}=speed; % vector of say 12 speeds
    tc.allDFoF{1}=dfof; % matrix of 12 columns x nRepeats. padded with NaNs for speed with less than max repeats
    tc.meanDFoF{1}=nanmean(dfof,1); % calculate the mean of the columns, ingore nan's
    tc.sdDFoF{1}=nanstd(dfof,1); % calculate the standard deviation of the columns, ingore nan's.
    tc.nDFoF{1}=sum(~isnan(dfof),1); % calculate the Number of non-nan values (=number of trials per direction)
    tc.N=1;
    if ~dpxdIs(tc)
        error('tc should be a dpxd struct');
    end
end