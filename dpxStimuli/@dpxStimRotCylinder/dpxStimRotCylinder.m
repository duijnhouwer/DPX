classdef dpxStimRotCylinder < dpxAbstractStim
    
    properties (Access=public)
        dotsPerSqrDeg=10;
        rotSpeedDeg=120;
        disparityFrac=1;
        sideToDraw='front'; % 'front','back','both'
        dotRGBA1frac=[1 1 1 1];
        dotRGBA2frac=[0 0 0 1];
        axis='hori';
        dotDiamDeg=.15;
        stereoLumCorr=1;
        fogFrac;
        dotDiamScaleFrac;
    end
    properties (Access=private)
        nDots;
        xCenterPx;
        yCenterPx;
        zCenterPx;
        dotRGBA1;
        dotRGBA2;
        depthPx;
        hordisp;
        dAz;
        stimEyeDistPx;
        dotDiamPx;
        Az;
        XYZ;
        leftEyeColor;
        rightEyeColor;
        fog;
        dotDiamScale;
    end
    methods (Access='public')
        function S=dpxStimRotCylinder
            S.wDeg=15;
            S.hDeg=10;
            S.fogFrac=0;
            S.dotDiamScaleFrac=0;
        end
    end
    methods (Access='protected')
        function myInit(S)
            S.nDots = max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            S.depthPx=round(S.yDeg*S.scrGets.deg2px);
            S.stimEyeDistPx=S.scrGets.distPx-S.zCenterPx;
            S.xCenterPx=round(S.xDeg*S.scrGets.deg2px);
            S.zCenterPx=round(S.zDeg*S.scrGets.deg2px);
            S.dotDiamPx=S.dotDiamDeg*S.scrGets.deg2px;
            [S.dotDiamPx,wasoutofrange]=dpxClip(S.dotDiamDeg*S.scrGets.deg2px,S.scrGets.limits.GL_ALIASED_POINT_SIZE_RANGE);
            if wasoutofrange
                S.dotDiamDeg=S.dotDiamPx/S.scrGets.deg2px;
                warning(['S.dotDiamDeg was out of range for this computer, capped at the limit of ' num2str(S.dotDiamDeg) ' degrees.']);
            end
            S.dotRGBA1=S.dotRGBA1frac*S.scrGets.whiteIdx;
            S.dotRGBA2=S.dotRGBA2frac*S.scrGets.whiteIdx;
            S.winCntrXYpx=[S.scrGets.widPx/2 S.scrGets.heiPx/2];
            [S.leftEyeColor,S.rightEyeColor]=getColors(S.nDots,[S.dotRGBA1(:) S.dotRGBA2(:)],S.stereoLumCorr);
            if strcmpi(S.axis,'hori')
                x=round(S.xCenterPx-S.wPx/2+S.wPx*rand(1,S.nDots));
                r=S.hPx/2; %Y is going in the screen
                S.Az=2*pi*rand(1,S.nDots);
                y=round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                z=round(-S.depthPx+r*sin(S.Az));
                S.XYZ=[x;y;z];
            elseif strcmpi(S.axis,'horisphere')
                x=round(S.xCenterPx-S.wPx/2+S.wPx*rand(1,S.nDots));
                r=S.hPx/2; %Y is going in the screen
                S.Az=2*pi*rand(1,S.nDots);
                y=round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                yScale=sin( acos(x/S.wPx*2) );
                y=y.*yScale;
                z=round(-S.depthPx+r*sin(S.Az));
                z=z.*yScale;
                S.XYZ=[x;y;z];
            elseif strcmpi(S.axis,'vert')
                z=round(S.zCenterPx-S.wPx/2+S.wPx*rand(1,S.nDots));
                r=S.wPx/2;
                S.Az=2*pi*rand(1,S.nDots);
                y=round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                x=round(S.xPx+r*sin(S.Az));
                S.XYZ=[x;y;z];
            elseif strcmpi(S.axis,'vertsphere')
                z=round(S.xCenterPx-S.wPx/2+S.wPx*rand(1,S.nDots));
                r=S.wPx/2; %Y is going in the screen
                S.Az=2*pi*rand(1,S.nDots);
                y=round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                yScale=sin( acos(z/S.wPx*2) );
                y=y.*yScale;
                x=round(-S.depthPx+r*sin(S.Az));
                x=x.*yScale;
                S.XYZ=[x;y;z];
            else
                error(['Unknown axis option: ' S.axis]);
            end
            S.dAz=S.rotSpeedDeg/180*pi/S.scrGets.measuredFrameRate;
        end
        function myDraw(S)
            wPtr=S.scrGets.windowPtr;
            for buffer=0:1
                if buffer==0 % left eye
                    dispfieldstr='lX00'; % disparity field string
                    dotColor=S.leftEyeColor;
                elseif buffer==1 % right eye
                    dispfieldstr='rX00'; % disparity field string
                    dotColor=S.rightEyeColor;
                end
                Screen('SelectStereoDrawBuffer', wPtr, buffer);
                % Only draw the dots on teh sides we want to see
                idx=getDotsOnSide('whichside',S.sideToDraw,'dotangles',S.Az);
                % apply the fog
                cols=dotColor;
                cols(4,:)=cols(4,:).*S.fog;
                % apply the dot-diam scaling
                diam=S.dotDiamScale*S.dotDiamPx;
                idx=idx & diam>=1;
                % Draw the dots
                if sum(idx)>0
                    Screen('DrawDots', wPtr,S.XYZ([1 3],idx)+S.hordisp.(dispfieldstr)([1 3],idx),diam(idx),cols(:,idx), S.winCntrXYpx,1);
                end
            end
        end
        function myStep(S)
            S.Az=S.Az+S.dAz;
            if strcmpi(S.axis,'hori')
                r = S.hPx/2;
                y = round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                z = round(-S.depthPx+r*sin(S.Az));
                S.XYZ=[S.XYZ(1,:);y;z];
            elseif strcmpi(S.axis,'vert')
                r = S.wPx/2;
                y = round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                x = round(S.xPx+r*sin(S.Az));
                S.XYZ=[x;y;S.XYZ(3,:)];
            elseif strcmpi(S.axis,'horisphere')
                r=S.hPx/2; %Y is going in the screen
                y=round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                taper=sin( acos(S.XYZ(1,:)/S.wPx*2) );
                y=y.*taper;
                z=round(-S.depthPx+r*sin(S.Az));
                z=z.*taper;
                S.XYZ=[S.XYZ(1,:);y;z];
            elseif strcmpi(S.axis,'vertsphere')
                r=S.wPx/2; %Y is going in the screen
                y=round(S.depthPx+S.disparityFrac*r*cos(S.Az));
                taper=sin( acos(S.XYZ(3,:)/S.hPx*2) );
                y=y.*taper;
                x=round(-S.depthPx+r*sin(S.Az));
                x=x.*taper;
                S.XYZ=[x;y;S.XYZ(3,:)];
            else
                %error(['Unknown axis option: ' S.axis]);
            end
            S.hordisp=getHorizontalDisparity(S.scrGets,S.XYZ);
            S.fog=1-(sign(S.fogFrac)*cos(S.Az)+1)/2*abs(S.fogFrac);
            S.dotDiamScale=1-(sign(S.dotDiamScaleFrac)*cos(S.Az)+1)/2*abs(S.dotDiamScaleFrac);
        end
    end
    methods
        function set.stereoLumCorr(S,value)
            if value<-1 || value>1
                error('stereoLumCorr should be correlation between -1 and 1.');
            end
            S.stereoLumCorr=value;
        end
        function set.fogFrac(S,value)
            if value<-1 || value>1
                error('fogFrac should be a signed fraction between -1 and 1.');
            end
            S.fogFrac=value;
        end
         function set.dotDiamScaleFrac(S,value)
            if value<-1 || value>1
                error('dotDiamScaleFrac should be a signed fraction between -1 and 1.');
            end
            S.dotDiamScaleFrac=value;
        end
    end
end



% ------------------------------------------------------------------------

function hordisp=getHorizontalDisparity(scr,XYZ)
    nDots=size(XYZ,2);
    leV=XYZ-scr.leftEyeXYZpx*ones(1,nDots);
    reV=XYZ-scr.rightEyeXYZpx*ones(1,nDots);
    ceV=XYZ-scr.cyclopEyeXYZpx*ones(1,nDots);
    leC=-scr.leftEyeXYZpx(2,:)*ones(1,nDots)./leV(2,:);
    reC=-scr.rightEyeXYZpx(2,:)*ones(1,nDots)./reV(2,:);
    ceC=-scr.cyclopEyeXYZpx(2,:)*ones(1,nDots)./ceV(2,:);
    lepXYZ=round(scr.leftEyeXYZpx*ones(1,nDots) + [leC; leC; leC].*leV );
    repXYZ=round(scr.rightEyeXYZpx*ones(1,nDots) + [reC; reC; reC].*reV );
    cepXYZ=round(scr.cyclopEyeXYZpx*ones(1,nDots) + [ceC; ceC; ceC].*ceV );
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
            error('Correlations other than 1 and -1 not implemented yet.');
        end
    elseif nrColors>2
        error('Current implementation designed for max 2 colors');
    else
        error(['Illegal number of colors: ' num2str(nrColors) ]);
    end
end