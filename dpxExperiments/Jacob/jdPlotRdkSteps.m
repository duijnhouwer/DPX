function jdPlotRdkSteps(DPXD,maxDtFrames)
    
    % function to plot DX-DY-DT histograms from the data stored by
    % dpxStimRdkStore
    
    if nargin==1
        maxDtFrames=3; % steps
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
    dxdydt=getSteps(xyt,maxDtFrames);
    limits=getMinMaxSteps(dxdydt);
    plotDxDyDt(dxdydt,limits,100,50);
end


function dxdydt=getSteps(xyt,maxDtFrames)
    dxdydt=cell(maxDtFrames,1);
    for dt=1:maxDtFrames
        dx=[];
        dy=[];
        for startT=1:maxDtFrames-1
            frame1=xyt{startT};
            for f=startT+dt:dt:numel(xyt)
                frame2=xyt{f};
                [newdx,newdy]=getDxDy(frame1,frame2);
                dx=[dx newdx];
                dy=[dy newdy];
            end
        end
        dxdydt{dt}=[dx;dy];
    end
end

function [dx,dy]=getDxDy(a,b)
    dx=[];
    dy=[];
    for i=1:size(a,2)
        dx=[dx a(1,i)-b(1,:)];
        dy=[dy a(2,i)-b(2,:)];
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

function plotDxDyDt(dxdydt,L,hBins,vBins)
    cpsFindFig(mfilename);
    edges{1}=linspace(L.minDx,L.maxDx,hBins);
    edges{2}=linspace(L.minDy,L.maxDy,vBins);
    nSteps=numel(dxdydt);
    rows=ceil(sqrt(nSteps));
    cols=ceil(sqrt(nSteps));
    for i=1:nSteps
        subplot(rows,cols,i);
        n=hist3(dxdydt{i}','Edges',edges);
        imagesc(edges{1},edges{2},n);
        cpsText(['dt = ' num2str(i)],'Color','m');
    end
    xlabel('dx (deg)');
    ylabel('dy (deg)');
end
