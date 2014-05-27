classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxStimRotCylinder < dpxBasicStim
    
    properties (Access=public)
        dotsPerSqrDeg=10;
        rotSpeedDeg=120;
        disparityFrac=1;
        sideToDraw='front'; % 'front','back','both'
        dotRGBA1frac=[1 1 1 1];
        dotRGBA2frac=[0 0 0 1];
        axis='hori';
        wDeg=15;
        hDeg=10;
        dotDiamDeg=.15;
        stereoLumCorr=1;
    end
    properties (Access=private)
        nDots;
        xCenterPx;
        yCenterPx;
        zCenterPx;
        rotSpeedRad;
        dotRGBA1;
        dotRGBA2;
        depthPx;
        hordisp;
        dAz;
        onFlip;
        offFlip;
        flipCounter;
        stimEyeDistPx;
        dotDiamPx;
        wPx;
        hPx;
        Z; R;
        Az;
        Y;
        X;
        XYZ;
        scrCenterXYpx;
        leftEyeColor;
        rightEyeColor;
    end
    methods (Access='public')
        function S=dpxStimRotCylinder
        end
        function init(S,physScrVals)
            if nargin~=2 || ~isstruct(physScrVals)
                error('Needs get(dpxStimWindow-object) struct');
            end
            if isempty(physScrVals.windowPtr)
                error('dpxStimWindow object has not been initialized');
            end
            S.nDots = max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            S.onFlip = S.onSecs * physScrVals.measuredFrameRate;
            S.offFlip = (S.onSecs + S.durSecs) * physScrVals.measuredFrameRate;
            S.flipCounter=0;
            S.depthPx=round(S.yDeg*physScrVals.deg2px);
            S.stimEyeDistPx=physScrVals.distPx-S.zCenterPx;
            S.xCenterPx=round(S.xDeg*physScrVals.deg2px);
            S.zCenterPx=round(S.zDeg*physScrVals.deg2px);
            S.rotSpeedRad=S.rotSpeedDeg/180*pi;
            S.dotDiamPx=max(1,S.dotDiamDeg*physScrVals.deg2px);
            S.dotRGBA1=S.dotRGBA1frac*physScrVals.whiteIdx;
            S.dotRGBA2=S.dotRGBA2frac*physScrVals.whiteIdx;
            S.wPx=round(S.wDeg*physScrVals.deg2px);
            S.hPx=round(S.hDeg*physScrVals.deg2px);
            S.scrCenterXYpx=[physScrVals.widPx/2 physScrVals.heiPx/2];
        
            %         C.DotFills=S.Cyl(i).DotFills;
            %         C.DotColorBlack=0;
            %         C.DotColorWhite=255;
            %         C.ColorCoordinationStr=S.Cyl(i).ColorCoordination;
            %         C.Axis=S.Cyl(i).Axis;
            [S.leftEyeColor,S.rightEyeColor]=getColors(S.nDots,[S.dotRGBA1(:) S.dotRGBA2(:)],S.stereoLumCorr);
            if strcmpi(S.axis,'hori')
                S.X=round(S.xCenterPx-S.wPx/2+S.wPx*rand(1,S.nDots));
                S.R=S.hPx/2; %Y is going in the screen
                S.Az=2*pi*rand(1,S.nDots);
                S.Y=round(S.depthPx+S.disparityFrac*S.R*cos(S.Az));
                S.Z=round(-S.depthPx+S.R*sin(S.Az));
                S.XYZ=[S.X;S.Y;S.Z];
            elseif strcmpi(S.axis,'vert')
                S.Z=round(S.zCenterPx-S.wPx/2+S.wPx*rand(1,S.nDots));
                S.R=S.hPx(2)/2;
                S.Az=2*pi*rand(1,S.nDots);
                S.Y=round(S.depthPx+S.disparityFrac*S.R*cos(S.Az));
                S.X=round(S.xPx+S.R*sin(S.Az));
                S.XYZ=[S.X;S.Y;S.Z];
            else
                error(['Unknown axis option: ' S.axis]);
            end
            S.dAz=S.rotSpeedRad/physScrVals.measuredFrameRate;
            S.hordisp=getHorizontalDisparity(physScrVals,S.XYZ);
            
        end
        function draw(S,windowPtr)
            for buffer=0:1
                if buffer==0 % left eye
                    dispfieldstr='lX00'; % disparity field string
                    dotColor=S.leftEyeColor;
                elseif buffer==1 % right eye
                    dispfieldstr='rX00'; % disparity field string
                    dotColor=S.rightEyeColor;
                end
                Screen('SelectStereoDrawBuffer', windowPtr, buffer);
                idx=getDotsOnSide('whichside',S.sideToDraw,'dotangles',S.Az);
                Screen('DrawDots', windowPtr,S.XYZ([1 3],idx)+S.hordisp.(dispfieldstr)([1 3],idx),S.dotDiamPx, dotColor(:,idx), S.scrCenterXYpx,1);
            end
        end
        function step(S,physScrVals)
            if nargin~=2 || ~isstruct(physScrVals)
                error('Needs get(dpxStimWindow-object) struct');
            end
            S.Az=S.Az+S.dAz;
            if strcmpi(S.axis,'hori')
                S.X = S.X;
                S.Y = round(S.depthPx+ S.disparityFrac *S.R*cos(S.Az));
                S.Z = round(-S.depthPx+S.R*sin(S.Az));
                S.XYZ=[S.X; S.Y; S.Z];
            elseif strcmpi(S.axis,'vert')
                S.Z = S.Z;
                S.Y = round(S.depthPx+S.disparityFrac*S.R*cos(S.Az));
                S.X = round(S.xPx+S.R*sin(S.Az));
                S.XYZ=[S.X; S.Y; S.Z];
            else
                error(['Unknown axis option: ' S.axis]);
            end
            S.hordisp=getHorizontalDisparity(physScrVals,S.XYZ);
            %S=updateDotColor(physscr,S);
        end
    end
    methods
        function set.stereoLumCorr(S,value)
            if value<-1 || value>1
                error('stereoLumCorr should be correlation between -1 and 1.');
            end
            S.stereoLumCorr=value;
        end
    end
end



% ------------------------------------------------------------------------

function hordisp=getHorizontalDisparity(physScr,XYZ)
    nDots=size(XYZ,2);
    leV=XYZ-physScr.leftEyeXYZpx*ones(1,nDots);
    reV=XYZ-physScr.rightEyeXYZpx*ones(1,nDots);
    ceV=XYZ-physScr.cyclopEyeXYZpx*ones(1,nDots);
    leC=-physScr.leftEyeXYZpx(2,:)*ones(1,nDots)./leV(2,:);
    reC=-physScr.rightEyeXYZpx(2,:)*ones(1,nDots)./reV(2,:);
    ceC=-physScr.cyclopEyeXYZpx(2,:)*ones(1,nDots)./ceV(2,:);
    lepXYZ=round(physScr.leftEyeXYZpx*ones(1,nDots) + [leC; leC; leC].*leV );
    repXYZ=round(physScr.rightEyeXYZpx*ones(1,nDots) + [reC; reC; reC].*reV );
    cepXYZ=round(physScr.cyclopEyeXYZpx*ones(1,nDots) + [ceC; ceC; ceC].*ceV );
    hordisp.lX00=cepXYZ-lepXYZ;
    hordisp.rX00=cepXYZ-repXYZ;
    % no perspective, only horizontal disparity component
    hordisp.lX00(2:3,:)=0;
    hordisp.rX00(2:3,:)=0;
end

function idx=getDotsOnSide(varargin)
    p=inputParser;
    p.addParamValue('whichside','both',@(x)any(strcmpi(x,{'both','back','front','none'})));
    p.addParamValue('dotangles',0,@(x)isnumeric(x));
    p.parse(varargin{:});
    switch p.Results.whichside
        case 'both'
            idx=true(1,numel(p.Results.dotangles));
        case 'back'
            idx=cos(p.Results.dotangles)>0;
        case 'front'
            idx=cos(p.Results.dotangles)<0;
        case 'none'
            idx=false(1,numel(p.Results.dotangles));
        otherwise
            error(['Unknown option for drawSidesStr: ' p.Results.whichside])
    end
end


function [leDotCols,reDotCols]=getColors(nDots,cols,correl)
    if size(cols,1)~=4
        error('cols should be 4xN matrix for N RGBA colors');
    end
    if nargin==2 || isempty(correl)
        correl=1;
    end
    nrColors=size(cols,2);
    if nrColors==1
        dotcols=repmat(cols,1,nDots);
        leDotCols=dotcols;
        reDotCols=dotcols;
    elseif nrColors==2
        nomcol=rand(1,nDots)<.5;
        cols1=repmat(cols(:,1),1,nDots);
        cols2=repmat(cols(:,2),1,nDots);
        if correl==1
            dotcols=repmat(cols(:,1),1,nDots);
            dotcols(:,nomcol)=repmat(cols(:,2),1,sum(nomcol));
            leDotCols=dotcols;
            reDotCols=dotcols;
        elseif correl==-1
            leDotCols=repmat(cols(:,1),1,nDots);
            leDotCols(:,nomcol)=repmat(cols(:,2),1,sum(nomcol));
            reDotCols=repmat(cols(:,2),1,nDots);
            reDotCols(:,nomcol)=repmat(cols(:,1),1,sum(nomcol));
        else
            error(['Correlation other than 1 and -1 not implemented yet.']);
        end
    elseif nrColors>2
        error('Current implementation designed for max 2 colors');
    else
        error(['Illegal number of colors: ' num2str(nrColors) ]);
    end
end