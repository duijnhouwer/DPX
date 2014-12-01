function tc=calcDirectionTuningCurve(dpxd,cellNr,varargin)
    % This function calcutes a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, it's output can be plot with the
    % complementary plotDirectionTuningCurve
    %
    % Split the data according to the direction of the grating
    [Ds,Ns]=dpxdSplit(dpxd,'grating_dirDeg');
    % Preallocate the list of directions ...
    dirDeg=NaN(1,numel(Ds));
    % Preallocate the table of responses
    dfof=NaN(max(Ns),numel(Ds)); % rows=trials, cols=directions
    % Construct the response and time fieldnames of this cellNr
    dfofField=['resp_unit' num2str(cellNr,'%.3d') '_dFoF']; % e.g., if cellNr is 1, 'resp_unit001_dFoF'
    timeField=['resp_unit' num2str(cellNr,'%.3d') '_s']; % e.g., if cellNr is 1, 'resp_unit001_s'
    for i=1:numel(Ds) % loop over all directions
        dirDeg(i)=Ds{i}.grating_dirDeg(1); % store this direction in degrees
        for t=1:Ds{i}.N
            % Get the dFoF trace of the entire t'th trial for this direction
            tSeries=Ds{i}.(dfofField){t}; 
            % Get the correspoding time axis
            tAxis=Ds{i}.(timeField){t};
            % Use tAxit to limit trace to the time the stim was on
            from=Ds{i}.grating_onSec(t);
            to=from+Ds{i}.grating_durSec(t);
            tSeries=tSeries(tAxis>=from & tAxis<to);
            % Store the mean of this segment, i.e., reduce trail's response to a single value
            dfof(t,i)=nanmean(tSeries); % nanmean because it ignores NaN's  
        end
    end
    % put the values in the output struct
    tc.dirDeg{1}=dirDeg;
    tc.allDFoF{1}=dfof;
    tc.meanDFoF{1}=nanmean(dfof,1); % calculate the mean of the columns, ingore nan's
    tc.sdDFoF{1}=nanstd(dfof,1); % calculate the standard deviation of the columns, ingore nan's
    tc.nDFoF{1}=sum(~isnan(dfof),1); % calculate the Number of non-nan values (number of trials per direction)
    tc.N=1;
    if ~dpxdIs(tc)
        error('tc should be a dpxd struct');
    end
end