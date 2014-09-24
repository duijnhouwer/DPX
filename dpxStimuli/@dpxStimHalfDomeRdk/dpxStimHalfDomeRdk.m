classdef dpxStimHalfDomeRdk < dpxBasicStim
    
    properties (Access=public)
        nDots;
        dotDiamDeg;
        lutFileName='halfDomeLUT.mat';
        dotRBGAfrac1;
        dotRBGAfrac2;
    end
    properties (Access=protected)
        aziDeg;
        eleDeg;
        dotxy;
        LUT;
        dotsRGBA;
        visibleDots;
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
            S.nDots=500;
            S.dotRBGAfrac1=[0 0 0 1];
            S.dotRBGAfrac2=[1 1 1 1];
        end
    end
    methods (Access=protected)
        function myInit(S)
            F2I=S.physScrVals.whiteIdx; % fraction to index (for colors)
            S.LUT=S.loadHalfdomeWarpObject;
            S.dotxy=[];
            % create a uniform-density sphere of nDots dots
            S.aziDeg=rand(S.nDots,1)*360; % angle in cross-section plane orthogonal to vertical axis
            S.eleDeg=acosd(rand(S.nDots,1)*2-1); % angle of origin-point vector with vertical axis
            idx = rand(1,S.nDots)<.5;
            S.dotsRGBA(:,idx) = repmat(S.dotRBGAfrac1(:)*F2I,1,sum(idx));
            S.dotsRGBA(:,~idx) = repmat(S.dotRBGAfrac2(:)*F2I,1,sum(~idx));
        end
        function myDraw(S)
            colors=S.dotsRGBA(:,S.visibleDots);
            Screen('DrawDots',S.physScrVals.windowPtr,S.dotxy,10,colors,[0 0],2);
        end
        function myStep(S)
            S.aziDeg=S.aziDeg+1;
            a=mod(S.aziDeg,360)-180;
            [S.dotxy, S.visibleDots]=S.LUT.getXYpix(a,S.eleDeg);
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
end
