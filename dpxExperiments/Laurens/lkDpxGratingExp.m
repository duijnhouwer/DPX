function lkDpxTuningExp(varargin)
    
    p=inputParser;
    p.addParamValue('mode','dir',@(x)any(strcmpi(x,{'dir','speed'})));
    p.addParamValue('stim','grat',@(x)any(strcmpi(x,{'grat','rdk'})));
    p.addParamValue('dirdeg',0,@(x)isnumeric(x)&&numel(x)==1);
    p.parse(varargin{:});

    
    E=dpxCoreExperiment;
    E.expName=['lkDpxTuning' mode];
    E.scr.distMm=lkSettings('VIEWDISTMM');
    E.scr.widHeiMm=lkSettings('SCRWIDHEIMM');
    E.scr.gamma=lkSettings('GAMMA');
    E.scr.backRGBA=lkSettings('BACKRGBA');
    E.scr.verbosity0min5max=lkSettings('VERBOSITY');
    E.scr.winRectPx=lkSettings('WINPIX');
    E.scr.skipSyncTests=lkSettings('SKIPSYNCTEST');
    if IsLinux
        E.txtStart='DAQ-pulse';
    else
        E.txtStart='asd DAQ-pulse';
    end
    E.txtEnd='';
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
    if strcmpi(mode,'DirTune')
        dirDegs=lkSettings('TESTDIRS');
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFFIX');
        contrastFracs=lkSettings('CONTRASTFIX');
        E.nRepeats=12;
    elseif strcmpi(mode,'SpeedTune')
        dirDegs=[dirDeg dirDeg+180];
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFRANGE');
        contrastFracs=lkSettings('CONTRASTRANGE');
        E.nRepeats=6;
    end
    stimSec=lkSettings('STIMSEC');
    isiSec=lkSettings('ISISEC');
    %
    for direc=dirDegs(:)'
        for cont=contrastFracs(:)'
            for sf=cyclesPerDeg(:)'
                for tf=cyclesPerSecond(:)'
                    C=dpxCoreCondition;
                    C.durSec=stimSec+isiSec;           
                    %
                    G=dpxStimGrating;
                    G.name='test';
                    G.wDeg=65;
                    G.hDeg=65;
                    G.dirDeg=direc;
                    G.cyclesPerSecond=tf;
                    G.cyclesPerDeg=sf;
                    G.contrastFrac=cont;
                    G.grayFrac=E.scr.backRGBA(1);
                    G.squareWave=false;
                    G.onSec=isiSec/2;
                    G.durSec=stimSec;
                    
                                    S=dpxStimRdk;
                S.name='test';
                S.wDeg=lkSettings('STIMDIAM');
                S.hDeg=S.wDeg;
                S.dirDeg=direc;
                S.speedDps=speed;
                S.dotsPerSqrDeg=.01;
                S.dotDiamDeg=2;
                S.nSteps=Inf; % unlimited lifetime
                % calculate the luminance based on the grayFrac and the contrast values
                bright=grayFrac+grayFrac*contrast;
                dark=grayFrac-grayFrac*contrast;
                S.dotRBGAfrac1=[bright bright bright 1]; % witte stippen
                S.dotRBGAfrac2=[dark dark dark 1]; % zwarte stippen
                S.onSec=isiSec/2;
                S.durSec=stimSec;
                
                    %
                    M=dpxStimMaskCircle;
                    M.name='mask';
                    M.wDeg=G.wDeg*sqrt(2)+1;
                    M.hDeg=G.wDeg*sqrt(2)+1;
                    M.outerDiamDeg=G.wDeg;
                    M.innerDiamDeg=G.wDeg-5;
                    M.RGBAfrac=E.scr.backRGBA;
                    %
                    V=dpxStimMccAnalogOut;
                    V.name='mcc';
                    V.onSec=0;
                    V.durSec=C.durSec;
                    V.initVolt=0;
                    V.stepSec=[G.onSec G.onSec+G.durSec];
                    V.stepVolt=[4 0];
                    V.pinNr=13;
                    %
                    MCC=dpxRespMccCounter;
                    MCC.name='mcc';
                    MCC.allowUntilSec=C.durSec;
                    %
                    C.addStim(M);
                    C.addStim(G);
                    if IsLinux % lab computer is linux, only use MCC there
                        C.addStim(V);
                        C.addResp(MCC);
                    end
                    %
                    E.addCondition(C);
                end
            end
        end    
    end
    nrTrials=numel(E.conditions) * E.nRepeats;
    xtr=lkSettings('2PHOTONEXTRASECS');
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+xtr)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + ' num2str(xtr) ' s)']);
    E.run;
end
