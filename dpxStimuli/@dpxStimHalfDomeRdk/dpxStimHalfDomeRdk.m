classdef dpxStimHalfDomeRdk < dpxAbstractVisualStim
    
    properties (Access=public)
        nClusters;
        dAdEdeg; % azimuth and elevation offsets of points in cluster
        clusterRadiusDeg;
        dotDiamPx;
        nSteps;
        lutFileName;
        RGBAfrac1;
        RGBAfrac2;
        aziDps;
        eleDps;
        motStartSec; % relative to stim on
        motDurSec;
        freezeFlip; % keep the stimulus frozen for N flips
        invertSteps; % flip RGBAfrac1 and 2 every N dot-steps
    end
    properties (Access=protected)
        pLut; % position lookup table
        aziDeg;
        eleDeg;
        dotCol; % 1s and 2s
        dotAge; % frames
        visibleDots;
        visDotXy;
        visDotCol;
        nDotsPerCluster;
        palette;
        aziDegPerFlip;
        eleDegPerFlip;
        motStartFlip;
        motStopFlip;
        dotStepsToInversion;
    end
    methods (Access=public)
        function S=dpxStimHalfDomeRdk
            % Random dot kinematogram stimulus for in the half-dome
            % projection set-up. (Part of the DPX toolkit)
            %
            % Type: get(dpxStimHalfDomeRdk) for more info
            % Type: edit dpxStimHalfDomeRdk for full info
            %
            % Definitely see also: dpxToolsHalfDomeWarp
            %
            % Jacob Duijnhouwer, 2014-09-23
            S.nClusters=500;
            S.dotDiamPx=4;
            S.nSteps=4;
            S.clusterRadiusDeg=1.4; % 2.9 deg diam in Douglas et al. 2006 (Vis Res "perception of vis mot coherence");
            S.dAdEdeg=[0 sind(45:45:360)*.5 sind(30:30:360) ; 0 cosd(45:45:360)*.5 cosd(30:30:360)];
            S.RGBAfrac1=[0 0 0 1];
            S.RGBAfrac2=[1 1 1 1];
            S.aziDps=60;
            S.eleDps=0;
            S.motStartSec=2; % relative to stimOnSec
            S.motDurSec=4;
            S.freezeFlip=1; % keep the stimulus frozen for N flips, decrease effective framerate
            S.invertSteps=Inf; % flip RGBAfrac1 and 2 every N flips
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.pLut=S.loadHalfdomeWarpObject;
            S.visDotXy=[];
            % create a uniform-density sphere of nClusters dots
            [S.aziDeg, S.eleDeg, S.dotAge]=S.getFreshClusters(S.nClusters,S.nSteps);
            % Xreate an array with the color group number (1 or 2) for all
            % dots, clusters (cols) x dotspercluster (rows);
            S.dotCol=repmat(round(S.RND.rand(1,S.nClusters))+1,S.nDotsPerCluster,1);
            % Make this table a row, so that dots of the same clusters are
            % next to each other
            S.dotCol=S.dotCol(:)';
            % Make the palette into which the dotCol numbers are indices
            S.palette=[S.RGBAfrac1(:) S.RGBAfrac2(:)]*S.scrGets.whiteIdx;
            % Calculate the rotation rates
            S.aziDegPerFlip=S.aziDps/S.scrGets.measuredFrameRate;
            S.eleDegPerFlip=S.eleDps/S.scrGets.measuredFrameRate;
            S.motStartFlip=round(S.motStartSec*S.scrGets.measuredFrameRate);
            S.motStopFlip=S.motStartFlip+S.motDurSec*S.scrGets.measuredFrameRate;
            S.dAdEdeg=S.dAdEdeg*S.clusterRadiusDeg;
            S.dotStepsToInversion=S.invertSteps;
        end
        function myDraw(S)
            if ~S.visible || S.nClusters==0
                return;
            end
            cols=S.palette(:,S.visDotCol);
            Screen('DrawDots',S.scrGets.windowPtr,S.visDotXy,S.dotDiamPx,cols,[0 0],1);
        end
        function myStep(S)
            % 0: is this a frozen frame (framerate reduction)
            frozen=mod(S.stepCounter-S.motStartFlip,S.freezeFlip)>0;
            % 1: if in motion interval update the positions            
            if S.stepCounter>S.motStartFlip && S.stepCounter<=S.motStopFlip
                if ~frozen
                    if S.aziDegPerFlip>0
                        S.aziDeg=S.aziDeg+S.aziDegPerFlip*S.freezeFlip;
                        S.aziDeg(S.aziDeg>135)=S.aziDeg(S.aziDeg>135)-270;
                    elseif S.aziDegPerFlip<0
                        S.aziDeg=S.aziDeg+S.aziDegPerFlip*S.freezeFlip;
                        S.aziDeg(S.aziDeg<-135)=S.aziDeg(S.aziDeg<-135)+270;
                    end
                    if S.eleDegPerFlip>0
                        S.eleDeg=S.eleDeg+S.eleDegPerFlip*S.freezeFlip;
                        S.eleDeg(S.eleDeg>80)=S.eleDeg(S.eleDeg>80)-160;
                    elseif S.eleDegPerFlip<0
                        S.eleDeg=S.eleDeg+S.eleDegPerFlip*S.freezeFlip;
                        S.eleDeg(S.eleDeg<-80)=S.eleDeg(S.eleDeg<-80)+160;
                    end
                end
            end
            
            % 2: update lifetime, replace expired points
            if S.nSteps<Inf && ~frozen
                S.dotAge=S.dotAge+1;
                expired=S.dotAge>S.nSteps;
                [S.aziDeg(expired), S.eleDeg(expired)]=S.getFreshClusters(sum(expired),S.nSteps);
                S.dotAge(expired)=0;
            end
            % 3: invert the contrast
            if S.invertSteps<Inf && ~frozen
                S.dotStepsToInversion=S.dotStepsToInversion-1;
                if S.dotStepsToInversion==0
                    S.palette=[S.palette(:,2) S.palette(:,1)];
                    S.dotStepsToInversion=S.invertSteps;
                end
            end     
            % 4: convert azi-ele deg to x-y pix
            % format the ele and azi coordinates lists of all clusters
            centerAzi=S.aziDeg(:)'; %mod(S.aziDeg(:)',360);
            centerEle=S.eleDeg(:)';
            % See which of the centers fall within the panorama
            [~, vis]=S.pLut.getXYpix(centerAzi,centerEle);
            col=repmat(S.dotCol(vis),S.nDotsPerCluster,1);
            azi=repmat(centerAzi(vis),S.nDotsPerCluster,1);
            ele=repmat(centerEle(vis),S.nDotsPerCluster,1);
            col=col(:)';
            azi=azi(:)';
            ele=ele(:)';
            dAzi=repmat(S.dAdEdeg(1,:),1,numel(vis));
            dEle=repmat(S.dAdEdeg(2,:),1,numel(vis));
            azi=azi+dAzi(:)';
            ele=ele+dEle(:)';
            [S.visDotXy, S.visibleDots]=S.pLut.getXYpix(azi,ele);
            S.visDotCol=col(S.visibleDots);
        end
        function myClear(S)
            S.pLut=[];
        end
        function [aziDeg,eleDeg,dotAge]=getFreshClusters(S,N,maxSteps)
            aziDeg=S.RND.rand(1,N)*270-135; % angle in cross-section plane orthogonal to vertical axis, leave out back quadrant to save computations (20160706)
            eleDeg=acosd(S.RND.rand(1,N)*1.5-1)-90; % angle of cluster center point vector with vertical axis, -90 to make equator at 0 elevation
            % Before 2016-07-08 the entire elevation angle was used. Like
            % this: 
            %   eleDeg=acosd(S.RND.rand(1,N)*2-1)-90;
            % Now, the bottom 25% is left out. This allows to reduce the
            % nClusters by another factor 0.75 to optimize the stimulus
            % without changing what it looks like in our halfdome at all.
            if nargout>2
                dotAge=floor(S.RND.rand(1,N)*maxSteps+1);
            end
        end
        function W=loadHalfdomeWarpObject(S)
            % The halfdomeWarpObject is an object of the
            % dpxToolsHalfDomeWarp class that should be used to measure the
            % x-y/azi-deg relation of the projection. It also has
            % functionality to create a lookup table from these
            % meausurements and has a function (getXYpix) that converts
            % arrays of azimuth and elevation values from degrees to x-y
            % position in pixels.
            % See also: dpxToolsHalfDomeWarp
            try
                tmp=load(S.lutFileName);
            catch
                error(['Could not load halfdomeWarpObject-file ''' S.lutFileName '''. If you have one for your setup make sure it''s on your matlab path. Otherwise, you can create one using ''dpxToolsHalfDomeWarp''.']);
            end
            fn=fieldnames(tmp);
            if numel(fn)>1
                error(['The file ''' S.lutFileName ''' contained multiple variables but a valid halfdomeWarpObject-file contains only one, a dpxToolsHalfDomeWarp-object (of any name).']);
            elseif ~isa(tmp.(fn{1}),'dpxToolsHalfDomeWarp')
                error(['The variable ''' fn{1} ''' in file ''' S.lutFileName ''' is of class ''' class(tmp.(fn{1})) ''' but should be of class ''dpxToolsHalfDomeWarp''.']);
            end
            W=tmp.(fn{1});
        end
    end
    methods
        function set.dAdEdeg(S,value)
            if ~isnumeric(value) || size(value,1)~=2
                error('dAdEdeg should be an 2xN matrix of N dots per cluster (dAzi,dEle) values in degrees');
            else
                S.dAdEdeg=value;
                S.nDotsPerCluster=size(value,2); %#ok<MCSUP>
            end
        end
        function set.RGBAfrac1(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RGBAfrac1 should be a ' str]);
            else
                S.RGBAfrac1=value;
            end
        end
        function set.RGBAfrac2(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RGBAfrac2 should be a ' str]);
            else
                S.RGBAfrac2=value;
            end
        end   
        function set.aziDps(S,value)
            S.aziDps=value;
        end
        function set.eleDps(S,value)
            %if value~=0
            %    error('eleDps is just a placeholder, must be zero. email Jacob if you need vertical motion.');
            %end
            S.eleDps=value;
        end
        function set.dotDiamPx(S,value)
            if ~isnumeric(value) || value<=0
                error('dotDiamPx must be a positive number');
            end
            S.dotDiamPx=value;
        end
    end
end


