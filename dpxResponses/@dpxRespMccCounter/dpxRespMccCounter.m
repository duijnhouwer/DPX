classdef dpxRespMccCounter < dpxAbstractResp
         
    properties (Access=protected)
        daq;
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
            % DOES NOTHING because
            % DaqCIn(R.daq) takes 25 ms, so cannot call every frame... 
            % So we only store the counter just prior to the beginning of
            % the trial (with accurate timestamp) in myInit.
            %
            % [2015-03-06] Weird, I'm looking into this again and now, on
            % my ASUS n550jv laptop, 
            %   daq=DaqDeviceIndex([],0); 
            %   tic, DaqCIn(daq), toc;
            %   Takes 0.002357 seconds, i.e., 2.5 ms. Did I read this wrong
            %   before? Should be possible to run this on a frame to frame
            %   basis at 100Hz with simple stimuli then?
            % Jacob
        end
    end
end