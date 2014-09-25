classdef dpxStimHalfDomeRdk < dpxBasicStim
    
    properties (Access=public)
        nClusters;
        dAdEdeg; % azimuth and elevation offsets of points in cluster
        dotSize;
        lutFileName='halfDomeLUT.mat';
        dotRBGAfrac1;
        dotRBGAfrac2;
    end
    properties (Access=protected)
        aziDeg;
        eleDeg;
        LUT;
        dotsRGBA;
        visibleDots;
        dotXy;
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
            S.dotSize=4;
            S.dAdEdeg=[0 sind(45:45:360)*.25 sind(30:30:360)*.5 ; 0 cosd(45:45:360)*.25 cosd(30:30:360)*.5];
            S.dotRBGAfrac1=[0 0 0 1];
            S.dotRBGAfrac2=[1 1 1 1];
        end
    end
    methods (Access=protected)
        function myInit(S)
            F2I=S.physScrVals.whiteIdx; % fraction to index (for colors)
            S.LUT=S.loadHalfdomeWarpObject;
            S.dotXy=[];
            % create a uniform-density sphere of nClusters dots
            S.aziDeg=rand(S.nClusters,1)*360; % angle in cross-section plane orthogonal to vertical axis
            S.eleDeg=acosd(rand(S.nClusters,1)*2-1)-90; % angle of origin-point vector with vertical axis, -90 to make equator at 0 elevation
            idx = rand(1,S.nClusters)<.5;
            S.dotsRGBA(:,idx) = repmat(S.dotRBGAfrac1(:)*F2I,1,sum(idx));
            S.dotsRGBA(:,~idx) = repmat(S.dotRBGAfrac2(:)*F2I,1,sum(~idx));
        end
        function myDraw(S)
            %colors=repmat(S.dotsRGBA(:,S.visibleDots),1,S.nDotsPerCluster);
            tic
            Screen('DrawDots',S.physScrVals.windowPtr,S.dotXy,S.dotSize,[255 255 255 255],[0 0],2);
            toc
            %  for i=1:numel(S.visibleDots)
            %        x=S.dotXy(1,i);
            %        y=S.dotXy(2,i);
            %        a=.5;
            %        check=[x-a y-a; x+a y-a; x+a y+a; x-a y+a];
            %        Screen('FillPoly',S.physScrVals.windowPtr,colors(:,i),check);
            %  end
        end
        function myStep(S)
            % 1: update the positions
            S.aziDeg=S.aziDeg+.1;
            % 2: convert azi-ele deg to x-y pix
            % format the ele and azi coordinates lists of all clusters
            centerAzi=mod(S.aziDeg(:)',360)-180;
            centerEle=S.eleDeg(:)';
            % See which of the centers fall within the panorama
            [~, S.visibleDots]=S.LUT.getXYpix(centerAzi,centerEle);
            azi=repmat(centerAzi(S.visibleDots),1,size(S.dAdEdeg,2));
            ele=repmat(centerEle(S.visibleDots),1,size(S.dAdEdeg,2));
            dAzi=repmat(S.dAdEdeg(1,:),numel(S.visibleDots),1);
            dEle=repmat(S.dAdEdeg(2,:),numel(S.visibleDots),1);
            azi=azi+dAzi(:)';
            ele=ele+dEle(:)';
            [S.dotXy, S.visibleDots]=S.LUT.getXYpix(azi,ele);
        end
        function myClear(S)
            S.LUT=[];
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
            end
        end
        function set.dotRBGAfrac1(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['dotRBGAfrac1 should be a ' str]);
            else
                S.dotRBGAfrac1=value;
            end
        end
        function set.dotRBGAfrac2(S,value)
            [ok,str]=dpxIsRGBAfrac(value);
            if ~ok
                error(['dotRBGAfrac2 should be a ' str]);
            else
                S.dotRBGAfrac2=value;
            end
        end         
    end
end
