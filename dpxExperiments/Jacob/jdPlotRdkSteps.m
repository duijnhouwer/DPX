function jdPlotRdkSteps(DPXD,maxDtFrames,zoom)
    
    % function to plot DX-DY-DT histograms from the data stored by
    % dpxStimRdkStore
    
    if ~exist('maxDtFrames','var') || isempty(maxDtFrames)
        maxDtFrames=3; % steps
    end
    if ~exist('zoom','var') || isempty(zoom)
        zoom=0;
    end
    
    fieldnames=dpxdMatchFieldnames(DPXD,'_xyt');
    if numel(fieldnames)==0
        error('No dotpos data stored in the DPXD');
    end
    if DPXD.N>1
        error('Designed to plot only one trial. Split the DPXD.');
    end
    xyt=cell(1000,1);
    for fi=1:numel(fieldnames)
        pos=DPXD.(fieldnames{fi}){1};
        for flip=1:size(pos,3)
            x=pos(1,:,flip);
            y=pos(2,:,flip);
            ok=~isnan(x)&~isnan(y);
            xyt{flip}=[xyt{flip} [x(ok); y(ok)]];
        end
    end
    xyt(cellfun(@isempty,xyt))=[];
    plotVisibleDotsPerFrame(xyt);

    % xyt=removeOverlap(xyt,1);
    dxdydt=getSteps(xyt,maxDtFrames);
    % percentage of conform the set speed
    P=getPercentageConformSetSpeed(dxdydt,DPXD.rdk_pxPerFrame);
    %
    ttl=[DPXD.treatment_str{1} ' ' num2str(DPXD.rdk_cohereFrac*100) '% coherence'];
    cpsFindFig(ttl);
    if zoom==0
        limits=getMinMaxSteps(dxdydt);
        plotDxDyDt(dxdydt,limits,100,50,P);
    else
        limits.maxDx=zoom(1)/2;
        limits.minDx=-zoom(1)/2;
        limits.maxDy=zoom(end)/2;
        limits.minDy=-zoom(end)/2;
        plotDxDyDt(dxdydt,limits,100,100,P);
    end
    title(ttl);
end

function  xyt=removeOverlap(xyt,marginPx)
    for i=1:numel(xyt)
        X=xyt{i}(1,:);
        Y=xyt{i}(2,:);
        nDots=numel(X);
        overlap=false(1,nDots);
        for d=1:nDots-1
            for e=d+1:nDots
                if abs(X(d)-X(e))<marginPx && abs(Y(d)-Y(e))<marginPx
                    overlap(e)=true;
                end
            end
        end
        %jdProp(overlap)
        xyt{i}(:,overlap)=[];
    end
end

function plotVisibleDotsPerFrame(xyt)
    cpsFindFig('plotVisibleDotsPerFrame');
    time=1:numel(xyt);
    n=nan(size(time));
    for t=time(:)'
        n(t)=size(xyt{t},2);
    end
    plot(time,n);
    xlabel('frame');
    ylabel('nDots');
    cpsText(num2str(mean(n)));
end


function dxdydt=getSteps(xyt,maxDtFrames)
    dxdydt=cell(maxDtFrames,1);
    for dt=1:maxDtFrames
        dx=[];
        dy=[];
        tel=0;
        for startT=1:dt
            frame1=xyt{startT};
            for f=startT+dt:dt:numel(xyt)
                frame2=xyt{f};
                [newdx,newdy]=getDxDy(frame1,frame2);
                dx=[dx newdx];
                dy=[dy newdy];
                frame1=frame2;
                tel=tel+1;
            end
        end
        disp(['dt total comparisons: ' num2str(tel)]);
        dxdydt{dt}=[dx;dy];
    end
end

function [dx,dy]=getDxDy(a,b)
    dx=[];
    dy=[];
    for i=1:size(b,2)
        dx=[dx b(1,i)-a(1,:)];
        dy=[dy b(2,i)-a(2,:)];
    end
end

function L=getMinMaxSteps(dxdydt)
    L.maxDx=-Inf;
    L.minDx=Inf;
    L.maxDy=-Inf;
    L.minDy=Inf;
    for i=1:numel(dxdydt)
        m=max(dxdydt{i}(1,:));
        if m>L.maxDx
            L.maxDx=m;
        end
        m=max(dxdydt{i}(2,:));
        if m>L.maxDy
            L.maxDy=m;
        end
        m=min(dxdydt{i}(1,:));
        if m<L.minDx
            L.minDx=m;
        end
        m=min(dxdydt{i}(2,:));
        if m<L.minDy
            L.minDy=m;
        end
    end
end

function  P=getPercentageConformSetSpeed(dxdydt,pxPerFrame)
    % only works for rightward motion
    P=zeros(numel(dxdydt),3);
    margin=0.0001;
    for idt=1:numel(dxdydt)
        xStep=idt*pxPerFrame;
        x=dxdydt{idt}(1,:);
        y=dxdydt{idt}(2,:);
        inbin=y<margin & y>-margin & x<xStep+margin & x>xStep-margin;
        P(idt,1)=sum(inbin);
        P(idt,2)=numel(inbin);
        P(idt,3)=jdProp(inbin)*100;
    end
end

function plotDxDyDt(dxdydt,L,hBins,vBins,P)
    edges{1}=linspace(L.minDx,L.maxDx,hBins);
    edges{2}=linspace(L.minDy,L.maxDy,vBins);
    nSteps=numel(dxdydt);
    rows=ceil(sqrt(nSteps));
    cols=ceil(sqrt(nSteps));
    for i=1:nSteps
        subplot(rows,cols,i);
        X=dxdydt{i}(1,:);
        Y=dxdydt{i}(2,:);
        n=hist3([Y(:) X(:)],'Edges',edges);
        binsX=edges{1}(1:end-1)+mean(diff(edges{1}))/2;
        binsY=edges{2}(1:end-1)+mean(diff(edges{2}))/2;
        imagesc(binsX,binsY,n);
        colorbar
        set(gca,'YDir','Normal')
        set(gca,'TickDir','out');
        str={};
        str{1}=['dt = ' num2str(i) ' (fr)'];
        str{end+1}=['N = ' num2str(sum(n(:)))];
        str{end+1}=['peak = ' num2str(max(n(:)))];
        str{end+1}=num2str(P(i,3));
        cpsText(str,'Color','m');
        if L.maxDx-L.minDx == L.maxDy-L.minDy
            axis square;
            cpsRefLine('+','m--');
        end
    end
   % cpsUnifyAxes('c');
    xlabel('dx (px)');
    ylabel('dy (px)');
end
