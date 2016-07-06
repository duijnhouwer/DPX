function jdDpxExpHalfDomeTransPercent(debug)
    % Jacob, 2016-05-23
    if nargin==0
        debug = false;
    end
    E = dpxCoreExperiment;
    E.paradigm = mfilename;
    E.window.verbosity0min5max = 1;
    E.window.backRGBA = [0 0 0 1];
    E.window.distMm = 600;
    if IsLinux
        E.outputFolder = '/data/vanwezeldata/dpxData';
        E.window.rectPx = [1920 0 1920+1920 1080];
        E.window.skipSyncTests = 0;
        E.window.gamma = 0.25;
    else
        if debug
            E.window.rectPx = [0 0 600 400];
        else
            E.window.rectPx = [0 0 1920 1080];
        end
        E.window.skipSyncTests = 1;
        E.window.gamma = 1;
    end
    E.nRepeats = 11;
    
    motSec = 2;
    lum = .15;
    degPerSec = 36;
    for prop = [0.5 0.6 0.7 0.8 0.9 1]
        for dir1 = 'lr'
            for startSec = [1 2]
                C = dpxCoreCondition;
                C.durSec = startSec+motSec+2;
                C.overrideBackRGBA = [0 0 0 1];
                %
                % mask
                M = dpxStimMaskTiff;
                M.name = 'mask';
                M.RGBAfrac = [0 0 0 1];
                M.filename = 'mask20141030.tif';
                M.dstRectPx = 'fullscreen';
                M.blurPx = 100;
                M.onSec = -1;
                %
                % dot stimulus 1
                S1 = dpxStimHalfDomeRdk;
                S1.name = 'rdk1';
                S1.lutFileName = 'HalfDomeWarpLut20141030.mat';
                S1.clusterRadiusDeg = 1;
                S1.dotDiamPx = 7;
                S1.invertSteps = Inf; % never invert: phi
                S1.nSteps = round(Inf*E.window.nominalFrameRate); % N second
                S1.eleDps = 0;
                S1.freezeFlip = 1;
                S1.motStartSec = startSec;
                S1.motDurSec = motSec;
                S1.RGBAfrac1 = [[lum lum lum]*2 1];
                S1.RGBAfrac2 = S1.RGBAfrac1;
                % dot stimulus 2
                S2 = dpxStimHalfDomeRdk;
                S2.name = 'rdk2';
                S2.lutFileName = 'HalfDomeWarpLut20141030.mat';
                S2.clusterRadiusDeg = 1;
                S2.dotDiamPx = 7;
                S2.invertSteps = Inf; % never invert: phi
                S2.nSteps = round(Inf*E.window.nominalFrameRate); % N second
                S2.eleDps = 0;
                S2.freezeFlip = 1;
                S2.motStartSec = startSec;
                S2.motDurSec = motSec;
                S2.RGBAfrac1 = [[lum lum lum]*2 1];
                S2.RGBAfrac2 = S2.RGBAfrac1;
                %
                % Set the directions of S1 and S2 and relative number
                % of dots
                S1.nClusters = round(750*prop);
                S2.nClusters = round(750*(1-prop));
                if dir1=='r'
                    S1.aziDps = degPerSec;
                    S2.aziDps = -degPerSec;
                elseif dir1=='l'
                    S1.aziDps = -degPerSec;
                    S2.aziDps = degPerSec;
                else
                    error(['Unknown Dir: ' dir1]);
                end
                %
                C.addStimulus(M);
                C.addStimulus(S1);
                C.addStimulus(S2);
                %
                if IsLinux
                    R1 = dpxRespContiMouse;
                    R1.name = 'mouseBack';
                    R1.doReset = false;
                    R1.mouseId = 9;
                    R1.defaultX = 1920;
                    R1.defaultY = 1080/2;
                    R1.allowUntilSec = C.durSec;
                    C.addResponse(R1);
                    %
                    R2 = dpxRespContiMouse;
                    R2.name = 'mouseSide';
                    R2.doReset = true;
                    R2.mouseId = 12;
                    R2.defaultX = 1920/2;
                    R2.defaultY = 1080/2;
                    R2.allowUntilSec = C.durSec;
                    C.addResponse(R2);
                end
                %
                E.addCondition(C);
            end
        end
    end
    blockDurSec = 0;
    for i = 1:numel(E.conditions)
        blockDurSec = blockDurSec+E.conditions{i}.durSec+.1;
    end
    disp([num2str(E.nRepeats) ' blocks will take approx. ' dpxSeconds2readable(blockDurSec*E.nRepeats)]);
    E.run;
end