function files=jdDpxExpHalfDomeRdkAnalysis(files)
    if nargin==0
        files=dpxUIgetfiles;
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
    E=dpxdSplit(E,'exp_subjectId');
    C={};
    for i=1:numel(E)
        C{end+1}=getSpeedCurves(E{i}); %#ok<AGROW>
    end
    % calculate mean traces per mouse (pooled over sessions)
    C=getMeanYawTracesPerMouse(C);
    % add a virtual mouse that is the mean of all others
    C=addMeanMouse(C);
    % plot the curves, panel per mouse
    plotTraces(C);
end


function C=getSpeedCurves(D)
    S{1}=dpxdSubset(D,D.rdk_aziDps<0);
    S{2}=dpxdSubset(D,D.rdk_aziDps==0);
    S{3}=dpxdSubset(D,D.rdk_aziDps>0);
    C.speed=[];
    for i=1:numel(S)
        C.speed(i)=S{i}.rdk_aziDps(1);
        C.mus{i}=S{i}.exp_subjectId{1};
        preStimYaw=getYawTrace(S{i},[-.5 0]);
        [C.yaw{i},C.time{i}]=getYawTrace(S{i},[-.5 2]);
        % subtract the baseline speed
        for t=1:numel(preStimYaw)
            C.yaw{i}{t}=C.yaw{i}{t}-nanmean(preStimYaw{t});
        end
    end
    C.N=numel(C.speed);
    if ~dpxdIs(C)
        error('not a valid DPXD!');
    end
    function [yaw,time]=getYawTrace(S,interval)
        yaw=cell(1,S.N);
        for t=1:S.N
            from=interval(1)+S.rdk_motStartSec(t);
            till=interval(2)+S.rdk_motStartSec(t);
            idx=S.resp_mouseBack_tSec{t}>=from & S.resp_mouseBack_tSec{t}<till;
            idx=idx(:)'; % make sure is row
            yaw{t}=mean([S.resp_mouseSideYaw{t}(idx);S.resp_mouseBackYaw{t}(idx)],1);
        end
        time=S.resp_mouseBack_tSec{t}(idx);
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
    % Step 3, smooth the data 50 ms running average (3 60-Hz samples)
    for t=1:D.N
            D.resp_mouseBack_dxPx{t}=smooth(D.resp_mouseBack_dxPx{t},30)';
            D.resp_mouseBack_dyPx{t}=smooth(D.resp_mouseBack_dyPx{t},30)';
            D.resp_mouseSide_dxPx{t}=smooth(D.resp_mouseSide_dxPx{t},30)';
            D.resp_mouseSide_dyPx{t}=smooth(D.resp_mouseSide_dyPx{t},30)';
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
    for i=1:numel(C)
        for v=1:C{i}.N
            % determine median length of trace, discard the rest
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
    nMice=numel(C);
    cols='kbbggrr';
    wid=[1 1.5 1.5 2 2 2.5 2.5];
    for i=1:nMice
        [~,order]=sort(abs(C{i}.speed));
        subplot(nMice,1,i)
        tel=0;
        for v=order(:)'
            tel=tel+1;
            if C{i}.speed(v)<0
                lStyle='--'; else lStyle='-';
            end 
            N=min(numel(C{i}.time{v}),numel(C{i}.yawMean{v}));
            plot(C{i}.time{v}(1:N),C{i}.yawMean{v}(1:N),'LineStyle',lStyle,'LineWidth',wid(tel),'Color',cols(tel));
            hold on
        end
        dpxPlotHori;
        dpxPlotVert;
    end
    
end

