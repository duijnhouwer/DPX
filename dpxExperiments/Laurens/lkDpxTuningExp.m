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
    %   Random dots speed tuning curve with different contrasts diagona/
    %        lkDpxTuningExp('stim','Rdk', 'mode','Speed','dirDeg',45)
    %   Random dots direction tuning curve with phi and reverse-phi dots
    %       lkDpxTuningExp('stim','rdkRevPhi', 'mode','dir');
    %   Random dots with 0, 90, 180 deg transparency (and 1 component control)
    %       lkDpxTuningExp('stim','rdkTrans')
    %   Random dots speed tuning curve with different DotDiam horizontal
    %        lkDpxTuningExp('stim','Rdk', 'mode','speedDotDiam')
    %   Random dots speed tuning curve with different DotDiam diagona\
    %        lkDpxTuningExp('stim','Rdk', 'mode','speedDotDiam','dirDeg',135)
    
    p=inputParser;
    p.addParamValue('mode','dir',@(x)any(strcmpi(x,{'dir','speed','speedDotDiam','speedContrast'})));
    p.addParamValue('stim','grat',@(x)any(strcmpi(x,{'grat','rdk','rdkRevPhi','rdkTrans'})));
    p.addParamValue('dirDeg',0,@(x)isnumeric(x)&&numel(x)==1);
    p.parse(varargin{:});
    
    E=dpxCoreExperiment;
    E.paradigm=dpxCamelCase('lkDpxTuning',p.Results.mode,p.Results.stim,num2str(p.Results.dirDeg));
    E.window.distMm=lkSettings('VIEWDISTMM');
    E.window.rectPx=lkSettings('WINPIX'); % WINPIX WINPIXDEBUG
    E.window.widHeiMm=lkSettings('SCRWIDHEIMM');
    E.window.gamma=lkSettings('GAMMA');
    E.window.backRGBA=lkSettings('BACKRGBA');
    E.window.verbosity0min5max=lkSettings('VERBOSITY');
    E.window.skipSyncTests=lkSettings('SKIPSYNCTEST');
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
        dotDiamFactor=1;
        E.nRepeats=10;
    elseif strcmpi(p.Results.mode,'Speed')
        dirDegs=mod([p.Results.dirDeg p.Results.dirDeg+180],360);
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFRANGE');
        contrastFracs=lkSettings('CONTRASTRANGE');
        dotDiamFactor=1;
        E.nRepeats=3;
    elseif strcmpi(p.Results.mode,'speedDotDiam')
        if isempty(strfind(lower(p.Results.stim),'rdk'))
            error('speedDotDiam can only be used with rdk-stim')
        end
        dirDegs=mod([p.Results.dirDeg p.Results.dirDeg+180],360);
        cyclesPerDeg=lkSettings('SFFIX');
        cyclesPerSecond=lkSettings('TFRANGE4DOTS');
        contrastFracs=lkSettings('CONTRASTFIX');
        dotDiamFactor=lkSettings('DOTDIAMFACTOR');
        E.nRepeats=10;
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
        E.nRepeats=4; % reduce number of repeats ...
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
                            for ddFactor=dotDiamFactor(:)'
                                C=dpxCoreCondition;
                                C.durSec=stimSec+isiSec;
                                %
                                if strcmpi(p.Results.stim,'Grat')
                                    S=dpxStimGrating;
                                    S.cyclesPerSecond=tf;
                                    S.cyclesPerDeg=sf;
                                    S.contrastFrac=cont;
                                    S.grayFrac=E.window.backRGBA(1);
                                    S.squareWave=false;
                                    S.dirDeg=direc;
                                    S.onSec=isiSec/2;
                                    S.durSec=stimSec;
                                    S.wDeg=lkSettings('STIMDIAM');
                                else % rdk, rdkTrans, or rdkRevPhi
                                    if ~strcmpi(p.Results.mode,'speedDotDiam')
                                        S=dpxStimRdk; % draws dot primites (max diam ~20 pix or so)
                                    else
                                        S=dpxStimRdkHuge; % draws oval of any size
                                    end
                                    S.speedDps=tf/sf;
                                    S.dotsPerSqrDeg=.12;
                                    S.dotDiamDeg=1/sf/6*ddFactor;
                                    if ddFactor~=1
                                        % adjust the dotsPerSqrDeg to maintain equal number of dot pixels drawn
                                        S.dotsPerSqrDeg=S.dotsPerSqrDeg/ddFactor^2;
                                    end
                                    S.dirDeg=direc;
                                    S.motStartSec=isiSec/2; % 2015-10-28
                                    S.motDurSec=stimSec; % 2015-10-28
                                    % calculate the luminance based on the backRGBA and the contrast values
                                    bright=E.window.backRGBA(1)+E.window.backRGBA(1)*cont; % single value between [0..1]
                                    dark=E.window.backRGBA(1)-E.window.backRGBA(1)*cont; % single value between [0..1]
                                    S.dotRBGAfrac1=[bright bright bright 1]; % witte stippen
                                    S.dotRBGAfrac2=[dark dark dark 1]; % zwarte stippen
                                    S.motType=motTypes{mt};
                                    if strcmpi(p.Results.stim,'Rdk')
                                        S.nSteps=Inf; % unlimited lifetime
                                    elseif strcmpi(p.Results.stim,'rdkTrans')
                                        S.nSteps=Inf;
                                        S.dotRBGAfrac1=[1 1 1 1];
                                        S.dotRBGAfrac2=[1 1 1 1];
                                        E.window.backRGBA=[0 0 0 1];
                                        if ~isnan(transDeg)
                                            S.dirDeg=S.dirDeg+transDeg*1i; % two components, transDir angular separation
                                        else
                                            S.dotsPerSqrDeg=S.dotsPerSqrDeg/2; % single component, use half the dots
                                        end
                                    elseif strcmpi(p.Results.stim,'RdkRevPhi')
                                        S.nSteps=1; % single step dotlife lifetime
                                        S.freezeFlip= 6;
                                    else
                                        error(['Unknown stim: ' p.Results.stim]);
                                    end
                                    if strcmpi(p.Results.mode,'speedDotDiam')
                                        % force single color dots in speedDotDiam mode (not Black/White)
                                        S.dotRBGAfrac1=[cont cont cont 1];
                                        S.dotRBGAfrac2=[cont cont cont 1];
                                        E.window.backRGBA=[0 0 0 1];
                                    end
                                    % Give the stimulus (but NOT the occulusing mask) to accomodate the dot
                                    % diameter.  a dot is refreshed when its center is out of the stimulus
                                    % width or height. With big dots, this will result in a sudden
                                    % disappearance of the dot. This size "should" be the radius of the dots.
                                    % However, because the scaling from degrees to pixels is assumed linear,
                                    % this doesn't work for large angle displays (like in the 2photon).
                                    % Therefore, just add 2 times the radius to be safe (this will incur a
                                    % penalty on the performance (larger stim is more dots) so if you get
                                    % framedrops look at this setting first.
                                    S.wDeg=lkSettings('STIMDIAM')+S.dotDiamDeg;
                                end
                                S.hDeg=S.wDeg;
                                S.name='test';
                                %
                                MASK=dpxStimMaskCircle;
                                MASK.name='mask';
                                MASK.wDeg=S.wDeg*sqrt(2)+1;
                                MASK.hDeg=S.wDeg*sqrt(2)+1;
                                MASK.outerDiamDeg=lkSettings('STIMDIAM');
                                MASK.innerDiamDeg=lkSettings('STIMDIAM')-5;
                                MASK.RGBAfrac=E.window.backRGBA;
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
                                C.addStimulus(MASK);
                                C.addStimulus(S);
                                if IsLinux % lab computer is linux, only use MCC there
                                    C.addStimulus(V);
                                    C.addResponse(MCC);
                                end
                                %
                                E.addCondition(C);
                            end
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