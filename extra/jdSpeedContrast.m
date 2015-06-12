function jdSpeedContrast
    
    global fitopts
    models={'XoffIsMinusIoff','XoffZero'};
    for i=1:numel(models)
        fitopts=models{i};
        M.(fitopts)=[rodmanAlbright1987 KrekelbergVanWezelAlbright2006];
    end
   % outKWA.(fitopts)=KrekelbergVanWezelAlbright2006;
   % fitopts='XoffIsMinusIoff';
   % outRA.(fitopts)=rodmanAlbright1987;
   % outKWA.(fitopts)=KrekelbergVanWezelAlbright2006;
    
   compareModels(M);%{'XoffIsMinusIoff','XoffZero'});
   
   keyboard
end

function out=rodmanAlbright1987
    global rodAlb
    global fitopts
    rodAlb=true;
    findfig(['rodmanAlbright1987 - ' fitopts]);
    clf;
    figures={'6a','6b','7a','7b'};
    for i=1:numel(figures)
        [speeds,~,resp]=getRodmanAlbright1987Data(figures{i});
        out(i)=fitSimple(speeds,1,resp);
        plotDataAndFit(out(i),[2 4 i]);
    end
end


function out=KrekelbergVanWezelAlbright2006
    global rodAlb 
    global fitopts
    rodAlb=false;
    findfig(['KrekelbergVanWezelAlbright2006 - ' fitopts]);
    clf;
    figures={'6a','6b','3a','3b','3c','3d'};
    for i=1:numel(figures)
        [speeds,contr,resp]=getKrekelbergVanWezelAlbright2006Data(figures{i});
        out(i)=fitSimple(speeds,contr,resp);
        plotDataAndFit(out(i),[2 numel(figures) i]);
    end
end


function [R,X,I]=speedResponseSimple(varargin)
    global rodAlb
    p=inputParser;
    p.addParamValue('domainDps',-512:512,@isnumeric);
    p.addParamValue('contrast',1,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Xsig',128,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Xoff',64,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Isig',32,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Igain',1,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('contPow',0.5,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Ro',0,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('A',1,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('fitopts','XoffIsMinusIoff',@(x)any(strcmpi(x,{'XoffIsMinusIoff','XoffZero'})));
    p.parse(varargin{:});
    %
    dom=p.Results.domainDps;
    if ~isempty(strfind(p.Results.fitopts,'XoffIsMinusIoff'))
        if rodAlb
            X=normpdf(dom,p.Results.Xoff,p.Results.Xsig);
            I=normpdf(dom,-p.Results.Xoff,p.Results.Isig);
        else
            X=normpdf(log(dom),log(p.Results.Xoff),log(p.Results.Xsig));
            I=normpdf(log(dom),-log(p.Results.Xoff),log(p.Results.Isig));
        end
        X=X./sum(X);
        I=I./sum(I);
        X=X./max(X);
        I=I./max(I);
        X=X*p.Results.contrast.^p.Results.contPow;
        I=I*p.Results.contrast*p.Results.Igain;
        R=(X-I);
        R=R*p.Results.A;
        R=R+p.Results.Ro;
    elseif ~isempty(strfind(p.Results.fitopts,'XoffZero'))
        if rodAlb
            X=normpdf(dom,0,p.Results.Xsig);
            I=normpdf(dom,-p.Results.Xoff,p.Results.Isig);
        else
            X=normpdf(log(dom),0,log(p.Results.Xsig));
            I=normpdf(log(dom),-log(p.Results.Xoff),log(p.Results.Isig));
        end
        X=X./sum(X);
        I=I./sum(I);
        X=X./max(X);
        I=I./max(I);
        X=X*p.Results.contrast.^p.Results.contPow;
        I=I*p.Results.contrast*p.Results.Igain;
        R=(X-I);
        R=R*p.Results.A;
        R=R+p.Results.Ro;
    else
        error(['Unknown fitopts: ' fitopts]);
    end
end


function out=fitSimple(speeds,conts,targetResp)
    global fitopts
    % check the inputs
    if numel(conts)==1
        conts=ones(size(targetResp))*conts;
    elseif ~all(conts-sort(conts,'ascend')==0)
        error('conts should be in monotonic ascending order!');
    end
    uniqConts=unique(conts,'stable');
    %
    % Set sensible estimated and boundaries
    maxS=max(speeds);
    minS=-max(speeds); % force symmetric domain even if data [1 ... fast]
    %
    XsigEst=maxS/3;
    XoffEst=speeds(find(targetResp==max(targetResp),1));
    IsigEst=maxS/3;
    IgainEst=1;
    RoEst=min(targetResp(:));
    AEst=max(targetResp(:));
    contPowEst=0.25;
    global rodAlb
    if rodAlb
        if strcmpi(fitopts,'XoffIsMinusIoff')
            EST=[ XsigEst XoffEst IsigEst  IgainEst  RoEst AEst .5];
            LOB=[ 20      0       20       eps       -100  eps  .5-eps];
            UPB=[ maxS*10 maxS*2  maxS*10  10        100   120  .5+eps];
        elseif strcmpi(fitopts,'XoffZero')
            EST=[ XsigEst XoffEst IsigEst  IgainEst  RoEst AEst .5];
            LOB=[ 20      0       20       eps       -100  eps  .5-eps];
            UPB=[ maxS*10 maxS*2  maxS*10  10        100   120  .5+eps];
        end
        plotConts=.25:.25:1;
    else
        if strcmpi(fitopts,'XoffIsMinusIoff')
            EST=[ XsigEst XoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 18      0       18       eps       -100  eps  0         ];
            UPB=[ maxS*10 maxS*2  maxS*10  10        100   120  2         ];
        elseif strcmpi(fitopts,'XoffZero')
            EST=[ XsigEst XoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 18      0       18       eps       -100  eps  0         ];
            UPB=[ maxS*10 maxS*2  maxS*10  10        100   120  2         ];
        end
        plotConts=uniqConts;
    end
    %
    % Run the fit in a loop with different starting values, choose the best R2
    options=optimoptions('lsqcurvefit');
    options.Display='off';
    nrStarts=1;
    bestR2=-Inf;
    for i=1:nrStarts
        if i>1
            EST=LOB+rand(size(LOB)).*(UPB-LOB);
        end
        [FIT,~,residual] = lsqcurvefit(@fitFunc, EST, {speeds,uniqConts}, targetResp, LOB, UPB, options);
        thisR2=jdR2(targetResp(:),residual(:));
        if thisR2>bestR2
            out.speedDomain=speeds;
            out.fitCurve=targetResp+residual;
            out.Xsig=FIT(1);
            out.Xoff=FIT(2);
            out.Isig=FIT(3);
            out.Igain=FIT(4);
            out.Ro=FIT(5);
            out.A=FIT(6);
            out.contPow=FIT(7);
            out.rss=sum(residual(:).^2);
            out.r2=jdR2(targetResp(:),residual(:));
            bestR2=thisR2;
            disp(['Fit (' num2str(i) '/' num2str(nrStarts) ')']);
            fprintf('\tXsig=%.2f, Xoff=%.2f, Isig=%.2f, Igain=%.2f, Ro=%.2f, A=%.2f, contPow=%.2f\n',FIT);
            fprintf('\tR2=%.2f\n',bestR2);
        else
            disp(['Fit (' num2str(i) '/' num2str(nrStarts) ') ... ']);
        end
        if bestR2>=1-eps % stop if perfect, whishful thinking
            break;
        end
    end
    % Store the curves and the data points for plotting
    out.fineDomain=min(speeds):max(speeds);
    out.plotConts=plotConts;
    out.targetR=nans(numel(plotConts),numel(targetResp)/numel(uniqConts));
    out.speeds=out.targetR;
    for ci=1:numel(plotConts)
        if sum(conts==plotConts(ci))>0
            out.targetR(ci,:)=targetResp(conts==plotConts(ci));
            out.speeds(ci,:)=speeds(conts==plotConts(ci));
        end
        [out.R(ci,:),out.X(ci,:),out.I(ci,:)]=speedResponseSimple( ...
            'domainDps',out.fineDomain ...
            ,'Xsig',out.Xsig ...
            ,'Xoff',out.Xoff ...
            ,'Isig',out.Isig ...
            ,'Igain',out.Igain ...
            ,'Ro',out.Ro ...
            ,'A',out.A ...
            ,'contPow',out.contPow ...
            ,'contrast',plotConts(ci) ...
            ,'fitopts',fitopts);
    end
    % The fit function, a wrapper around speedResponseSimple
    function Rout=fitFunc(prms,speedsContsCell)
        Rout=nan(size(speedsContsCell{1}));
        nSpeeds=numel(speedsContsCell{1})/numel(speedsContsCell{2});
        for c=1:numel(speedsContsCell{2})    
            idx=(c-1)*nSpeeds+1:c*nSpeeds;
            R=speedResponseSimple( ...
                'domainDps',speedsContsCell{1}(idx) ...
                ,'contrast',speedsContsCell{2}(c) ...
                ,'Xsig',prms(1) ...
                ,'Xoff',prms(2) ...
                ,'Isig',prms(3) ...
                ,'Igain',prms(4) ...
                ,'Ro',prms(5) ...
                ,'A',prms(6) ...
                ,'contPow',prms(7) ...
                ,'fitopts',fitopts);
            Rout(idx)=R;
        end
    end
end



%function plotDataAndFit(speeds,conts,targetResp,fit,spn)
function plotDataAndFit(fit,spn)
    global rodAlb
    cmap=colormap('hot');
    peakx=[];
    peaky=[];
    
    if rodAlb
        plotFnc=@plot;
    else
        plotFnc=@semilogx;
    end
    for i=1:numel(fit.plotConts)
        C=fit.plotConts(i);
        opac=.05+C*.95;
        col=cmap(floor((1-opac)*size(cmap,1))+1,:);
        % 
        % Plot the markers
        subplot(spn(1),spn(2),spn(3),'align');
        plotFnc(fit.speeds(i,:),fit.targetR(i,:),'o','MarkerFaceColor',col,'MarkerEdgeColor','w');
        hold on
        %
        % Plot the fitted curve
        subplot(spn(1),spn(2),spn(3),'align');
        plotFnc(fit.fineDomain,fit.R(i,:),'Color',col,'LineWidth',2);
        hold on;
        if spn(1)>1
            subplot(spn(1),spn(2),spn(3)+spn(2),'align');
            plotFnc(fit.fineDomain,fit.X,'Color',[1 0 0 opac],'LineWidth',2);
            hold on;
            plotFnc(fit.fineDomain,fit.I,'Color',[0 0 1 opac],'LineWidth',2);
            axis tight
        end
        peakx(end+1)=fit.fineDomain(find(fit.R(i,:)==max(fit.R(i,:)),1));
        peaky(end+1)=max(fit.R(i,:));
    end
    subplot(spn(1),spn(2),spn(3),'align');
    plotFnc(peakx,peaky,'xb-','LineWidth',1.5);
    %
    axis tight;
    jdText(['R2 = ' num2str(fit.r2,'%.2f')]);
    %
    if spn(3)==1
        xlabel('Speed (deg/s)');
        ylabel('Response (IPS)');
    end
end




function [speed,contr,resp]=getRodmanAlbright1987Data(figStr)
    if strcmpi(figStr,'6A')
        speed=[-64 -32 -16 -8 8  16 32 64];
        resp= [0   9   14  13 18 17 16 3];
        %  speed=imresize(speed,[1 2*numel(speed)],'bilinear');
        %  resp=imresize(resp,[1 2*numel(resp)],'bilinear');
    elseif strcmpi(figStr,'6B')
        speed=[-40 -20 -10 -5 -2.5 -1.25 1.25 2.5 5 10 20 40];
        resp=[16 19 12 5 2 1 5 7 6 17.5 30 24];
    elseif strcmpi(figStr,'7A')
        speed=[-40 -20 -10 -5 5 10 20 40];
        resp=[-3 -2 -1.5 -1 0.5 2 6 7.5];
        % speed=imresize(speed,[1 2*numel(speed)],'bilinear');
        % resp=imresize(resp,[1 2*numel(resp)],'bilinear');
    elseif strcmpi(figStr,'7B')
        speed=[-80 -40 -20 -10 -5 -2.5 2.5 5 10 20 40 80];
        resp=[-2 -6.5 -9 -7 -4 -5 5 13 24 30 21 18];
    else
        error('No such Rodman Albright 1987 Data');
    end
    % set the minimum response to zero + somehting
    resp=resp-min(resp);
  %  resp=resp/max(resp)*10;
    contr=ones(size(resp));
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
end



function compareModels(M,modStrCell)
    if nargin==1 || isempty(modStrCell)
        modStrCell=fieldnames(M);
    end
    findfig('compareModels');
    jdScatStat([M.(modStrCell{1}).r2],[M.(modStrCell{2}).r2],'test','signtest');
    xlabel([modStrCell{1} ' R^2']);
    ylabel([modStrCell{2} ' R^2']);
    axis square
end


