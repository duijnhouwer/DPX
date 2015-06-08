function files=jdDpxExpHalfDomeRdkAnalysis(files)
    if nargin==0
        files=dpxUIgetfiles;
        if isempty(files)
            return;
        end
    end
    E={};
    for i=1:numel(files)
        D=dpxdLoad(files{i});
        [D,str,suspect,maxCorr]=clarifyAndCheck(D);
        if ~suspect
            E{end+1}=D;
        else
            disp(['clarifyAndCheck said ' str ' but correlation (' num2str(maxCorr) ') is below threshold...']);
            disp([' ---> skipping file : ' files{i} ]);
        end
        clear D;
    end
    E=dpxdMerge(E);
    E=dpxdSplit(E,'exp_subjectId'); % split per mouse
    C={};
    for i=1:numel(E) % for each mouse, get the curves
        C{end+1}=getSpeedCurves(E{i}); %#ok<AGROW>
    end
    plotAllYawToCheckClipping(C);
    % calculate mean traces per mouse (pooled over sessions)
    C=getMeanYawTracesPerMouse(C);
    % add a virtual mouse that is the mean of all others
    C=addMeanMouse(C);
    %
    C=getOffsetPerSecond(C);
    % plot the curves, panel per mouse
    plotTraces(C);
    % plot the drifts relative to stat
    plotDriftScatter(C);
end


function C=getSpeedCurves(D)
    if false
        S{1}=dpxdSubset(D,D.rdk_aziDps<0);
        S{2}=dpxdSubset(D,D.rdk_aziDps==0);
        S{3}=dpxdSubset(D,D.rdk_aziDps>0);
    elseif true
        S{1}=dpxdSubset(D,D.rdk_aziDps==-10|D.rdk_aziDps==-40);
        S{2}=dpxdSubset(D,D.rdk_aziDps==0);
        S{3}=dpxdSubset(D,D.rdk_aziDps==10|D.rdk_aziDps==40);
    end
    C.speed=[];
    for i=1:numel(S)
        C.speed(i)=S{i}.rdk_aziDps(1);
        C.mus{i}=S{i}.exp_subjectId{1};
        preStimYaw=getYawTrace(S{i},[-.5 0]);
        [C.yawRaw{i},C.time{i}]=getYawTrace(S{i},[-.5 2]);
        % subtract the baseline speed
        for t=1:numel(preStimYaw)
            C.yaw{i}{t}=C.yawRaw{i}{t}-nanmean(preStimYaw{t});
        end
    end
    C.N=numel(C.speed);
    if ~dpxdIs(C)
        error('not a valid DPXD!');
    end
    %- sub function
    function [yaw,time]=getYawTrace(S,interval)
        yaw=cell(1,S.N);
        for tt=1:S.N
            from=interval(1)+S.rdk_motStartSec(tt);
            till=interval(2)+S.rdk_motStartSec(tt);
            idx=S.resp_mouseBack_tSec{tt}>=from & S.resp_mouseBack_tSec{tt}<till;
            idx=idx(:)'; % make sure is row
            yaw{tt}=mean([S.resp_mouseSideYaw{tt}(idx);S.resp_mouseBackYaw{tt}(idx)],1);
        end
        time=S.resp_mouseBack_tSec{tt}(idx);
        time=time-time(1)+interval(1);
    end
end



function [D,str,suspect,maxCorr]=clarifyAndCheck(D)
    suspect=false;
    % Make some changes to the DPXD that make the analysis easier to read;
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
    maxCorr=-Inf;
    if corr(BdX(:),SdX(:))>maxCorr;
        D.resp_mouseBackYaw=D.resp_mouseBack_dxPx;
        D.resp_mouseSideYaw=D.resp_mouseSide_dxPx;
        str='yaw are BdX and SdX - OPTION 1';
        maxCorr=corr(BdX(:),SdX(:));
    end
    if corr(BdY(:),SdY(:))>maxCorr
        D.resp_mouseBackYaw=D.resp_mouseBack_dyPx;
        D.resp_mouseSideYaw=D.resp_mouseSide_dyPx;
        str='yaw are BdY and SdY - OPTION 22';
        maxCorr=corr(BdY(:),SdY(:));
    end
    if corr(BdX(:),SdY(:))>maxCorr
        D.resp_mouseBackYaw=D.resp_mouseBack_dxPx;
        D.resp_mouseSideYaw=D.resp_mouseSide_dyPx;
        str='yaw are BdX and SdY - OPTION 333';
        maxCorr=corr(BdY(:),SdY(:));
    end
    if corr(BdY(:),SdX(:))>maxCorr
        D.resp_mouseBackYaw=D.resp_mouseBack_dyPx;
        D.resp_mouseSideYaw=D.resp_mouseSide_dxPx;
        str='yaw are BdY and SdX - OPTION 4444';
        maxCorr=corr(BdY(:),SdY(:));
    end
    if maxCorr<0.8
        suspect=true;
        keyboard
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
            ok=find(len==median(len));
            if isempty(ok)
                error('no trial with correct length');
            end
            % [mn,n,sd]=dpxMeanUnequalLengthVectors(C{i}.preStimYaw{v},'align','end');
            for tr=1:numel(ok)
                Y(tr,:)=dpxMakeRow( C{i}.yaw{v}{ok(tr)} );
            end
            C{i}.yawMean{v}=mean(Y,1);
            C{i}.yawSEM{v}=std(Y,1)/sqrt(size(Y,1));
            C{i}.yawN{v}=size(Y,1);
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
    nMice=numel(C);
    C{nMice+1}=C{1};
    for i=1:C{end}.N
        C{end}.mus{i}='MEAN';
        C{end}.yaw{i}={};
    end
    for v=1:C{end}.N
        Y={};
        for i=1:numel(C)
            Y{end+1}=C{i}.yawMean{v}; %#ok<AGROW>
        end
        C{end}.yawMean{v}=dpxMeanUnequalLengthVectors(Y);
    end
end

function plotTraces(C)
    findfig('TheWayOfTheMouse');
    nMice=numel(C);
    for i=1:nMice
        [~,order]=sort(abs(C{i}.speed));
        subplot(ceil(nMice/3),3,i)
        tel=0;
        for v=order(:)'
            tel=tel+1;
            if C{i}.speed(v)<0
                Nleft=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
                leftX=C{i}.time{v}(1:Nleft);
                leftY=C{i}.yawMean{v}(1:Nleft);
            elseif C{i}.speed(v)==0
                Nstat=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
                statX=C{i}.time{v}(1:Nstat);
                statY=C{i}.yawMean{v}(1:Nstat);
            elseif C{i}.speed(v)>0
                Nright=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
                riteX=C{i}.time{v}(1:Nright);
                riteY=C{i}.yawMean{v}(1:Nright);
            end
        end
        minN=min([Nleft Nstat Nright]);
        leftX=leftX(1:minN);
        leftY=leftY(1:minN);
        statX=statX(1:minN);
        statY=statY(1:minN);
        riteX=riteX(1:minN);
        riteY=riteY(1:minN);
        plot(leftX,leftY,'LineStyle','-','LineWidth',2,'Color','r');        hold on
        plot(statX,statY,'LineStyle','-','LineWidth',2,'Color','k');
        plot(riteX,riteY,'LineStyle','-','LineWidth',2,'Color','b');
        patch([leftX leftX(end:-1:1)],[statY leftY(end:-1:1)],'r','FaceAlpha',.1,'LineStyle','none');
        patch([riteX riteX(end:-1:1)],[statY riteY(end:-1:1)],'b','FaceAlpha',.1,'LineStyle','none');
        axis tight
        dpxText(C{i}.mus{1});
        dpxPlotHori;
        dpxPlotVert;
        xlabel('Time since motion onset (s)');
        ylabel('Yaw (a.u.)');
    end
    
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
                leftX=C{i}.time{v}(1:Nleft);
                leftY=C{i}.yawMean{v}(1:Nleft);
            elseif C{i}.speed(v)==0
                Nstat=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
                statX=C{i}.time{v}(1:Nstat);
                statY=C{i}.yawMean{v}(1:Nstat);
            elseif C{i}.speed(v)>0
                Nright=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
                riteX=C{i}.time{v}(1:Nright);
                riteY=C{i}.yawMean{v}(1:Nright);
            end
        end
        minN=min([Nleft Nstat Nright]);
        leftX=leftX(1:minN);
        leftY=leftY(1:minN);
        statX=statX(1:minN);
        statY=statY(1:minN);
        riteX=riteX(1:minN);
        riteY=riteY(1:minN);
        C{i}.leftDriftPerSecond=sum(leftY-statY)/(statX(end)-statX(1));
        C{i}.rightDriftPerSecond=sum(riteY-statY)/(statX(end)-statX(1));
    end
end


function plotDriftScatter(C)
    dpxFindFig('DriftScatter');
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


function plotAllYawToCheckClipping(C)
    findfig('YawBreaker');
    for i=1:numel(C)
        subplot(ceil(numel(C)/5),5,i);
        for s=1:numel(C{i}.yawRaw)
            for t=1:numel(C{i}.yawRaw{s})
                plot(C{i}.yawRaw{s}{t}(1:2:end),'Color',[0 0 0 .01]);
                hold on;
            end
        end
        jdYaxis(-1080/2,1080/2);
        jdPlotHori(500,'r-');
        jdPlotHori(-500,'r-');
    end
end






