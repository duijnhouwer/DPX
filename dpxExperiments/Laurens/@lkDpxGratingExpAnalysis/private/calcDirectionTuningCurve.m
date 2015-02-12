function tc=calcDirectionTuningCurve(dpxd,cellNr,varargin)
    
    if nargin==1 && strcmp(dpxd,'info')
        tc.per='cell';
        return;
    end
    % This function calculates a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, its output can be plot with the
    % complementary plotDirectionTuningCurve
    % Parse 'options' input
    p=inputParser;
    p.addParamValue('bayesfit',true,@islogical);
        % If true: use the bayesPhysV1 toolkit to fit tuningcurves to the data, and
        % test which is the best model. This will determine if the cell is
        % tuned at all, and if so, if it is direction or orientation selective.
    p.parse(varargin{:});
    
    
    % Split the data according to the direction of the grating.    
    % Ds is the DPXD called 'dpxd' split up in a DPXD per direction (so
    % numel Ds would typically be 8). Ns is an array corrsponding to Ds
    % that contains the N of each DPXD in Ds
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
            % Get the corresponding time axis
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
    tc.sdDFoF{1}=nanstd(dfof,1); % calculate the standard deviation of the columns, ingore nan's.
    tc.nDFoF{1}=sum(~isnan(dfof),1); % calculate the Number of non-nan values (=number of trials per direction)
    tc.N=1;
    if p.Results.bayesfit
        dirDeg=repmat(dirDeg,size(dfof,1),1);
        curvesToTest={'constant','circular_gaussian_180','circular_gaussian_360','direction_selective_circular_gaussian'};
        B=dpxBayesPhysV1('deg',dirDeg(:),'resp',dfof(:),'curvenames',curvesToTest,'unit','dfof');
        tc.dpxBayesPhysV1{1}=B.winnerstr;
        tc.dpxBayesPhysV1x=B.bestCurveX;
        tc.dpxBayesPhysV1y=B.bestCurveY;
    end
    if ~dpxdIs(tc)
        error('tc should be a dpxd struct');
    end
end