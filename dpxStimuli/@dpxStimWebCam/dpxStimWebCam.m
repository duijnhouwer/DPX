classdef dpxStimWebCam < dpxAbstractVisualStim
    
    properties (Access=public)
        idNr@double;
        resolution@char;
        flipLr@logical;
        flipUd@logical;
        quality;
    end
    properties (Access=private)
        cam@webcam;
        tex;
        dstRect;
        srcRect;
    end
    properties (Constant)
        NEARESTNEIGHBOR=0;
        BILINEAR=1;
    end
    methods
        function S=dpxStimWebCam
            S.idNr=1;
            S.wDeg=16;
            S.hDeg=12;
            S.flipLr=true;
            S.flipUd=false;
            S.srcRect=[];
            S.resolution=''; % empty means default to first cell of webcam.AvailableResolutions
            S.quality=S.NEARESTNEIGHBOR;
        end
    end
    methods (Access=protected)
        function myInit(S)
            list=webcamlist();
            if isempty(list)
                error(['[' mfilename '] No webcams detected on this system']);
            elseif numel(list)<S.idNr
                error(['[' mfilename '] requested idNr (' num2str(s.idNr) ') out of range (' num2str(numel(list)) ').']);
            else
                try
                    S.cam=webcam(S.idNr);
                catch me
                    if strcmp(me.identifier,'MATLAB:webcam:connectionExists')
                        sca
                        error(['Webcam ''' list{S.idNr} ''' is already claimed by some process. Execute <a href="matlab:clear classes webcam">clear classes webcam</a> and try running your experiment again']);
                    else
                        rethrow(me);
                    end
                end
                try
                    if isempty(S.resolution)
                        S.resolution=S.cam.AvailableResolutions{1};
                    end
                    S.cam.Resolution=S.resolution;
                catch me
                    if strcmp(me.identifier,'MATLAB:webcam:unrecognizedStringChoice')
                        str=sprintf('%s, ',S.cam.AvailableResolutions{:});
                        str(end-1:end)=[];
                        error('a:b','resolution for %s should be one of %s.\n\tOR leave empty ('''') to default to %s.',S.cam.Name,str,S.cam.AvailableResolutions{1});
                    else
                        rethrow(me);
                    end
                end
            end
            S.dstRect=[S.xPx-S.wPx/2+S.winCntrXYpx(1) S.yPx-S.hPx/2+S.winCntrXYpx(2)]; % lower left
            S.dstRect=[S.dstRect S.dstRect(1)+S.wPx  S.dstRect(2)+S.hPx]; % add top right
            if S.flipLr && S.flipUd
                % This saves having to fliplr and flipud the snapshot matrix
                S.aDeg=S.aDeg+180;
            end
        end
        function myStep(S)
            M=S.cam.snapshot(); % uint8
            if S.flipLr && ~S.flipUd
                M=fliplr(M);
            elseif S.flipUd && ~S.flipLr
                M=flipud(M);
            end
            S.tex=Screen('MakeTexture',S.scrGets.windowPtr,M,S.aDeg,4,0);
        end
        function myDraw(S)
            % left-right or up-down inversion cant be achieved by flipping the src or
            % dst rectangles, Screen sees them as impossible rectangles. In OpenGL this
            % is perfectly possible, and would be much faster than flipping the
            % snapshot matrix obtained in myStep.
            Screen('DrawTexture',S.scrGets.windowPtr,S.tex,S.srcRect,S.dstRect,S.aDeg,S.quality);
        end
        function myClear(S)
            S.cam.delete;
        end
    end
    methods 
        function set.quality(S,value)
             opts=[S.NEARESTNEIGHBOR S.BILINEAR];
            if numel(value)~=1 || ~isnumeric(value) || ~any(value==opts)
                error(['valid values for ''quality'' are:' sprintf(' %d',opts)]);
            end
            S.quality=value;
        end
    end
end
