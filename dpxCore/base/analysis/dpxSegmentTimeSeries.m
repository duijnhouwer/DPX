function [Ys,Ts]=dpxSegmentTimeSeries(varargin)
    
    % Cut an array into pieces defined by start and stop moments in
    % seconds.
    % Jacob Duijnhouwer, 2014-08-29
    
    p = inputParser;
    p.addParamValue('timeseries',[],@isnumeric);
    p.addParamValue('timestamps',[],@isnumeric);
    p.addParamValue('starts',[],@isnumeric);
    p.addParamValue('stops',[],@isnumeric);
    p.addParamValue('check','warn',@(x)any(strcmpi('warn','err')));
    p.addParamValue('checkToleranceSamples',0,@isnumeric);
    p.addParamValue('outputTiming','absolute',@(x)any(strcmpi(x,{'relative','absolute'})));
    p.parse(varargin{:});
    %
    if numel(p.Results.starts) ~= numel(p.Results.stops)
        error('Numbers of starts and stops must be equal');
    end
    
    checkTiming(p);
    Ys=cell(1,numel(p.Results.starts));
    from=p.Results.starts;
    to=p.Results.stops;
    if nargout==1
        for i=1:numel(Ys)
            idx=p.Results.timestamps>=from(i) & p.Results.timestamps<to(i);
            Ys{i}=p.Results.timeseries(idx);
        end
    else
        Ts=cell(1,numel(p.Results.starts));
        rel=strcmpi(p.Results.outputTiming,'relative');
        for i=1:numel(Ys)
            idx=p.Results.timestamps>=from(i) & p.Results.timestamps<to(i);
            Ys{i}=p.Results.timeseries(idx);
            Ts{i}=p.Results.timestamps(idx);
            if rel % align the time axis of this segment to from if outputTiming is 'relative'
                Ts{i}=Ts{i}-from(i);
            end
        end
    end
end

% --- HELP FUNCTIONS ------------------------------------------------------

function checkTiming(p)
    % Test 1
    nrStartAfterStop=sum(p.Results.stops-p.Results.starts<0);
    if nrStartAfterStop>0
        error([num2str(nrStartAfterStop) ' of ' num2str(numel(p.Results.starts)) ' defined segment-starts occur after corresponding stops.']);
    end
    % Test 2 
    if numel(p.Results.timeseries)~=numel(p.Results.timestamps)
        error(['number of timestamps (N=' num2str(numel(p.Results.timeseries)) ' does not match timeseries (N=' num2str(numel(p.Results.timestamps)) ')']);
    end
end
