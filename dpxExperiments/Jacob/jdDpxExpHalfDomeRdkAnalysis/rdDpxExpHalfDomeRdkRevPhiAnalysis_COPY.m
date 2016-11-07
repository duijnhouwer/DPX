function files=jdDpxExpHalfDomeRdkRevPhiAnalysis_COPY(files)
if nargin==0
    files = dpxUIgetFiles;
    if isempty(files) || isempty(files{1})
        return;
    end
end
E={};
for i=1:numel(files)
    D=dpxdLoad(files{i});
    [D,str,suspect,maxCorr]=clarifyAndCheck(D);
    if ~suspect
        % Only include data files that are completely fine and have no suspicious
        % things happening, like poor correlations between the yaw measurements of
        % both computer mice on the ball (both measure yaw, should be about the
        % same)
        E{end+1}=D;
    else
        disp(['clarifyAndCheck said ' str ' but correlation (' num2str(maxCorr) ') is below threshold...']);
        disp([' ---> skipping file : ' files{i} ]);
    end
    clear D;
end
% Merge all datafiles that we collected in cell array
E=dpxdMerge(E); % E is now a DPXD

flip=5;
PHI  = dpxdSubset(E,E.rdk_nSteps==1 & E.rdk_invertSteps==Inf);
Cphi = analyze(PHI,['; Phi, flip: ' num2str(flip)]);
IHP  = dpxdSubset(E,E.rdk_nSteps==1 & E.rdk_invertSteps==1);
Cihp = analyze(IHP,['; Reversed phi, flip: ' num2str(flip)]);

%% analysing movement pattern at the end
% [Cphi Cihp] = scatterdiverging(Cphi,Cihp);
% flipsplot(Cphi,Cihp,flip);

dpxTileFigs;

% end

keyboard

%     namePhi = ['Allmice Phi Flip ' num2str(flip)];
%     print(hPhi,namePhi,'-dpng','-r0')
%     nameRevPhi = ['Allmice ReversedPhi Flip ' num2str(flip)];
%     print(hRPhi,nameRevPhi,'-dpng','-r0')f
%     clearvars -except EE
%     close all
% end
return;

% Add a mean background luminance field to E based on the RGBAfrac values
% by calculates the mean of the first 3 elements of each 4-element array in
% cell array E.mask_RGBAfrac
E.mask_grayFrac=cellfun(@(x)mean(x(1:3)),E.mask_RGBAfrac);
E.mask_grayFrac=round(E.mask_grayFrac*1000)/1000; % round to remove precission errors
lumsUsed=unique(E.mask_grayFrac);
lumsUsed=[lumsUsed -1]; % add -1 to analyze the pooled data also
for i=1:numel(lumsUsed)
    if lumsUsed(i)==-1
        analyze(E,'; Lum=ALL');
    else
        analyze(dpxdSubset(E,E.mask_grayFrac==lumsUsed(i)),['; Lum=' num2str(lumsUsed(i))]);
    end
end
end


function C=analyze(E,titleString)
% split E per mouse, E
E=dpxdSplit(E,'exp_subjectId'); % E is now a cell-array of DPXDs
% for each mouse, get the curves, and store in cell array C
C=cell(size(E));
for i=1:numel(E)
    C{i}=getSpeedCurves(E{i});
end
% Make a plot of the raw yaw traces, to visual inspect for clipping
%     plotAllYawToCheckClipping(C,titleString);
% calculate mean traces per mouse (pooled over sessions)
C=getMeanYawTracesPerMouse(C);
% add a virtual mouse that is the mean of all mean-others
C=addMeanMouse(C);
%
C=getOffsetPerSecond(C);
% plot the curves, panel per mouse
plotTraces(C,titleString);
plotMeanTrace(C{end},titleString);
% plot the drifts relative to stat
% plotDriftScatter(C,titleString);
end

function C=getSpeedCurves(D)
% Split the data in left, static, and rightward stimulation
S{1}=dpxdSubset(D,D.rdk_aziDps<0);
S{2}=dpxdSubset(D,D.rdk_aziDps==0);
if S{2}.N==0
    S{2}=dpxdSubset(D,D.rdk_aziDps>0);
else
    S{3}=dpxdSubset(D,D.rdk_aziDps>0);
end
C.speed=[];
for i=1:numel(S)
    C.speed(i)=S{i}.rdk_aziDps(1);
    C.mus{i}=S{i}.exp_subjectId{1};
    % Get the yaw that happened from half a second before the start of the
    % stimulus until the start of the stimulus. This mean of this will be the
    % baseline speed that we subtract from the whole yaw-trace a first step of
    % normalization, i.e., this removes the baseline
    preStimYaw=getYawTrace(S{i},[-.5 0]);
    [C.yawRaw{i},C.time{i}]=getYawTrace(S{i},[-.5 4]);
    % subtract the baseline speed
    for t=1:numel(preStimYaw)
        C.yaw{i}{t}=C.yawRaw{i}{t}-nanmean(preStimYaw{t});
    end
end
% Add the number of speeds. A field called N that contains the numbers of
% elemenents per row of DPXD struct is required for any valid DPXD struct.
C.N=numel(C.speed);
if ~dpxdIs(C)
    error('not a valid DPXD!');
end
% ---- Sub function
    function [yaw,time]=getYawTrace(S,interval)
        % calculate the mean yaw for all trials in S over the specified interval
        yaw=cell(1,S.N);
        for tt=1:S.N
            from=interval(1)+S.rdk_motStartSec(tt);
            till=interval(2)+S.rdk_motStartSec(tt);
            idx{tt}=S.resp_mouseBack_tSec{tt}>=from & S.resp_mouseBack_tSec{tt}<till;
            idx{tt}=idx{tt}(:)'; % make sure is row
            yaw{tt}=mean([S.resp_mouseSideYaw{tt}(idx{tt});S.resp_mouseBackYaw{tt}(idx{tt})],1);
        end
        for q=1:numel(idx)
        ok(q)=sum(idx{q});
        end
        T=find(ok==median(ok));
        T=T(1); %take first proper time idxm T should be index of all the same lengths
        time=S.resp_mouseBack_tSec{T}(idx{T});
        time=time-time(1)+interval(1);
        %wut? use the index from just the last trial in the loop on the last , use that
        %for the time? will be very different from other times because the
        %timing is kinda irregular (sometimes finished 5.5 sometimes, 6.3
        %when should be 6. Get lots of discrepancies
    end
end

function [D,str,suspect,maxCorr]=clarifyAndCheck(D)
suspect=false;
str='';
maxCorr=-Inf;
% Make some changes to the DPXD that make the analysis easier to read;
if D.N==0
    suspect=true;
    return;
end
% Step 1, align time of traces to the start of trial
for t=1:D.N
    D.resp_mouseBack_tSec{t}=D.resp_mouseBack_tSec{t}-D.startSec(t);
    D.resp_mouseSide_tSec{t}=D.resp_mouseSide_tSec{t}-D.startSec(t);
end
% Step 2, remove offset from X value traces, because of monitor
% settings in the Half Dome setup, the left-x is 0, and the control
% computer starts at -1920. The Logitech mice are sampled on the
% control monitor.
for t=1:D.N
    D.resp_mouseBack_dxPx{t}=D.resp_mouseBack_dxPx{t}+1920;
    D.resp_mouseSide_dxPx{t}=D.resp_mouseSide_dxPx{t}+1920;
end
% Step 3, smooth the data N*16.6667 ms running average (3 60-Hz samples is 50 ms)
SMOOTHFAC=3;
for t=1:D.N
    D.resp_mouseBack_dxPx{t}=smooth(D.resp_mouseBack_dxPx{t},SMOOTHFAC)';
    D.resp_mouseBack_dyPx{t}=smooth(D.resp_mouseBack_dyPx{t},SMOOTHFAC)';
    D.resp_mouseSide_dxPx{t}=smooth(D.resp_mouseSide_dxPx{t},SMOOTHFAC)';
    D.resp_mouseSide_dyPx{t}=smooth(D.resp_mouseSide_dyPx{t},SMOOTHFAC)';
end
% Step 4, rename the mouse fields that code yaw (these should not
% change from session to session but to be extra cautious we're gonna
% assume nothing and figure out on a per file basis. Yaw is shared by
% the back and the side Logitech, determine what combination
% backdx,backdy,sizedx,sidedy has the most similar trace, these must
% have been the yaw axes. Do this for all trials in a file, the mouse may
% have been sitting still during a trial, and this method would fail if
% only that trial was regarded.
BdX=[];
BdY=[];
SdX=[];
SdY=[];
for t=1:D.N
    tSec=D.resp_mouseSide_tSec{t};
    idx=tSec>1 & tSec<max(tSec)-1;
    BdX=[BdX D.resp_mouseBack_dxPx{t}(idx)]; %#ok<AGROW>
    BdY=[BdY D.resp_mouseBack_dyPx{t}(idx)]; %#ok<AGROW>
    SdX=[SdX D.resp_mouseSide_dxPx{t}(idx)]; %#ok<AGROW>
    SdY=[SdY D.resp_mouseSide_dyPx{t}(idx)]; %#ok<AGROW>
end
if numel(unique(BdX))==1 || numel(unique(BdY))==1
    str='BackMouseDidNotWork';
    suspect=true;
    return;
end
if numel(unique(SdX))==1 || numel(unique(SdY))==1
    str='SideMouseDidNotWork';
    suspect=true;
    return;
end

if corr(BdX(:),SdX(:))>maxCorr;
    D.resp_mouseBackYaw=D.resp_mouseBack_dxPx;
    D.resp_mouseSideYaw=D.resp_mouseSide_dxPx;
    tempN=D.N; D=rmfield(D,'N'); D.N=tempN;
    str='yaw are BdX and SdX - OPTION 1';
    maxCorr=corr(BdX(:),SdX(:));
end
if corr(BdY(:),SdY(:))>maxCorr
    D.resp_mouseBackYaw=D.resp_mouseBack_dyPx;
    D.resp_mouseSideYaw=D.resp_mouseSide_dyPx;
    tempN=D.N; D=rmfield(D,'N'); D.N=tempN;
    str='yaw are BdY and SdY - OPTION 22';
    maxCorr=corr(BdY(:),SdY(:));
end
if corr(BdX(:),SdY(:))>maxCorr
    D.resp_mouseBackYaw=D.resp_mouseBack_dxPx;
    D.resp_mouseSideYaw=D.resp_mouseSide_dyPx;
    tempN=D.N; D=rmfield(D,'N'); D.N=tempN;
    str='yaw are BdX and SdY - OPTION 333';
    maxCorr=corr(BdY(:),SdY(:));
end
if corr(BdY(:),SdX(:))>maxCorr
    D.resp_mouseBackYaw=D.resp_mouseBack_dyPx;
    D.resp_mouseSideYaw=D.resp_mouseSide_dxPx;
    tempN=D.N; D=rmfield(D,'N'); D.N=tempN; %keep DPX struct syntax
    str='yaw are BdY and SdX - OPTION 4444';
    maxCorr=corr(BdY(:),SdY(:));
end
if maxCorr<0.8
    suspect=true;
    %   keyboard
end
if isempty(str)
    keyboard;
end

% Reinder: step 7, remove trials in which mice are not moving enough,
% i.e. if any of the axis is below threshold 1
D = RemoveStaticMouse(D,2,{'resp_mouseBack_dyPx','resp_mouseBack_dxPx',...
    'resp_mouseSide_dyPx','resp_mouseSide_dxPx'});
if D.N==0
    suspect=true;
    str='Zero trials left after static mouse check, removing file !!!';
    return;
end
end

function C=getMeanYawTracesPerMouse(C)
% calculate mean traces per mouse (pooled over sessions)
for i=1:numel(C)
    for v=1:C{i}.N
        % determine median length of trial, discard the trials that have a
        % different length. This should be rare but it is still better to use the
        % unequal length averaging. I don't know why that is currently commented
        % out, i must have had problems with that when i wrote it in Dec-2014. I'll
        % look into it again if the data is promising enough Jacob, 2015-05-18
        len=[];
        for tr=1:numel(C{i}.yaw{v})
            len(end+1)=numel(C{i}.yaw{v}{tr});
        end
        ok=find(len==ceil(median(len)));
        if isempty(ok)
            warning('no trial with correct length');
            continue
        end
        % [mn,n,sd]=dpxMeanUnequalLengthVectors(C{i}.preStimYaw{v},'align','end');
        for tr=1:numel(ok)
            Y(tr,:)=dpxMakeRow( C{i}.yaw{v}{ok(tr)} );
        end
        C{i}.yawMean{v}=mean(Y,1);
        C{i}.yawSEM{v}=std(Y,1)/sqrt(size(Y,1));
        C{i}.yawN{v}=size(Y,1);
        clear Y
        %   C{i}.preStimYawN{v}=n;
        %   C{i}.preStimYawSd{v}=sd;
        %  [mn,n,sd]=dpxMeanUnequalLengthVectors(C{i}.conStimYaw{v},'align','begin');
        %            C{i}.conStimYawMean{v}=mn;
        %   C{i}.conStimYawN{v}=n;
        %   C{i}.conStimYawSd{v}=sd;
    end
end
end

function C=addMeanMouse(C)
% Calculate a mean of all mice and add it as an additional mouse called
% 'MEAN'
nMice=numel(C);
C{nMice+1}=C{1};
for i=1:C{end}.N
    C{end}.mus{i}='MEAN';
    C{end}.yaw{i}={};
end
for v=1:C{end}.N
    Y={};
    for i=1:numel(C)-1
        Y{end+1}=C{i}.yawMean{v}; %#ok<AGROW>
    end
    [C{end}.yawMean{v}, n{v}, yawSTD{v}] =dpxMeanUnequalLengthVectors(Y);
    C{end}.yawSEM{v} = yawSTD{v}./sqrt(n{v});
end
end

function h=plotTraces(C,str)
% Plot the traces per speed, with colored areas to highlight the difference
% between left, static, and rightward stimulation
h = dpxFindFig(['TheWayOfTheMouse ' str]);
nMice=numel(C)-1; %minus the mean
for i=1:nMice
    [~,order]=sort(abs(C{i}.speed));
    subplot(ceil(nMice/3),3,i)
    tel=0;
    for v=order(:)'
        tel=tel+1;
        if C{i}.speed(v)<0
            Nleft=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            leftT=C{i}.time{v}(1:Nleft);
            leftDrift=C{i}.yawMean{v}(1:Nleft);
        elseif C{i}.speed(v)==0
            Nstat=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            statT=C{i}.time{v}(1:Nstat);
            statDrift=C{i}.yawMean{v}(1:Nstat);
        elseif C{i}.speed(v)>0
            Nright=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            riteT=C{i}.time{v}(1:Nright);
            riteDrift=C{i}.yawMean{v}(1:Nright);
        end
    end
    if exist('statT','var')
        minN=min([Nleft Nstat Nright]);
        leftT=leftT(1:minN);
        leftDrift=leftDrift(1:minN);
        statT=statT(1:minN);
        statDrift=statDrift(1:minN);
        riteT=riteT(1:minN);
        riteDrift=riteDrift(1:minN);
        % PLot the areas
        patch([leftT leftT(end:-1:1)],[statDrift leftDrift(end:-1:1)],'r','FaceAlpha',.1,'LineStyle','none');  hold on
        patch([riteT riteT(end:-1:1)],[statDrift riteDrift(end:-1:1)],'b','FaceAlpha',.1,'LineStyle','none');
        % Plot the lines
        plot(leftT,leftDrift,'LineStyle','-','LineWidth',2,'Color','r');
        plot(statT,statDrift,'LineStyle','-','LineWidth',2,'Color','k');
        plot(riteT,riteDrift,'LineStyle','-','LineWidth',2,'Color','b');
    else
        minN=min([Nleft Nright]);
        leftT=leftT(1:minN);
        leftDrift=leftDrift(1:minN);
        riteT=riteT(1:minN);
        riteDrift=riteDrift(1:minN);
        % PLot the areas
%           patch([leftT leftT(end:-1:1)],[riteDrift(end:-1:1) leftDrift(end:-1:1)],'r','FaceAlpha',.1,'LineStyle','none');  hold on
        % Plot the lines
        plot(leftT,leftDrift,'LineStyle','-','LineWidth',2,'Color','r'); hold on
        plot(riteT,riteDrift,'LineStyle','-','LineWidth',2,'Color','b');
    end
    %
    axis tight
    dpxText(C{i}.mus{1});
    dpxPlotHori(0,'k--');
    dpxPlotVert(0,'k--');
    xlabel('Time since motion onset (s)');
    ylabel('Yaw (a.u.)');
    %
    clear statX
end


end

function h=plotMeanTrace(C,str)
h = dpxFindFig(['TheMeanOfAllMice ' str]);

[~,order]=sort(abs(C.speed));
    tel=0;
    for v=order(:)'
        tel=tel+1;
        if C.speed(v)<0
            Nleft=min(numel(C.time{v}),numel(C.yawMean{v}));
            leftT=C.time{v}(1:Nleft);
            leftDrift=C.yawMean{v}(1:Nleft);
            leftSEM=C.yawSEM{v}(1:Nleft);
        elseif C.speed(v)==0
            Nstat=min(numel(C.time{v}),numel(C.yawMean{v}));
            statT=C.time{v}(1:Nstat);
            statDrift=C.yawMean{v}(1:Nstat);
            statSEM=C.yawSEM{v}(1:stat);
        elseif C.speed(v)>0
            Nright=min(numel(C.time{v}),numel(C.yawMean{v}));
            riteT=C.time{v}(1:Nright);
            riteDrift=C.yawMean{v}(1:Nright);
            riteSEM=C.yawSEM{v}(1:Nright);
            
        end
    end
    if exist('statT','var')
        minN=min([Nleft Nstat Nright]);
        leftT=leftT(1:minN);
        leftDrift=leftDrift(1:minN);
        statT=statT(1:minN);
        statDrift=statDrift(1:minN);
        riteT=riteT(1:minN);
        riteDrift=riteDrift(1:minN);
        % PLot the areas
        patch([leftT leftT(end:-1:1)],[statDrift leftDrift(end:-1:1)],'r','FaceAlpha',.1,'LineStyle','none');  hold on
        patch([riteT riteT(end:-1:1)],[statDrift riteDrift(end:-1:1)],'b','FaceAlpha',.1,'LineStyle','none');
        % Plot the lines
        plot(leftT,leftDrift,'LineStyle','-','LineWidth',2,'Color','r');
        plot(statT,statDrift,'LineStyle','-','LineWidth',2,'Color','k');
        plot(riteT,riteDrift,'LineStyle','-','LineWidth',2,'Color','b');
    else
        minN=min([Nleft Nright]);
        leftT=leftT(1:minN);
        leftDrift=leftDrift(1:minN);
        leftSEM=leftSEM(1:minN);
        riteT=riteT(1:minN);
        riteDrift=riteDrift(1:minN);
        riteSEM=riteSEM(1:minN);
        % PLot the areas
%         area(riteT,riteDrift+riteSEM,min(riteDrift),'FaceColor',[0.5 0.5 0.7]); hold on;
%         area(riteT,riteDrift,min(riteDrift-riteSEM),'FaceColor',[0.5 0.5 0.7]);
%         area(riteT,riteDrift-riteSEM,min(riteDrift-riteSEM),'FaceColor',[1 1 1]);
        patch([riteT riteT(end:-1:1)],[riteDrift+riteSEM riteDrift(end:-1:1)-riteSEM(end:-1:1)],[.5 .5 .7],'FaceAlpha',.5); hold on
        plot(riteT,riteDrift,'LineStyle','-','LineWidth',2,'Color','b');

        
%         area(leftT,leftDrift+leftSEM,min(leftDrift),'FaceColor',[0.7 0.5 0.5]); hold on;
%         area(leftT,leftDrift,min(leftDrift-leftSEM),'FaceColor',[0.7 0.5 0.5]);
%         area(leftT,leftDrift-leftSEM,min(leftDrift-leftSEM),'FaceColor',[1 1 1]);
        patch([leftT leftT(end:-1:1)],[leftDrift+leftSEM leftDrift(end:-1:1)-leftSEM(end:-1:1)],[.7 .5 .5],'FaceAlpha',.5);
        plot(leftT,leftDrift,'LineStyle','-','LineWidth',2,'Color','r'); hold on

        
    end
    %
    axis tight
    dpxText(C.mus{1});
    dpxPlotHori(0,'k--');
    dpxPlotVert(0,'k--');
    xlabel('Time since motion onset (s)');
    ylabel('Yaw (a.u.)');
    %
    clear statX

end


function C=getOffsetPerSecond(C)
nMice=numel(C);
for i=1:nMice
    [~,order]=sort(abs(C{i}.speed));
    tel=0;
    for v=order(:)'
        tel=tel+1;
        if C{i}.speed(v)<0
            Nleft=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            leftT=C{i}.time{v}(1:Nleft);
            leftDrift=C{i}.yawMean{v}(1:Nleft);
        elseif C{i}.speed(v)==0
            Nstat=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            statT=C{i}.time{v}(1:Nstat);
            statDrift=C{i}.yawMean{v}(1:Nstat);
        elseif C{i}.speed(v)>0
            Nright=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            riteT=C{i}.time{v}(1:Nright);
            riteDrift=C{i}.yawMean{v}(1:Nright);
        end
    end
    if exist('statT','var')
        minN=min([Nleft Nstat Nright]);
        leftT=leftT(1:minN);
        leftDrift=leftDrift(1:minN);
        statT=statT(1:minN);
        statDrift=statDrift(1:minN);
        riteT=riteT(1:minN);
        riteDrift=riteDrift(1:minN);
        C{i}.leftDriftPerSecond=sum(leftDrift-statDrift)/(leftT(end)-leftT(1));
        C{i}.rightDriftPerSecond=sum(riteDrift-statDrift)/(leftT(end)-leftT(1));
    else
        minN=min([Nleft Nright]);
        leftT=leftT(1:minN);
        leftDrift=leftDrift(1:minN);
        riteT=riteT(1:minN);
        riteDrift=riteDrift(1:minN);
        C{i}.leftDriftPerSecond=sum(leftDrift)/(leftT(end)-leftT(1));
        C{i}.rightDriftPerSecond=sum(riteDrift)/(riteT(end)-riteT(1));
    end
end
end

function plotDriftScatter(C,titleString)
dpxFindFig(['DriftScatter' titleString]);
x=[];
y=[];
for i=1:numel(C)-1 % don't include the pooled mouse
    x(i)=C{i}.leftDriftPerSecond;
    y(i)=C{i}.rightDriftPerSecond;
end
dpxScatStat(x,y,'test','ttest');
xlabel('Speed during left - speed during static (a.u/second)');
ylabel('Speed during right - speed during static (a.u/second)');
end


function plotAllYawToCheckClipping(C,titleString)
dpxFindFig(['YawBreaker' titleString]);
for i=1:numel(C)
    subplot(ceil(numel(C)/5),5,i);
    for s=1:numel(C{i}.yawRaw)
        for t=1:numel(C{i}.yawRaw{s})
            plot(C{i}.yawRaw{s}{t}(1:2:end),'Color',[0.1 0.1 0.1 ]);
            hold on;
        end
    end
    dpxYaxis(-1080/2,1080/2);
    dpxPlotHori(500,'r-');
    dpxPlotHori(-500,'r-');
end
end


function [data Av Stdev RemData] = RemoveStaticMouse(data,varargin)
% testing the single trials for non-moving mice.
% non-moving is defined by a certain Standard deviation over a single
% trial.
% INPUT:
% data = mice half dome data
% varargin = threshold (default is 2)
% varargin 2 = resp str (default is back X)

if nargin>1;
    threshold = varargin{1};
    if nargin==3;
        resp    = varargin{2};
    end
else
    threshold = 2;
    resp = 'resp_mouseBack_dxPx';
end
for r = 1:numel(resp)
    
    tempD = OnsetLength(data,resp{r}); %get data from stimulus motion onset.
    Av = zeros(tempD.N,1);
    Stdev = zeros(tempD.N,1);
    StaticTr = zeros(r,tempD.N);
    
    
    for tr=1:tempD.N
        Av(tr) = mean(tempD.(resp{r}){tr});
        Stdev(tr) = (std(tempD.(resp{r}){tr}));
        if Stdev(tr) < threshold
            StaticTr(r,tr)=1;
        end
    end
end
StaticTr=sum(StaticTr,1);

RemTr = find(StaticTr~=0);

[data RemData] = dpxdRemoveTrial(data,RemTr);

disp(['removed ' num2str(numel(RemTr)) '/' num2str(tempD.N) ' trials for being below motion threshold ' num2str(threshold) ', from mouse: ' tempD.exp_subjectId{1} ]);

end

function data=OnsetLength(data,resp)
% get data from the analytical usefull period in the trial, i.e. from -.5
% till 2, (from -30 till frame 180; zero points are stimulus motion onset)

for i=1:data.N
    data.(resp){i} = data.(resp){i}(end-209:end);
end
end

function [Cphi Cihp] = scatterdiverging(Cphi,Cihp)
if ~isempty(findobj('type','figure'))
    h=figure(numel(findobj('type','figure'))+1);
else
    h=figure;
end
figure(h);
hold on;

Marker={'+','o','*','.','x','s','d','^','v','>','<','p','h'};
for c=1:numel(Cphi)
    for s=1:numel(Cphi{c}.time)
        movingTime = find(Cphi{c}.time{s}>0.5);
        if max(movingTime)>numel(Cphi{c}.yawMean{s})
            tooMuch = movingTime>numel(Cphi{c}.yawMean{s});
            movingTime(tooMuch) = [];
        end
        Cphi{c}.Moved{s} = mean(Cphi{c}.yawMean{s}(movingTime));
    end
    phiMoved(1,c) = Cphi{c}.Moved{1};
    phiMoved(2,c) = Cphi{c}.Moved{2};
    
%     plot(phiMoved(1,c),phiMoved(2,c),Marker{c});
%     leg{c} = Cphi{c}.mus{1};
end
[phiMoved,iSort] = sort(phiMoved,1);
plot(phiMoved(1,:),phiMoved(2,:),'bo')

for e=1:numel(Cphi)
    Cphi{e}.Moved{1} = phiMoved(1,e); %for export
    Cphi{e}.Moved{2} = phiMoved(2,e);
end

for c=1:numel(Cihp)
    for s=1:numel(Cihp{c}.time)
       movingTime = find(Cihp{c}.time{s}>0.5);
        if max(movingTime)>numel(Cihp{c}.yawMean{s})
            tooMuch = movingTime>numel(Cihp{c}.yawMean{s});
            movingTime(tooMuch) = [];
        end
        Cihp{c}.Moved{s} = mean(Cihp{c}.yawMean{s}(movingTime));
    end
    ihpMoved(1,c) = Cihp{c}.Moved{1};
    ihpMoved(2,c) = Cihp{c}.Moved{2};
%     plot(ihpMoved(1,c),ihpMoved(2,c),Marker{c},'color',[1 0 0]);
%     leg{c} = Cphi{c}.mus{1};
end


for s=1:size(iSort,2)
 ihpMoved(:,s)=ihpMoved(iSort(:,s),s);
end
plot(ihpMoved(1,:),ihpMoved(2,:),'rs')

for e=1:numel(Cihp)
    Cihp{e}.Moved{1} = ihpMoved(1,e); %for export
    Cihp{e}.Moved{2} = ihpMoved(2,e);
end

xlabel('amount of motion for stimulus motion A');
ylabel('amount of motion for stimulus motion B');
legend('Phi','reversed Phi')
% legend(leg)
x=[-20:20];y=x; plot(x,y,'-','color',[.5 .5 .5]);

end

function flipsplot(Cphi,Cihp,flip)
h = dpxFindFig(['Flip vs motion divergence']);

figure(h);
hold on;

plot(flip,Cphi{end}.Moved{2}-Cphi{end}.Moved{1},'ob')

plot(flip,Cihp{end}.Moved{2}-Cihp{end}.Moved{1},'sr')

legend({'phi'},{'Revphi'});

end


