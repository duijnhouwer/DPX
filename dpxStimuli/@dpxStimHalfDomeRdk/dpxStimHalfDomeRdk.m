classdef dpxStimHalfDomeRdk < dpxBasicStim
    
    properties (Access=public)
        nClusters;
        dAdEdeg; % azimuth and elevation offsets of points in cluster
        dotDiamPx;
        nSteps;
        lutFileName='halfDomeLUT.mat';
        RBGAfrac1;
        RBGAfrac2;
    end
    properties (Access=protected)
        LUT;
        aziDeg;
        eleDeg;
        dotCol; % 1s and 2s
        dotAge; % frames
        visibleDots;
        visDotXy;
        visDotCol;
        nDotsPerCluster;
        palette;
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
            S.dotDiamPx=2;
            S.nSteps=4;
            S.dAdEdeg=[0 sind(45:45:360)*.25 sind(30:30:360)*.5 ; 0 cosd(45:45:360)*.25 cosd(30:30:360)*.5];
            S.RBGAfrac1=[0 0 0 1];
            S.RBGAfrac2=[1 1 1 1];
        end
    end
    methods (Access=protected)
        function myInit(S)
            S.LUT=S.loadHalfdomeWarpObject;
            S.visDotXy=[];
            % create a uniform-density sphere of nClusters dots
            [S.aziDeg, S.eleDeg, S.dotAge]=S.getFreshClusters(S.nClusters,S.nSteps);
            % Xreate an array with the color group number (1 or 2) for all
            % dots, clusters (cols) x dotspercluster (rows);
            S.dotCol=repmat(round(rand(1,S.nClusters))+1,S.nDotsPerCluster,1);
            % Make this table a row, so that dots of the same clusters are
            % next to each other
            S.dotCol=S.dotCol(:)';
            % Make the paletter into which the dotCol numbers are indices
            S.palette=[S.RBGAfrac1(:) S.RBGAfrac2(:)]*S.scrGets.whiteIdx;        
        end
        function myDraw(S)
            cols=S.palette(:,S.visDotCol);
            Screen('DrawDots',S.scrGets.windowPtr,S.visDotXy,S.dotDiamPx,cols,[0 0],2);
        end
        function myStep(S)
            % 1: update the positions
            S.aziDeg=S.aziDeg+.1;
            % 2: update lifetime, replace expired points
            if S.nSteps<Inf
                S.dotAge=S.dotAge+1;
                expired=S.dotAge>S.nSteps;
                [S.aziDeg(expired), S.eleDeg(expired)]=S.getFreshClusters(sum(expired),S.nSteps);
                S.dotAge(expired)=0;
            end
            % 3: convert azi-ele deg to x-y pix
            % format the ele and azi coordinates lists of all clusters
            centerAzi=mod(S.aziDeg(:)',360)-180;
            centerEle=S.eleDeg(:)';
            % See which of the centers fall within the panorama
            [~, vis]=S.LUT.getXYpix(centerAzi,centerEle);
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
            [S.visDotXy, S.visibleDots]=S.LUT.getXYpix(azi,ele);
            S.visDotCol=col(S.visibleDots);
        end
        function myClear(S)
            S.LUT=[];
        end
        function [aziDeg,eleDeg,dotAge]=getFreshClusters(~,N,maxSteps)
            aziDeg=rand(1,N)*360; % angle in cross-section plane orthogonal to vertical axis
            eleDeg=acosd(rand(1,N)*2-1)-90; % angle of origin-point vector with vertical axis, -90 to make equator at 0 elevation
            if nargout>2
                dotAge=floor(rand(1,N)*maxSteps+1);
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
        function set.RBGAfrac1(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RBGAfrac1 should be a ' str]);
            else
                S.RBGAfrac1=value;
            end
        end
        function set.RBGAfrac2(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RBGAfrac2 should be a ' str]);
            else
                S.RBGAfrac2=value;
            end
        end         
    end
end


