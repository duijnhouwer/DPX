classdef dpxRespContiMouse < dpxAbstractResp
    
    properties (Access=public)
        mouseId=[];
        defaultX;
        defaultY;
    end
    properties (Access=protected)
        nrTotalSamples;
        nrSamplesTaken;
        startTime;
    end
    methods (Access=public)
        function R=dpxRespContiMouse
            % R=dpxRespContiMouse
            % Record mouse position on each frame (Conti-nuously). Under
            % linux, a dedicated mouse can be used by setting property
            % 'mouseId'. Setting mouseId to some impossible value like -1
            % will trigger a mouse selection menu on the command line.
            % EXAMPLE:
            %    M=dpxRespContiMouse;
            %    M.mouseId=-1
            %
        end
    end
    methods (Access=protected)
        function myInit(R)
            HideCursor;
            R.nrTotalSamples=floor(R.allowUntilNrFlips-R.allowAfterNrFlips);
            R.nrSamplesTaken=0;
            R.resp.dxPx=nan(1,R.nrTotalSamples);
            R.resp.dyPx=nan(1,R.nrTotalSamples);
            R.resp.tSec=nan(1,R.nrTotalSamples);
            R.defaultX=round(R.scrGets.widPx/2);
            R.defaultY=round(R.scrGets.heiPx/2);
        end
        function myGetResponse(R)
            [x,y] = GetMouse(R.scrGets.windowPtr, R.mouseId); % R.mouseId is ignored on platforms other than Linux
            t=GetSecs;
            SetMouse(R.defaultX, R.defaultY);
            R.nrSamplesTaken=R.nrSamplesTaken+1;
            R.resp.dxPx(R.nrSamplesTaken)=x-R.defaultX;
            R.resp.dyPx(R.nrSamplesTaken)=y-R.defaultY;
            R.resp.tSec(R.nrSamplesTaken)=t;
            if R.nrSamplesTaken>=R.nrTotalSamples-1
                % Flag dpxCoreCondition that the response is complete and
                % can be appended to the output structure. Subtracting 1
                % from nrTotalSamples serve to guarantee that given is set
                % in the face of rounding errors. Last sample will be NaN.
                R.given=true;
            end
        end
    end
    methods
        function set.mouseId(R,value)
            if ~isnumeric(value)
                error('mouseId should be a number');
            end
            if ~IsLinux
                dpxDispFancy('SELECTING BETWEEN MULTIPLE MICE ONLY WORKS ON LINUX','-',5,2);
            end
            [mouseIndices, productNames]= GetMouseIndices;
            if any(mouseIndices==value)
                R.mouseId=value;
            else
                R.mouseId=selectAndTestMouse(mouseIndices, productNames);
            end
        end
    end
end

% --- HELP FUNCTIONS ------------------------------------------------------

function mouseId=selectAndTestMouse(mouseIndices, productNames)
    N=numel(productNames);
    dpxDispFancy('Mice available on this system',':',2);
    for i=1:N
        disp([':: ' num2str(mouseIndices(i),'%.2d') ' : ' productNames{i}]);
    end
    disp(':: Which mouse should dpxRespContiMouse use? (If two or more share a productname, try the first and test ...)');
    selec=[];
    while isempty(selec)
        selec=str2double(input([':: Type ' sprintf('%d, ',mouseIndices(1:end-1)) 'or ' num2str(mouseIndices(end)) ' and press Enter >> '],'s'));
        selec=intersect(selec,mouseIndices);
    end
    mouseId=selec;
    dpxDispFancy(['Testing mouseId ' num2str(mouseId) ' (' productNames{mouseIndices==selec} ')'],':',2);
    firsttime=true;
    while ~dpxGetEscapeKey
        [x,y] = GetMouse(0, mouseId); % mouseId is ignored on platforms other than Linux
        if firsttime, firsttime=false;
        else fprintf(repmat('\b',1,numel(str)));
        end
        str=sprintf(':: X: %.4d Y: %.4d (Press Escape when done.)\n',x,y);
        fprintf('%s',str);
    end
end