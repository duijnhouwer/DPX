function lkDpxTuningExp(varargin)
    
    % EXAMPLE
    %   Standaard grating tuning curve:
    %       lkDpxTuningExp
    %   Grating speed tuning curve with different contrasts vertical
    %        lkDpxTuningExp('mode','Speed', 'stim','Grat', 'dirdeg',90)
    %   Random dots speed tuning curve with different contrasts horizontal
    %        lkDpxTuningExp('stim','Rdk', 'mode','Speed')   
    
    p=inputParser;
    p.addParamValue('mode','dir',@(x)any(strcmpi(x,{'dir','speed'})));
    p.addParamValue('stim','grat',@(x)any(strcmpi(x,{'grat','rdk','rdkRevPhi'})));
    p.addParamValue('dirDeg',0,@(x)isnumeric(x)&&numel(x)==1);
    p.parse(varargin{:});
    
    E=dpxCoreExperiment;
    E.expName=dpxCamelCase('lkDpxTuning',p.Results.mode,p.Results.stim,num2str(p.Results.dirDeg));
    E.scr.distMm=lkSettings('VIEWDISTMM');
    E.scr.winRectPx=lkSettings('WINPIX');
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
    if strcmpi(p.Results.mode,'Dir')
        dirDegs=lkSettings('TESTDIRS');
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFFIX');
        contrastFracs=lkSettings('CONTRASTFIX');
        E.nRepeats=12;
    elseif strcmpi(p.Results.mode,'Speed')
        dirDegs=mod([p.Results.dirDeg p.Results.dirDeg+180],360);
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
                    if strcmpi(p.Results.stim,'Grat')
                        S=dpxStimGrating;
                        S.name='test';
                        S.wDeg=lkSettings('STIMDIAM');
                        S.hDeg=S.wDeg;
                        S.dirDeg=direc;
                        S.cyclesPerSecond=tf;
                        S.cyclesPerDeg=sf;
                        S.contrastFrac=cont;
                        S.grayFrac=E.scr.backRGBA(1);
                        S.squareWave=false;
                        S.onSec=isiSec/2;
                        S.durSec=stimSec;
                    elseif strcmpi(p.Results.stim,'Rdk') || strcmpi(p.Results.stim,'RdkRevPhi')
                        S=dpxStimRdk;
                        S.name='test';
                        S.wDeg=lkSettings('STIMDIAM');
                        S.hDeg=S.wDeg;
                        S.dirDeg=direc;
                        S.speedDps=tf/sf;
                        S.dotsPerSqrDeg=.01;
                        S.dotDiamDeg=1/sf/4;
                        S.nSteps=Inf; % unlimited lifetime
                        % calculate the luminance based on the grayFrac and the contrast values
                        bright=E.scr.backRGBA(1)+E.scr.backRGBA(1)*cont; % single value between [0..1]
                        dark=E.scr.backRGBA(1)-E.scr.backRGBA(1)*cont; % single value between [0..1]
                        S.dotRBGAfrac1=[bright bright bright 1]; % witte stippen
                        S.dotRBGAfrac2=[dark dark dark 1]; % zwarte stippen
                        S.onSec=isiSec/2;
                        S.durSec=stimSec;
                    else
                        error(['Unknown stim: ' p.Results.stim]);
                    end
                    %
                    M=dpxStimMaskCircle;
                    M.name='mask';
                    M.wDeg=S.wDeg*sqrt(2)+1;
                    M.hDeg=S.wDeg*sqrt(2)+1;
                    M.outerDiamDeg=S.wDeg;
                    M.innerDiamDeg=S.wDeg-5;
                    M.RGBAfrac=E.scr.backRGBA;
                    %
                    V=dpxStimMccAnalogOut;
                    V.name='mcc';
                    V.onSec=0;
                    V.durSec=C.durSec;
                    V.initVolt=0;
                    V.stepSec=[S.onSec S.onSec+S.durSec];
                    V.stepVolt=[4 0];
                    V.pinNr=lkSettings('MCCPIN');
                    %
                    MCC=dpxRespMccCounter;
                    MCC.name='mcc';
                    MCC.allowUntilSec=C.durSec;
                    %
                    C.addStim(M);
                    C.addStim(S);
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
