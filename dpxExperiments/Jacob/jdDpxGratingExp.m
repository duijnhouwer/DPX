function jdDpxGratingExp
    E=dpxCoreExperiment;
    E.windowed(true) ; % [0 0 810 610]+100); % true, false, [0 0 410 310]+100
    E.txtStart='Press and release a key to start\nthen start the LasAF pattern';
    E.txtPauseNrTrials=0;
    %
    % settings
    %
    dirDegs=0:45:315;
    contrastFracs=1;
    cyclesPerDeg=.05;
    cyclesPerSecond=1;
    E.nRepeats=5;
    stimSec=4;
    isiSec=4;
    %
    nrTrials=numel(dirDegs) * numel(contrastFracs) * numel(cyclesPerDeg) * numel(cyclesPerSecond) * E.nRepeats
    disp(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec+5))) ' s recording pattern in LasAF.']);
    input('<< Press a key when done >>');
    for direc=dirDegs(:)'
        for cont=contrastFracs(:)'
            for sf=cyclesPerDeg(:)'
                for tf=cyclesPerSecond(:)'
                    C=dpxCoreCondition;
                    C.durSec=stimSec+isiSec;
                    %
                    S=dpxStimGrating;
                    %
                    S.wDeg=25;
                    S.dirDeg=direc;
                    S.cyclesPerSecond=tf;
                    S.cyclesPerDeg=sf;
                    S.contrastFrac=cont;
                    S.squareWave=true;
                    S.maskStr='circle';
                    S.maskPars=3;
                    S.onSec=isiSec;
                    S.durSec=stimSec;
                    %
                    C.addStim(S);
                    E.addCondition(C);
                end
            end
        end    
    end
    E.run;
end
