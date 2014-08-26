function jdDpxGratingExp
    E=dpxCoreExperiment;
    E.expName='squarewaves';
    E.windowed(true) ; % [0 0 810 610]+100); % true, false
    E.txtStart='AAA DAQ-pulse';
    E.txtEnd='AAA DAQ-pulse';
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
    dirDegs=0:45:315;
    contrastFracs=1;
    cyclesPerDeg=.05;
    cyclesPerSecond=1;
    E.nRepeats=2;
    stimSec=1;
    isiSec=1;
    %
    nrTrials=numel(dirDegs) * numel(contrastFracs) * numel(cyclesPerDeg) * numel(cyclesPerSecond) * E.nRepeats;
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec+5))) ' s recording pattern in LasAF.']);
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
