function tc=calcDirectionTuningCurveGlm(DPXD,cellNr,varargin)
    
    if nargin==1 && strcmp(DPXD,'info')
        tc.per='cell';
        return;
    end
    % This function calculates a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, its output can be plot with the
    % complementary plotDirectionTuningCurve
    %
    % This is a complete overhaul of the calcDirectionTuningCurve where the
    % dFoF was calculated as
    
    % Remove trials in which the test was not enabled. Typically, this means that that
    % trial was initial, long adaptation trial which has a dummy test-stimulus.
    DPXD=dpxdSubset(DPXD,DPXD.test_enabled);
    % See how many sessions went into this dataset, could be merged data.
    % If so, plot the individual session curves as well as the merged curve
    % (merged on top and clearer line and markers)
    tc{1}=getCurve(DPXD,cellNr,varargin{:}); % 1 is always all data
    thisIsMergeData=numel(unique(DPXD.exp_startTime))>1;
    if thisIsMergeData
        D=dpxdSplit(DPXD,'exp_startTime');
        for i=1:numel(D)
            tc{end+1}=getCurve(D{i},cellNr,varargin{:}); %#ok<AGROW>
        end
    end
end

function tc=getCurve(DPXD,cellNr,varargin)
    % Parse 'options' input
    p=inputParser;
    p.parse(varargin{:});
    %
    dfofField=['resp_unit' num2str(cellNr,'%.3d') '_dFoF']; % e.g., if cellNr is 1, 'resp_unit001_dFoF'
    timeField=['resp_unit' num2str(cellNr,'%.3d') '_s']; % e.g., if cellNr is 1, 'resp_unit001_s'
    
    % Get the response vector R and corresponding timeaxis RT
    [R,RT]=getResponseVector(DPXD,dfofField,timeField);
    % Make the design matrix (conditions) M
    [M,desc]=getDesignMatrix(DPXD,RT);
    % Make a simple design matrix (one column, stim ON - OFF)
    ONOFF=sum(M,2);
    % 
    % Remove the startime from RT (don't do before getDesignMatrix!)
    RT=RT-RT(1);
    % Filter the respopnse
    if false
        R=bandpassFilterResponse(RT,R,M);
    end
    if false
        M=convolveGCaMP6response(M,RT);
        ONOFF=convolveGCaMP6response(ONOFF,RT);
    end
    
    % The response has an unknown delay compared to the stimulus (combined
    % neural latency and GCaMP6). Perform the GLM at a number of delays and
    % see which is best. Use that one, and store the found delay. According
    % to paper "doi: 10.1371/journal.pone.0108697" whe should find it at around 2 second.
    
    delaySec=0:.25:8;
    Fvalues=nan(size(delaySec));
    maxF=-Inf;
    for t=1:numel(delaySec)
        % Shift the response vector by the latency estimate
        if delaySec(t)==0
            offsetR=R;
        else
            latSamples=ceil(delaySec(t)/median(diff(RT)));
            if size(R,1)~=1, error('R was assumed a row vector!'); end
           % offsetR=circshift(R,latSamples,2); % used to fill end with nan but seemed to favor large shifts (nans don't count toward residual error)
           % newTailIdx=numel(R)-latSamples:numel(R);
           % offsetR(newTailIdx)=R(randperm(numel(R),numel(newTailIdx))); % fill the tail from offsetR with random values from R
            offsetR=[R(latSamples:end) nan(1,latSamples-1)];
        end
        mdl=fitglm([ONOFF M],offsetR,'linear');
        DT = mdl.devianceTest;
        Fvalues(t) = table2array(DT(2,3)); % generic for F and Chi2
        if Fvalues(t)>maxF
            bestMdl=mdl;
            maxF=Fvalues(t);
            bestDelaySec=delaySec(t);
            bestOffSetR=offsetR;
            pValueFull= DT.pValue(2);
            devianceFull=DT.Deviance(2);
        end
    end
    fittedR=bestMdl.Fitted.Response;
    rSq=bestMdl.Rsquared.Ordinary;
    B=table2array(bestMdl.Coefficients(3:end,1)); % 3:end = ignore the intercept and ONOFF columns
    Bse=table2array(bestMdl.Coefficients(3:end,2)); % 3:end = ignore the intercept and ONOFF columns
    % Compare the full model with the simple model that only has stim
    % on/off
    mdlSimple=fitglm(ONOFF,bestOffSetR,'linear');
    mdlFull=bestMdl; % came as best out of the delay loop
    DT=mdlSimple.devianceTest;
    pValueSimple= DT.pValue(2);
    devianceSimple=DT.Deviance(2);
    nAdditionalParams=numel(mdlFull.CoefficientNames)-numel(mdlSimple.CoefficientNames);
    fullVsSimplePvalue=1-chi2cdf(devianceSimple-devianceFull,nAdditionalParams); % not clear if i should use devianceSimple-devianceFull or other way around!!!
    % Now put this result in a format that is similar to that of the
    % calcDirectionTuningCurve (without Glm) so we can use most of the same
    % plot routine
    
    motTypes=unique({desc.test_motType});
    for mti=1:numel(motTypes)
        tc.motType{mti}=motTypes{mti}; % string indicating the motion type (e.g. 'phi')
        tc.rSq{mti}=rSq; %  deviance is a generalization of the residual sum of squares
        tc.dirDeg{mti}=[];
        tc.B{mti}=[];
        tc.Bse{mti}=[];
        tc.dFoF{mti}=[RT(:) offsetR(:) fittedR(:)];
        tc.GlmFvaluePerDelay{mti}=[delaySec(:) Fvalues(:)];
        tc.bestDelay{mti}=bestDelaySec;
        tc.GlmFullPvalue{mti}=pValueFull;
        tc.GlmOnOffPvalue{mti}=pValueSimple;
        tc.FullVsOnOffPvalue{mti}=fullVsSimplePvalue;
        for i=1:numel(desc)
            if strcmp(desc(i).test_motType,motTypes{mti})
                tc.dirDeg{mti}(end+1)=desc(i).test_dirDeg;
                tc.B{mti}(end+1)=B(i);
                tc.Bse{mti}(end+1)=Bse(i);
            end
        end
        tc.N=numel(motTypes);
        if ~dpxdIs(tc)
            error('tc should be a DPXD-struct');
        end
    end
end


function [R,RT]=getResponseVector(DPXD,dfofField,timeField)
    % Make the Time axis
    RT=cell(1,DPXD.N);
    for i=1:DPXD.N
        tmp=DPXD.(timeField){i}; % to make row
        RT{i}=tmp(:)'+DPXD.startSec(i);
    end
    RT=[RT{:}];
    % Make the response vector by concatenating all responses
    R=[DPXD.(dfofField){:}];
end

function [M,desc]=getDesignMatrix(D,RT)
    % Create the design matrix M and a description per condition (desc)
    D=dpxdSplit(D,{'test_motType','test_dirDeg'});
    M=zeros(numel(RT),numel(D));
    for c=1:numel(D)
        desc(c).test_motType=D{c}.test_motType{1}; %#ok<AGROW>
        desc(c).test_dirDeg=D{c}.test_dirDeg(1); %#ok<AGROW>
        for tr=1:D{c}.N
            % this could easily be optimized but i think it won't take long
            from=D{c}.test_motStartSec(tr)+D{c}.startSec(tr);
            till=from+D{c}.test_motDurSec(tr);
            idx=RT>=from & RT<till;
            M(idx,c)=1;
        end
    end
end


function  M=convolveGCaMP6response(M,RT)
    % Convolve the stimulus onsets to mimic the dynamics of
    % neural/GCaMP6 response. Reference doi:
    % 10.1371/journal.pone.0108697 for this The response profile that
    % i'm creating here to convolve the Design Matrix is an imitation
    % of their Figure 5f (AAV-6s). The delay is not important (we will
    % be shifting the response vector in a loop when we do the GLM)
    sampleSec=median(diff(RT));
    decayTauSec=3;
    riseTauSec=0.3;
    tAxis=(0:1000)*sampleSec;
    threshold=0.01;
    rise=exp(-tAxis/riseTauSec);
    decay=exp(-tAxis/decayTauSec);
    rise(rise<threshold)=[];
    decay(decay<threshold)=[];
    profile=[rise(end:-1:2) decay(:)'];
    profile=dpxClamp(profile,[0 1]); % normalize between 0 and 1
    if false % do plot
        cpsFindFig('GCaMP6 convolution profile (Dana et al 2014 plos1)');
        tAxis=(0:numel(profile)-1)*sampleSec;
        plot(tAxis,profile);
        set(gca,'XLim',[0 5]);
        xlabel('Time (S)'); ylabel('dFoF');
        keyboard
    end
    for c=1:size(M,2)
        f=conv(M(:,c),profile,'full');
        f=f(1:size(M,1)); % cut off the last bit
        M(:,c)=f;
    end
end


function fR=bandpassFilterResponse(RT,R,M)
    % Step 1: find the stimulation frequency (stimHz)
    stimpat=sum(M'); % the pattern of stim on stim off
    Fs=1/median(diff(RT)); % sampling rate in Hz
    nrSamples=numel(RT); % number of samples
    NFFT=2^nextpow2(nrSamples); % round up to nearest power of 2
    f=Fs/2*linspace(0,1,NFFT/2+1); % frequency axis of the power spectrum
    Y=fft(stimpat,NFFT)/nrSamples; % Fast Fourier transform
    % semilogx(f,imag(Y(1:NFFT/2+1)*360),'r'); % plots the power spectrum
    [~,idx]=max(imag(Y(1:NFFT/2+1)*360));
    stimHz=f(idx);
    % Step 2: Band pass filter the response
    maxFreq=stimHz/Fs*2;
    [b,a]=butter(3,[maxFreq/10,maxFreq]);
    fR=filtfilt(b,a,R);
end
