function tc=calcDirectionTuningCurve(dpxd,cellNr,varargin)
 
    warning('a:b','NOTE WE ARE SIMPLY TAKING THE DFOF OVER THE WHOLE TRIAL NOW!!!!!\nIT IS IMPORTANT TO CHANGE THIS TO ONLY THE STIM-ON TIME ASAP!!!');
            
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
        dirDeg(i)=Ds{i}.grating_dirDeg(1);
        for t=1:Ds{i}.N
            % Get the dFoF trace of the entire t'th trial for this direction
            tSeries=Ds{i}.(dfofField){t}; 
            % Get the correspoding time axis
            tAxis=Ds{i}.(timeField){t};
            % Limit to the time the stim was on
            from=Ds{i}.grating_onSec(t);
            to=from+Ds{i}.grating_durSec(t);
            tSeries=tSeries(tAxis>=from & tAxis<to);
            % Store the mean of this segment, reduce trail's response to a single value
            dfof(t,i)=nanmean(tSeries); % nanmean because it ignores NaN's  
        end
    end
    % put the values in the output struct
    tc.dirDeg=dirDeg;
    tc.allDFoF=dfof;
    tc.meanDFoF=nanmean(dfof,1); % calculate the mean of the columns, ingore nan's
    tc.sdDFoF=nanstd(dfof,1); % calculate the standard deviation of the columns, ingore nan's
    tc.nDFoF=sum(~isnan(dfof),1); % calculate the Number of non-nan values (number of trials per direction)
end