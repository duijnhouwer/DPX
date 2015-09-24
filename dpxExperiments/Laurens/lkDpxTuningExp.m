function lkDpxTuningExp(varargin)
    
    % lkDpxTuningExp(varargin)
    %
    % EXAMPLES
    %   Standard grating tuning curve:
    %       lkDpxTuningExp
    %   Grating speed tuning curve with different contrasts vertical
    %        lkDpxTuningExp('mode','Speed', 'stim','Grat', 'dirdeg',90)
    %   Random dots speed tuning curve with different contrasts horizontal
    %        lkDpxTuningExp('stim','Rdk', 'mode','Speed')
    %   Random dots direction tuning curve with phi and reverse-phi dots
    %       lkDpxTuningExp('stim','rdkRevPhi', 'mode','dir');
    
    p=inputParser;
    p.addParamValue('mode','dir',@(x)any(strcmpi(x,{'dir','speed'})));
    p.addParamValue('stim','grat',@(x)any(strcmpi(x,{'grat','rdk','rdkRevPhi','rdkTrans'})));
    p.addParamValue('dirDeg',0,@(x)isnumeric(x)&&numel(x)==1);
    p.parse(varargin{:});
    
    E=dpxCoreExperiment;
    E.expName=dpxCamelCase('lkDpxTuning',p.Results.mode,p.Results.stim,num2str(p.Results.dirDeg));
    E.scr.distMm=lkSettings('VIEWDISTMM');
    E.scr.winRectPx=lkSettings('WINPIX'); % WINPIX WINPIXDEBUG
    E.scr.widHeiMm=lkSettings('SCRWIDHEIMM');
    E.scr.gamma=lkSettings('GAMMA');
    E.scr.backRGBA=lkSettings('BACKRGBA');
    E.scr.verbosity0min5max=lkSettings('VERBOSITY');
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
        dirDegs=lkSettings('TESTDIRS')+p.Results.dirDeg;
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFFIX');
        contrastFracs=lkSettings('CONTRASTFIX');
        E.nRepeats=6;
    elseif strcmpi(p.Results.mode,'Speed')
        dirDegs=mod([p.Results.dirDeg p.Results.dirDeg+180],360);
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFRANGE');
        contrastFracs=lkSettings('CONTRASTRANGE');
        E.nRepeats=3;
    end
    stimSec=lkSettings('STIMSEC');
    isiSec=lkSettings('ISISEC');
    if strcmpi(p.Results.stim,'rdkRevPhi')
        motTypes={'phi','ihp'}; % rdkRevPhi exp has regular AND reverse phi
    else
        motTypes={'phi','phi'}; % twice so we keep the same number of trials per block
    end
    if strcmpi(p.Results.stim,'rdkTrans')
        transSeparationDeg=[nan 0 90 180]; % nan is 1 component, otherwise 2 components with X angular separation
        E.nRepeats=2; % reduce number of repeats ...
    else
        transSeparationDeg=0;
    end
    %
    for direc=dirDegs(:)'
        for cont=contrastFracs(:)'
            for sf=cyclesPerDeg(:)'
                for tf=cyclesPerSecond(:)'
                    for mt=1:numel(motTypes)
                        for transDeg=transSeparationDeg(:)'
                            C=dpxCoreCondition;
                            C.durSec=stimSec+isiSec;
                            %
                            if strcmpi(p.Results.stim,'Grat')
                                S=dpxStimGrating;
                                S.cyclesPerSecond=tf;
                                S.cyclesPerDeg=sf;
                                S.contrastFrac=cont;
                                S.grayFrac=E.scr.backRGBA(1);
                                S.squareWave=false;
                                S.dirDeg=direc;
                            else % rdk or rdkRevPhi
                                S=dpxStimRdk;
                                S.speedDps=tf/sf;
                                S.dotsPerSqrDeg=.09;
                                S.dotDiamDeg=1/sf/6;
                                S.dirDeg=direc;
                                % calculate the luminance based on the backRGBA and the contrast values
                                bright=E.scr.backRGBA(1)+E.scr.backRGBA(1)*cont; % single value between [0..1]
                                dark=E.scr.backRGBA(1)-E.scr.backRGBA(1)*cont; % single value between [0..1]
                                S.dotRBGAfrac1=[bright bright bright 1]; % witte stippen
                                S.dotRBGAfrac2=[dark dark dark 1]; % zwarte stippen
                                S.motType=motTypes{mt};
                                if strcmpi(p.Results.stim,'Rdk')
                                    S.nSteps=Inf; % unlimited lifetime
                                elseif strcmpi(p.Results.stim,'rdkTrans')
                                    S.nSteps=Inf;
                                    if ~isnan(transDeg)
                                        S.dirDeg=S.dirDeg+transDeg*1i; % two components, transDir angular separation
                                    else
                                        S.dotsPerSqrDeg=S.dotsPerSqrDeg/2; % single component, use half the dots
                                    end
                                elseif strcmpi(p.Results.stim,'RdkRevPhi')
                                    S.nSteps=1; % single step dotlife lifetime
                                    S.freezeFlip=4;
                                else
                                    error(['Unknown stim: ' p.Results.stim]);
                                end
                            end
                            S.name='test';
                            S.wDeg=lkSettings('STIMDIAM');
                            S.hDeg=S.wDeg;
                            S.onSec=isiSec/2;
                            S.durSec=stimSec;
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
        end
    end
    nrTrials=numel(E.conditions) * E.nRepeats;
    xtr=lkSettings('2PHOTONEXTRASECS');
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+xtr)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + ' num2str(xtr) ' s)']);
    E.run;
end
