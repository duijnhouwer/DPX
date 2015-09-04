
function jdSpeedContrast
%    plotExample;
    global fitopts
    models={'EoffIsMinusIoff'};%,'EoffZero'}%,''};EoffZero EoffIsMinusIoff OneOffOneSig
    for i=1:numel(models)
        fitopts=models{i};
        M.(fitopts)=[ KrekelbergVanWezelAlbright2006 ]; % packHunterBorn2005 rodmanAlbright1987 KrekelbergVanWezelAlbright2006
    end
    
    %compareModels(M);%{'EoffIsMinusIoff','EoffZero'});
end

function plotExample
    %
    xSecCont=[.8 .2];
    
    pars.Ai=15;
    pars.Ax=30;
    pars.ContPow=.2;
    pars.Eoff=5;
    pars.Esig=30;
    pars.Ioff=5;
    pars.Isig=30;
    pars.Ro=5;
    pars=jdStructToArray(pars); % AVAILABLE ON KLAB SYSTEM, COPY FROM THERE IF NEEDED 2015-09-04 jacob
    dpxFindFig('Example')
    for i=1:1
        if i==1
            h(1)=subplot(1,2,1,'align');
            stl='-';
        else
            h(2)=subplot(2,2,3,'align');
            stl='--';
        end
        maxV=12;
        [R,v,~,E,I]=speedContrastResponseCurve(...
            'dpsDom',[-(2.^(maxV:-.25:0)) 0 2.^(0:.25:maxV)] ...
            ,'contDom', xSecCont(i)...
            ,'parList', pars ...
            ,'mods','EoffIsMinusIoff' ... EoffIsMinusIoff EoffZero
            ,'logDps',true);
        
        plot(v,E,stl,'LineWidth',2,'Color',[1 0 0 1]);  hold on
        plot(v,I,stl,'LineWidth',2,'Color',[0 0 1 1]);
        plot(v,R,stl,'LineWidth',2,'Color',[0 0 0 1]);
        plot(v(R==max(R)),max(R),'om','MarkerFaceColor','m','MarkerSize',5);
        if i==1
            vMaxE=v(E==max(E));
            plot([vMaxE vMaxE],[0 max(E)],'LineWidth',1,'Color',[1 0 0 1]);
            vMaxI=v(I==max(I));
            plot([vMaxI vMaxI],[0 max(I)],'LineWidth',1,'Color',[0 0 1 1]);
        end
        dpxXaxis(-maxV-1,maxV+1);
        set(gca, 'Layer', 'top');
        box off;
        dpxPlotVert(0,'k--');
        if i==1, dpxText(['C = ' num2str(xSecCont(i),'%.1f') ],'FontSize',12); end
    end
    dpxShareAxes(h);
    dpxText(['C = ' num2str(xSecCont(i),'%.1f')],'FontSize',12);
    xlabel('Speed (Log2 deg/s)','FontSize',12);
    ylabel('Spikes/s','FontSize',12);
    
    subplot(2,2,[2 4],'align')
    vDom=[-256:.1:-1 0 1:.1:256];
    [R,vMesh,cMesh,E,I,~,peaks]=speedContrastResponseCurve(...
        'dpsDom',[-256:.1:-1 0 1:.1:256] ...
        ,'contDom',.1:.01:1 ...
        ,'parList',pars ...
        ,'mods','EoffIsMinusIoff' ... EoffIsMinusIoff EoffZero
        ,'logDps',true);
    %   surf(vMesh,cMesh,R,'EdgeColor','none');
    
    
    [I,vAx,cAx]=jdSurfToImage(vMesh,cMesh,R,256,256);
    imagesc(vAx,cAx,I);
    set(gca,'YDir','normal');
    axis tight;
    % shading interp
    hold on;
    colorbar
    Z=ones(peaks.N,1)*max(R(:))*2;
    plot3(peaks.V,peaks.C,peaks.R+sqrt(eps),'m-','LineWidth',4);
    plot3([-log2(abs(min(vDom))) log2(max(vDom))],[xSecCont(1) xSecCont(1)],[max(R(:)) max(R(:))]+eps,'k-','LineWidth',2);
   % plot3([-log2(abs(min(vDom))) log2(max(vDom))],[xSecCont(2) xSecCont(2)],[max(R(:)) max(R(:))]+eps,'k--','LineWidth',2);
    set(gca, 'Layer', 'top');
    plot3([0 0],[.1 1],[max(R(:)) max(R(:))]+eps,'k--');
    grid off;
    box on;
    xlabel('Speed (Log2 deg/s)','FontSize',12);
    ylabel('Contrast','FontSize',12);
end

function out=KrekelbergVanWezelAlbright2006
    global rodAlb
    global fitopts
    rodAlb=false;
    dpxFindFig(['KrekelbergVanWezelAlbright2006 - ' fitopts]);
    clf;
    figures={'6a','6b','3a','3b','3c','3d'};
    for i=1:numel(figures)
        dpxDispFancy(['KWA - ' figures{i}]);
        [speeds,contr,resp]=getKrekelbergVanWezelAlbright2006Data(figures{i});
        out(i)=fitSimple(speeds,contr,resp);
        plotDataAndFit(out(i),[2 numel(figures) i]);
    end
end

function out=rodmanAlbright1987
    global rodAlb
    global fitopts
    rodAlb=true;
    dpxFindFig(['rodmanAlbright1987 - ' fitopts]);
    clf;
    figures={'6a','6b','7a','7b'};
    for i=1:numel(figures)
        dpxDispFancy(['RA - ' figures{i}]);
        [speeds,contr,resp]=getRodmanAlbright1987Data(figures{i});
        out(i)=fitSimple(speeds,contr,resp);
        plotDataAndFit(out(i),[2 4 i]);
    end
end


function out=packHunterBorn2005
    global rodAlb
    global fitopts
    rodAlb=false;
    dpxFindFig(['packHunterBorn2005 - ' fitopts]);
    clf;
    figures={'1C','3CD'};
    for i=1:numel(figures)
        dpxDispFancy(['RA - ' figures{i}]);
        [speeds,contr,resp]=getPackHunterBornData(figures{i});
        out(i)=fitSimple(speeds,contr,resp);
        plotDataAndFit(out(i),[2 4 i]);
    end
end


function out=fitSimple(speeds,conts,targetResp)
    global fitopts;
    global rodAlb;
    %
    % Set sensible estimated and boundaries
    maxS=max(speeds);
    minS=-max(speeds); % force symmetric domain even if data [1 ... fast]
    minR=min(targetResp(:));
    maxR=max(targetResp(:));
    %
    EoffEst=[speeds(find(targetResp==maxR,1)) 0 maxS*2];
    EsigEst=[maxS/3 10 1000];
    IoffEst=EoffEst;
    IsigEst=EsigEst;
    RoEst=[minR -maxR maxR];
    AeEst=[maxR/2 eps 500];
    AiEst=[maxR/2 eps 500];
    contPowEst=[.25 0.05 1];
    STR=[ AeEst(1) AiEst(1) contPowEst(1) EoffEst(1) EsigEst(1)  IoffEst(1) IsigEst(1) RoEst(1)];
    LOB=[ AeEst(2) AiEst(2) contPowEst(2) EoffEst(2) EsigEst(2)  IoffEst(2) IsigEst(2) RoEst(2)];
    UPB=[ AeEst(3) AiEst(3) contPowEst(3) EoffEst(3) EsigEst(3)  IoffEst(3) IsigEst(3) RoEst(3)];
    %
    % Run the fit in a loop with different starting values, choose the best R2
    uSpeeds=unique(speeds);
    uConts=unique(conts);
    options=optimoptions('lsqcurvefit');
    options.Display='off';
    nrStarts=1;
    bestR2=-Inf;
    for i=1:nrStarts
        if i>1
            STR=LOB+rand(size(LOB)).*(UPB-LOB);
        end
        [EST,~,residual] = lsqcurvefit(@fitFunc, STR, {uSpeeds,uConts}, targetResp, LOB, UPB, options);
        thisR2=jdR2(targetResp(:),residual(:));
        if thisR2>bestR2
            out.prms=EST;
            out.rss=sum(residual(:).^2);
            out.r2=jdR2(targetResp(:),residual(:));
            bestR2=thisR2;
            out.lobStr=sprintf('Ae=%.2f\t\tIgain=%.2f\t\tcontPow=%.2f\t\tEoff=%.2f\t\tEsig=%.2f\t\tIoff=%.2f\t\tIsig=%.2f\t\tRo=%.2f',LOB);
            out.estStr=sprintf('Ae=%.2f\t\tIgain=%.2f\t\tcontPow=%.2f\t\tEoff=%.2f\t\tEsig=%.2f\t\tIoff=%.2f\t\tIsig=%.2f\t\tRo=%.2f',EST);
            out.upbStr=sprintf('Ae=%.2f\t\tIgain=%.2f\t\tcontPow=%.2f\t\tEoff=%.2f\t\tEsig=%.2f\t\tIoff=%.2f\t\tIsig=%.2f\t\tRo=%.2f',UPB);
            fprintf('\nLOB : %s',out.lobStr);
            fprintf('\nEST : %s',out.estStr);
            fprintf('\nUPB : %s',out.upbStr);
            fprintf('\n%s',['       R2 = ' num2str(thisR2)]);
        else
            fprintf('.');
        end
        if bestR2>=1-eps % stop if perfect, whishful thinking
            break;
        end
    end
    fprintf('\n');
    % Store the curves and the data points for plotting
    out.uSpeeds=uSpeeds;
    out.uConts=uConts;
    out.targetR=reshape(targetResp,numel(uSpeeds),numel(uConts))';
    out.surfs=prepPlotSurfs(uSpeeds,uConts,EST,50,50);
    out.curves=prepPlotSurfs(speeds,uConts,EST,50,[]);
    % make prediction at set contrast points
    out.pred.uConts=1;
    out.pred.surfs=prepPlotSurfs(uSpeeds,out.pred.uConts,EST,50,50);
    out.pred.curves=prepPlotSurfs(speeds,out.pred.uConts,EST,50,[]);
    %
    % The fit function, a wrapper around speedContrastResponseCurve
    function R=fitFunc(prms,speedsContsCell)
        R=speedContrastResponseCurve( ...
            'dpsDom',speedsContsCell{1} ...
            ,'contDom',speedsContsCell{2} ...
            ,'parList',prms ...
            ,'logDps',~rodAlb ...
            ,'mods',fitopts);
        R=reshape(shiftdim(R,1),1,numel(R));
    end
    %
    % A function that prepares surfaces and lines for easy plotting of results
    function P=prepPlotSurfs(speeds,conts,EST,nV,nC)
        if ~isempty(nV)
            vStep=(max(speeds)-min(speeds))/nV;
            vDom=min(speeds):vStep:max(speeds);
        else
            vDom=speeds;
        end
        if ~isempty(nC) && numel(conts)>1
            cStep=(max(conts)-min(conts))/nC;
            cDom=min(conts):cStep:max(conts);
        else
            cDom=conts;
        end
        [P.R,P.vMesh,P.cMesh,P.E,P.I,P.gainMesh]=speedContrastResponseCurve( ...
            'dpsDom',vDom ...
            ,'contDom',cDom ...
            ,'parList',EST ...
            ,'mod',fitopts);
    end
end


function [R,vMesh,cMesh,E,I,gainMesh,peaks]=speedContrastResponseCurve(varargin)
    p=inputParser;
    p.addParamValue('dpsDom',-1024:8:1024,@isnumeric);
    p.addParamValue('contDom',0:.01:1,@(x)isnumeric(x));
    p.addParamValue('Esig',128,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Eoff',64,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Isig',32,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Ioff',64,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('contPow',0.5,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Ro',0,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Ai',1,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Ax',1,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('mods','EoffIsMinusIoff',@(x)any(strcmpi(x,{'EoffIsMinusIoff','EoffZero','OneOffOneSig'})));
    p.addParamValue('logDps',true,@islogical);
    p.addParamValue('parList',[],@(x)isempty(x)||numel(x)==8)
    p.parse(varargin{:});
    %
    if isempty(p.Results.parList)
        Ai=p.Results.Ai;
        Ax=p.Results.Ax;
        contPow=p.Results.contPow;
        Eoff=p.Results.Eoff;
        Esig=p.Results.Esig;
        Ioff=p.Results.Ioff;
        Isig=p.Results.Isig;
        Ro=p.Results.Ro;
    else
        % alphabetical
        Ai=p.Results.parList(1);
        Ax=p.Results.parList(2);
        contPow=p.Results.parList(3);
        Eoff=p.Results.parList(4);
        Esig=p.Results.parList(5);
        Ioff=p.Results.parList(6);
        Isig=p.Results.parList(7);
        Ro=p.Results.parList(8);
    end
    [vMesh,cMesh]=meshgrid(p.Results.dpsDom,real(p.Results.contDom));
    vMesh=jdLogSignedAxis(vMesh,@log2);
    if strcmpi(p.Results.mods,'EoffIsMinusIoff')
        E=normpdf(vMesh,log2(Ioff),log2(Esig));
        I=normpdf(vMesh,-log2(Ioff),log2(Isig));
    elseif strcmpi(p.Results.mods,'OneOffOneSig')
        E=normpdf(vMesh,log2(Ioff),log2(Isig));
        I=normpdf(vMesh,-log2(Ioff),log2(Isig));
    elseif strcmpi(p.Results.mods,'EoffZero')
        E=normpdf(vMesh,0,log2(Esig));
        I=normpdf(vMesh,-log2(Ioff),log2(Isig));
    end
    E=E./max(E(:));
    I=I./max(I(:));
    gainMesh=cMesh.^contPow;
    E=E.*gainMesh*Ax+Ro;
    I=I.*cMesh*Ai;
    R=E-I;
    R=jdSmoothBottom(R);
    %
    
    if nargout>=7
        [peaks.R,i]=max(R,[],2);
        peaks.C=p.Results.contDom;
        peaks.V=jdLogSignedAxis(p.Results.dpsDom(i),@log2);
        peaks.N=numel(peaks.V);
    end
end



function [speed,contr,resp]=getKrekelbergVanWezelAlbright2006Data(figStr)
    if strcmpi(figStr,'6A')
        resp=[10.5 12.4 15.5 16.25 14.9 11 8.5 12 14 15.5 18.75 19 17.5 12.5 13 15 17.6 21 22.6 21.5 18.5 13 15 17.7 21.5 23.75 23.5 21];
    elseif strcmpi(figStr,'6B')
        resp=[.34 .395 .475 .49 .45 .3 .25 , .4 .48 .54 .596 .61 .53 .395 , .42 .47 .54 .635 .665 .605 .52 , .43 .48 .54 .65 .72 .645 .595];
    elseif strcmpi(figStr,'3A')
        resp=[12 15 20 24 14 8 7.5 19 22.5 35 46 43 25 14 20 32.5 55 68 71 55 41 21 26 41 68 93 83 60];
    elseif strcmpi(figStr,'3B')
        resp=[10 15 18 18 14.5 9.5 7 21 30 35 40 35 20 7.5 22 30 38 48 51 34 10 21 30 31 53 55 25 7.5];
    elseif strcmpi(figStr,'3C')
        resp=[0.5 0.5 2 5.5 3 1.3 0.7 1 1.5 3 4.5 9 7.5 2.5 1.1 1.9 3.9 8.25 9.5 7 3.5 0.5 0.6 0.5 0.9 5 7.8 9.7];
    elseif strcmpi(figStr,'3D')
        resp=[40 51 56 55 41 22 14 30 38 50 51 45 38 18 20 35 50 55 43 21 8 17.5 21 36 55 54 15 8];
    else
        error('No such Krekelberg VanWezel Albright 2006 Data');
    end
    speed=[ 1 2 4 8 16 32 64 1 2 4 8 16 32 64 1 2 4 8 16 32 64 1 2 4 8 16 32 64];
    contr=[0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.7 0.7 0.7 0.7 0.7 0.7 0.7];
    contr=sqrt(contr./max(contr));
    %contr=contr./max(contr);
    % add zero contrast
    if false
        b=min(resp)/2;
        speed=[1 2 4 8 16 32 64 speed];
        resp= [b b b b b b b resp];
        contr=[0 0 0 0 0 0 0 contr];
    end
end


function [speed,contr,resp]=getPackHunterBornData(figStr)
    if strcmpi(figStr,'1C')
        speed=[1 2 4 8 16 32 64    1 2 4 8 16 32 64 ];
        contr=[1 1 1 1 1  1  1     3 3 3 3 3  3  3    ]/3;
        resp=[8 14 37 46 30 15 5   2 4 3 11 38 82 29 ];
    elseif strcmpi(figStr,'3CD')
        speed=[-64 -32 -16 -8 -4 -2 -1  1 2 4 8 16 32 64      -64 -32 -16 -8 -4 -2 -1 1  2  4  8   16  32  64 ];
        contr=[1   1   1   1   1  1  1  1 1 1 1 1  1  1       3   3   3   3  3  3  3  3  3  3  3   3   3   3  ]/3;
        resp=[ 15  18  19  12  10 9  8  55 63 51 31 25 17 18  12  9   2   0  0  0  0  37 70 83 80  51  35  33 ];
    else
        error('No such data');
    end
end



function [speed,contr,resp]=getRodmanAlbright1987Data(figStr)
    if strcmpi(figStr,'6A')
        speed=[-64 -32 -16 -8 8  16 32 64];
        resp= [0   9   14  13 18 17 16 3];
    elseif strcmpi(figStr,'6B')
        speed=[-40 -20 -10 -5 -2.5 -1.25 1.25 2.5 5 10 20 40];
        resp=[16 19 12 5 2 1 5 7 6 17.5 30 24];
    elseif strcmpi(figStr,'7A')
        speed=[-40 -20 -10 -5 5 10 20 40];
        resp=[-3 -2 -1.5 -1 0.5 2 6 7.5];
    elseif strcmpi(figStr,'7B')
        speed=[-80 -40 -20 -10 -5 -2.5 2.5 5 10 20 40 80];
        resp=[-2 -6.5 -9 -7 -4 -5 5 13 24 30 21 18];
    else
        error('No such Rodman Albright 1987 Data');
    end
    % set the minimum response to zero
    resp=resp-min(resp);
    contr=ones(size(resp));
end


function plotDataAndFit(fit,spn)
    isPrediction=~isfield(fit,'targetR');
    cmap=colormap('hot');
    peakx=[];
    peaky=[];
    
    plotFnc=@plot;
    for i=1:numel(fit.uConts)
        C=fit.uConts(i);
        opac=.05+C*.95;
        col=cmap(floor((1-opac)*size(cmap,1))+1,:);
        %
        % Plot the markers
        if ~isPrediction
            subplot(spn(1),spn(2),spn(3),'align');
            V=jdLogSignedAxis(fit.uSpeeds,@log2);fit.uSpeeds
            plotFnc(V,fit.targetR(i,:),'o','MarkerFaceColor',col,'MarkerEdgeColor','w','MarkerSize',8);
            hold on
        end
        %
        % Plot the fitted or predicted curve
        subplot(spn(1),spn(2),spn(3),'align');
        plotFnc(fit.curves.vMesh(i,:),fit.curves.R(i,:),'Color',col,'LineWidth',2);
        hold on;
        if spn(1)>1
            subplot(spn(1),spn(2),spn(3)+spn(2),'align');
            plotFnc(fit.curves.vMesh(i,:),fit.curves.E(i,:),'Color',[1 0 0 opac],'LineWidth',2);
            hold on;
            plotFnc(fit.curves.vMesh(i,:),-fit.curves.I(i,:),'Color',[0 0 1 opac],'LineWidth',2);
            axis tight
        end
        peakx(end+1)=fit.curves.vMesh(i,(find(fit.curves.R(i,:)==max(fit.curves.R(i,:)),1))); %#ok<*AGROW>
        peaky(end+1)=max(fit.curves.R(i,:));
    end
    jdPlotHori(0,'k--');
    subplot(spn(1),spn(2),spn(3),'align');
    plotFnc(peakx,peaky,'xb-','LineWidth',1.5);
    %
    axis tight;
    if ~isPrediction
        dpxText(['R2 = ' num2str(fit.r2,'%.2f')],'FontSize',12);
        %
        if spn(3)==1
            xlabel('Speed (deg/s)');
            ylabel('Response (IPS)');
        end
    end
end
