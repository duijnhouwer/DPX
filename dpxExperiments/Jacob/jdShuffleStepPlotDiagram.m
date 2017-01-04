function info=jdShuffleStepPlotDiagram(nSteps)
    suppressPlot=nSteps<0;
    nSteps=abs(nSteps);
    info=calcInfo(nSteps);
    speed=1/4;
    DTs=diff(nchoosek(1:nSteps+1,2),[],2);
    frames=ones(size(DTs));
    for i=2:numel(DTs);
        if DTs(i)<DTs(i-1)
            frames(i)=frames(i-1)+1;
        else
            frames(i)=frames(i-1);
        end
    end
    
    %nFrames=nSteps+1;
    XT=cell(1,nSteps+1);
    for i=1:numel(DTs)
        XT{frames(i)}=[XT{frames(i)} i];
        XT{frames(i)+DTs(i)}=[XT{frames(i)+DTs(i)} i+speed*DTs(i)];
    end
    if ~suppressPlot
        plotXt(XT,speed,info);
    end
    
end

function out=calcInfo(nSteps)
    out.nSteps=nSteps;
    out.Npfr=nSteps; %
    out.Kconform=nchoosek(nSteps+1,2);
    out.Ntot=out.Kconform*2;
    out.nFr=nSteps+1;
    out.Ktot=0;
    for i=1:out.nFr
        out.Ktot=out.Ktot+out.Npfr*(out.Ntot-i*out.Npfr);
    end
    out.Kspurious=out.Ktot-out.Kconform;
end
        

function [K,spurious]=plotXt(XT,speed,infoStruct)
    cpsFindFig(mfilename);
    clf;
    K=0;
    spurious=[];
    for twice=0:1 % loop twice to plot speed-conform lines on top
        for fr1=1:numel(XT)
            x1=XT{fr1};
            for fr2=fr1+1:numel(XT)
                x2=XT{fr2};
                for i=1:numel(x1)
                    for j=1:numel(x2)
                        if twice==0 && round(diff([x1(i) x2(j)])/diff([fr1 fr2])*10^12)~=round(speed*10^12)
                            plot([x1(i) x2(j)],[fr1 fr2]-1,'-','Color',[0 0 0  .18]);
                        elseif twice==1 && round(diff([x1(i) x2(j)])/diff([fr1 fr2])*10^12)==round(speed*10^12)
                            plot([x1(i) x2(j)],[fr1 fr2]-1,'ko-','MarkerEdgeColor','k','MarkerFaceColor','k','LineWidth',2);
                        end
                    end
                    hold on
                end
            end
        end
    end
    set(gca,'YDir','reverse')
    set(gca,'XAxisLocation','top');
    set(gca,'TickDir','out');
    set(gca,'YTick',0:numel(XT)-1);
    box off;
    ylabel('T');
    xlabel('X');
    
    str={};
    fields=fieldnames(infoStruct)
    for i=1:numel(fields)
        str{i}=[fields{i} ' = ' num2str(infoStruct.(fields{i}))];
    end
    cpsText(str,'Location','BottomRight');
end



