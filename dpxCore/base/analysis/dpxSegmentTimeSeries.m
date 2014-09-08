function segments=dpxSegmentTimeSeries(varargin)
    
    % Cut an array into pieces defined by start and stop moments in
    % seconds, array is assumed to start at t=0 and have even spacing.
    % Jacob Duijnhouwer, 2014-08-29
    
    p = inputParser;
    p.addParamValue('timeseries',[],@isnumeric);
    p.addParamValue('sampleHz',[],@isnumeric);
    p.addParamValue('starts',[],@isnumeric);
    p.addParamValue('stops',[],@isnumeric);
    p.addParamValue('check','warn',@(x)any(strcmpi('warn','err')));
    p.addParamValue('checkToleranceSamples',0,@isnumeric);
    p.parse(varargin{:});
    %
    if numel(p.Results.starts) ~= numel(p.Results.stops)
        error('Numbers of starts and stops should be equal');
    end
    nrStartAfterStop=sum(p.Results.stops-p.Results.starts<0);
    if nrStartAfterStop>0
        error([num2str(nrStartAfterStop) ' of ' num2str(numel(p.Results.starts)) ' defined segment-starts occur after corresponding stops.']);
    end
    checkTiming(p);
    segments=cell(1,numel(p.Results.starts));
    from=dpxClip(round(p.Results.starts*p.Results.sampleHz),[1 numel(p.Results.timeseries)]);
    to=dpxClip(round(p.Results.stops*p.Results.sampleHz),[1 numel(p.Results.timeseries)]);
    for i=1:numel(segments)
        segments{i}=p.Results.timeseries(from(i):to(i));
    end
end

% --- HELP FUNCTIONS ------------------------------------------------------

function checkTiming(p)
    %warning('Checking of segment timing relative to timeseries not implemented yet.');
end
