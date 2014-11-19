function tc=calcDirectionTuningCurve(data,cellNr)
 
    warning('a:b','NOTE WE ARE SIMPLY TAKING THE DFOF OVER THE WHOLE TRIAL NOW!!!!!\nIT IS IMPORTANT TO CHANGE THIS TO ONLY THE STIM-ON TIME ASAP!!!');
            
    % Split the data according to the direction of the grating
    D=dpxdSplit(data,'grating_dirDeg');
    % Preallocate the list of directions ...
    dirDeg=NaN(1,numel(D));
    % ... and mean responses. These will be our x and y axis value
    meanDFoF=NaN(1,numel(D));
    % Make the response field name of this cellNr
    resp_field=['resp_unit' num2str(cellNr,'%.3d') '_dFoF'];
    for i=1:numel(D)
        dirDeg(i)=D{i}.grating_dirDeg(1);
        trialMeanDFoF=NaN(1,D{i}.N);
        for t=1:D{i}.N
            % tSeries = this trials dFoF time series; % Note: the
            % STRUCT.(STRING) notation makes it possible to reference the
            % fields of structure STRUCT with variables STRING that contain
            % the fieldname as a string
            timeSeries=D{i}.(resp_field){t};
            % Store the mean dFoF for this trial
            trialMeanDFoF(t)=mean(timeSeries);   
        end
        meanDFoF(i)=nanmean(trialMeanDFoF); % get the mean over the trials
    end
    % put the x and y axis values in the output struct
    tc.dirDeg=dirDeg;
    tc.meanDFoF=meanDFoF;
end