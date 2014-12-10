function files=jdDpxExpHalfDomeRdkAnalysis(files)
    if nargin==0
        files=dpxUIgetfiles;
    end
    E={};
    for i=1:numel(files)
        D=dpxdLoad(files{i});
        [D,suspect]=elucidateAndCheck(D);
        if ~suspect
            E{end+1}=D;
        end
        clear D;
    end
    E=dpxdMerge(E);
    E=dpxdSplit(E,'exp_subjectId');
    C={};
    for i=1:numel(E)
        C{end+1}=getSpeedCurves(E{i}); %#ok<AGROW>
    end
        
    % calculate mean traces per mouse (pooled of sessions)
    C=getMeanCurvesPerMouse(C);
    keyboard
end


function C=getSpeedCurves(D)
    S=dpxdSplit(D,'rdk_aziDps');
    C.speed=[];
    for i=1:numel(S)
        C.speed(i)=S{i}.rdk_aziDps(1);
        C.mus{i}=S{i}.exp_subjectId{1};
        [C.preStimYaw{i},C.preTime{i}]=getYawTrace(S{i},[-1 0]);
        [C.conStimYaw{i},C.conTime{i}]=getYawTrace(S{i},[0 1]);
    end
    C.N=numel(C.speed);
    if ~dpxdIs(C)
        error('not a valid DPXD!');
    end
end

function [yaw,time]=getYawTrace(S,interval)
    yaw=cell(1,S.N);
    for t=1:S.N
        from=interval(1)+S.rdk_motStartSec(t);
        to=interval(2)+S.rdk_motStartSec(t);
        idx=S.resp_mouseBack_tSec{t}>=from & S.resp_mouseBack_tSec{t}<to;
        idx=idx(:)'; % make sure is row
       	yaw{t}=mean([S.resp_mouseSideYaw{t}(idx);S.resp_mouseBackYaw{t}(idx)],1);
    end 
    time=S.resp_mouseBack_tSec{t}(idx);
    time=time-time(1)+interval(1);
end

function [D,suspect]=elucidateAndCheck(D)
    suspect=false;
    % MAke some changes to the DPXD that make the analysis easier to read;
    % Step 1, align time of traces tmo start of trial
    for t=1:D.N
        D.resp_mouseBack_tSec{t}=D.resp_mouseBack_tSec{t}-D.startSec(t);
        D.resp_mouseSide_tSec{t}=D.resp_mouseSide_tSec{t}-D.startSec(t);
    end
    % Step 2, remove offset from X value traces, because of monitor
    % settings in the Half Dome setup, the left-x is 0, and the control
    % computer starts at -1920. The Logitechs are sampled on the control
    % monitor.
    for t=1:D.N
        D.resp_mouseBack_dxPx{t}=D.resp_mouseBack_dxPx{t}+1920;
        D.resp_mouseSide_dxPx{t}=D.resp_mouseSide_dxPx{t}+1920;
    end
    % Step 3, rename the mouse fields that code yaw (these should not
    % change from session to session but to be extra cautious we're gonna
    % assume nothing and figure out on a per file basis. Yaw is shared by
    % the back and the side mouse, determine whether the what combination
    % backdx,backdy,sizedx,sidedy has the most similar trace, these must
    % have been the yaw axes. Do this for all trials in a file, the Mus may
    % have been sitting still during a trial, and this method would fail
    % if only that trial was regarded.
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
    maxCorr;
    if maxCorr<0.95
        suspect=true;
    end
end


function C=getMeanCurvesPerMouse(C)
    for i=1:numel(C)
        for v=1:C{i}.N
            [mn,n,sd]=dpxMeanUnequalLengthVectors(C{i}.preStimYaw{v});
            C{i}.preStimYawMean{v}=mn;
            C{i}.preStimYawN{v}=n;
            C{i}.preStimYawSd{v}=sd;
        end
    end   
    keyboard;
end