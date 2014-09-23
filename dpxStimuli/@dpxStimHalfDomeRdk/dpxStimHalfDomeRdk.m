classdef dpxStimHalfDomeRdk < dpxBasicStim
    
    properties (Access=public)
        nDots;
        dotDiamDeg;
        lutFileName='halfDomeLUT.mat';
    end
    properties (Access=protected)
        aziDeg;
        eleDeg;
        dotxy;
        LUT;
    end
    methods (Access=public)
        function S=dpxStimHalfDomeRdk
            % Random dot kinematogram stimulus for in the half-dome
            % projection set-up.
            %
            % Type: get(dpxStimHalfDomeRdk) for more info
            % Type: edit dpxStimHalfDomeRdk for full info
            %
            % Part of the DPX toolkit
            % Jacob Duijnhouwer, 2014-09-23
            S.nDots=1000;
        end
    end
    methods (Access=protected)
        function myInit(S)
            pwd
            tmp=load(S.lutFileName);
            
            S.LUT=S.loadHalfdomeWarpObject;
            S.dotxy=[];
            % create a uniform-density sphere of nDots dots
            S.aziDeg=rand(S.nDots,1)*360; % angle in cross-section plane orthogonal to vertical axis
            S.eleDeg=acosd(rand(S.nDots,1)*2-1); % angle of origin-point vector with vertical axis
        end
        function myDraw(S)
            Screen('DrawDots',S.physScrVals.windowPtr,S.dotxy,10,[255 255 255 255],[0 0],2);
        end
        function myStep(S)
            S.aziDeg=S.aziDeg+1;
            a=mod(S.aziDeg,360)-180;
            S.dotxy=S.LUT.getXYpix(a,S.eleDeg);
        end
        function myClear(S)
            S.LUT=[];
        end
        function W=loadHalfdomeWarpObject(S)
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
