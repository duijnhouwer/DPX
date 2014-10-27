classdef dpxRespMccCounter < dpxAbstractResp
         
    properties (Access=protected)
        daq;
        nrTotalSamples;
        nrSamplesTaken;
    end
    methods (Access=protected)
        function myInit(R)
            % Get and store the internal counter of Measurement computing
            % USB-1208FS, connected on pins 20 and 17
            R.daq=DaqDeviceIndex([],0);
            R.resp.ctr=DaqCIn(R.daq);
            R.resp.tSec=GetSecs;
        end
        function myGetResponse(R)
            % DaqCIn(R.daq) takes 25 ms, so cannot call every frame... 
            % So we only store the counter just prior to the beginning of
            % the trial (with accurate timestamp)
        end
    end
end