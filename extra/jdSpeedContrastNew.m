function jdSpeedContrast
    
    global fitopts
    global fitcounter
    global plotfitcounter
    fitcounter=0;
    plotfitcounter=0;
   % models={'IoffIsNegXoff','XoffZero','IoffZero'}%'XoffIoff'};
     models={'IoffIsNegXoff'}%,'XoffIoff'}%'XoffIoff'};
     
     %%
     global rodAlb;
     rodAlb=false
     
   %  plotTest
     
   %  return
     
            
            
    for i=1:numel(models)
        fitopts=models{i};
        M.(fitopts)=[rodmanAlbright1987 ];
         % M.(fitopts)=[ KrekelbergVanWezelAlbright2006];
    end
   % outKWA.(fitopts)=KrekelbergVanWezelAlbright2006;
   % fitopts='IoffIsNegXoff';
   % outRA.(fitopts)=rodmanAlbright1987;
   % outKWA.(fitopts)=KrekelbergVanWezelAlbright2006;
    
   compareModels(M);%{'IoffIsNegXoff','XoffZero'});
   
   keyboard
end

function out=rodmanAlbright1987
    global rodAlb
    global fitopts
    rodAlb=true;
    dpxFindFig(['rodmanAlbright1987 - ' fitopts]);
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
    dpxFindFig(['KrekelbergVanWezelAlbright2006 - ' fitopts]);
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
    p.addParamValue('domainDps',100:512,@isnumeric);
    p.addParamValue('contrast',.5,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Xsig',128,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Xoff',64,@(x)isnumeric(x)&&numel(x)==1&&x>=0);
    p.addParamValue('Ioff',64,@(x)isnumeric(x)&&numel(x)==1&&x>=0);
    p.addParamValue('Isig',32,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Igain',1,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('contPow',0.5,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('Ro',1000,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('A',100,@(x)isnumeric(x)&&numel(x)==1);
    p.addParamValue('fitopts','IoffIsNegXoff',@(x)any(strcmpi(x,{'IoffIsNegXoff','XoffZero','IoffZero','XoffIoff'})));
    p.parse(varargin{:});
    
    
  %  p=inputParser;
  %  p.addParamValue('domainDps',-512:512,@isnumeric);
  %  p.addParamValue('contrast',1,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('Xsig',128,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('Xoff',64,@(x)isnumeric(x)&&numel(x)==1&&x>=0);
  %  p.addParamValue('Ioff',64,@(x)isnumeric(x)&&numel(x)==1&&x>=0);
  %  p.addParamValue('Isig',32,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('Igain',1,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('contPow',0.5,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('Ro',0,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('A',1,@(x)isnumeric(x)&&numel(x)==1);
  %  p.addParamValue('fitopts','IoffIsNegXoff',@(x)any(strcmpi(x,{'IoffIsNegXoff','XoffZero','IoffZero','XoffIoff'})));
  %  p.parse(varargin{:});
    %
    if rodAlb
        CONTPOW=0.5;
    else
        CONTPOW=p.Results.contPow;
    end
    %
    dom=p.Results.domainDps;
    if ~isempty(strfind(p.Results.fitopts,'IoffIsNegXoff'))
        if rodAlb
            X=normpdf(dom,p.Results.Xoff,p.Results.Xsig);
            I=normpdf(dom,-p.Results.Xoff,p.Results.Isig);
        else
            X=normpdf(log(dom),log(p.Results.Xoff),log(p.Results.Xsig));
            I=normpdf(log(dom),-log(p.Results.Xoff),log(p.Results.Isig));  
        end
    elseif ~isempty(strfind(p.Results.fitopts,'XoffZero'))
        if rodAlb
            X=normpdf(dom,0,p.Results.Xsig);
            I=normpdf(dom,-p.Results.Ioff,p.Results.Isig);
        else
            X=normpdf(log(dom),0,log(p.Results.Xsig));
            I=normpdf(log(dom),-log(p.Results.Ioff),log(p.Results.Isig));
        end
    elseif ~isempty(strfind(p.Results.fitopts,'IoffZero'))
        if rodAlb
            X=normpdf(dom,p.Results.Xoff,p.Results.Xsig);
            I=normpdf(dom,0,p.Results.Isig);
        else
            X=normpdf(log(dom),log(p.Results.Xoff),log(p.Results.Xsig));
            I=normpdf(log(dom),0,log(p.Results.Isig));
        end
    elseif ~isempty(strfind(p.Results.fitopts,'XoffIoff'))
        if rodAlb
            X=normpdf(dom,p.Results.Xoff,p.Results.Xsig);
            I=normpdf(dom,-p.Results.Ioff,p.Results.Isig);
        else
            X=normpdf(log(dom),log(p.Results.Xoff),log(p.Results.Xsig));
            I=normpdf(log(dom),-log(p.Results.Ioff),log(p.Results.Isig));
        end
    else
        error(['Unknown fitopts: ' fitopts]);
    end
    X=X./max(X);
    I=I./max(I);
    X=X*(p.Results.contrast).^CONTPOW;
    I=I*p.Results.contrast*p.Results.Igain;   
    R=X-I;
    R=R*p.Results.A;
    R=R+p.Results.Ro;
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
    XoffEst=speeds(find(targetResp==max(targetResp),1))/2;
    IoffEst=0;
    IsigEst=maxS/3;
    IgainEst=1;
    RoEst=min(targetResp(:));
    AEst=1;%max(targetResp(:));
    contPowEst=0.25;
    global rodAlb
    if rodAlb
        if strcmpi(fitopts,'IoffIsNegXoff')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 20      0       0       20       eps       -100  eps  0         ];
            UPB=[ maxS*10 maxS*2  maxS*2   maxS*10  100        100 120  2         ];
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst        ];
            LOB=[ 20      0       0       20       eps       -100  eps  0    ];
            UPB=[ maxS*10 maxS*2  maxS*2   maxS*10  10        100   120  2    ];
        elseif strcmpi(fitopts,'XoffZero')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 20      0       0       20       eps       -100  eps  0         ];
            UPB=[ maxS*4 maxS*2  maxS*2  maxS*10  100        100   200  2         ];
        elseif strcmpi(fitopts,'IoffZero')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 20      0       0       20       eps       -100  eps  0         ];
            UPB=[ maxS*4 maxS*2  maxS*2  maxS*10  100        100   200  2         ];
        elseif strcmpi(fitopts,'XoffIoff')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 20      0       -maxS*2       20       eps       -100  eps  0         ];
            UPB=[ maxS*4 maxS*2  maxS*2  maxS*10  100        100   200  2         ];
        end
        plotConts=.25:.25:1;
    else
        if strcmpi(fitopts,'IoffIsNegXoff')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 18      0       0       18       eps       -500  eps  0         ];
            UPB=[ maxS*4  maxS*2  maxS*2  maxS*10  100        2000 2000  200         ];
        elseif strcmpi(fitopts,'XoffZero')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 18      0       0       18       eps       -500  eps  0         ];
            UPB=[ maxS*4  maxS*2  maxS*2  maxS*10  100        2000 2000  200         ];
        elseif strcmpi(fitopts,'IoffZero')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 18      0       0       18       eps       -500  eps  0         ];
            UPB=[ maxS*4  maxS*2  maxS*2  maxS*10  100        2000 2000  200         ];
        elseif strcmpi(fitopts,'XoffIoff')
            EST=[ XsigEst XoffEst IoffEst IsigEst  IgainEst  RoEst AEst contPowEst];
            LOB=[ 18      0       0       18       eps       -50  eps  0         ];
            UPB=[ maxS*4  maxS*2  maxS*2  maxS*2   100       50   2    20       ];
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
      %  dpxFindFig('fitprog'); clf
        [FIT,~,residual] = lsqcurvefit(@fitFunc, EST, {speeds,uniqConts,targetResp}, targetResp, LOB, UPB, options);
        thisR2=jdR2(targetResp(:),residual(:));
        if thisR2>bestR2
            out.speedDomain=speeds;
            out.fitCurve=targetResp+residual;
            out.Xsig=FIT(1);
            out.Xoff=FIT(2);
            out.Ioff=FIT(3);
            out.Isig=FIT(4);
            out.Igain=FIT(5);
            out.Ro=FIT(6);
            out.A=FIT(7);
            out.contPow=FIT(8);
            out.rss=sum(residual(:).^2);
            out.r2=jdR2(targetResp(:),residual(:));
            bestR2=thisR2;
            disp(['Fit (' num2str(i) '/' num2str(nrStarts) ')']);
            fprintf('\tXsig=%.2f, Xoff=%.2f, Ioff=%.2f, Isig=%.2f, Igain=%.2f, Ro=%.2f, A=%.2f, contPow=%.2f\n',FIT);
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
            ,'Ioff',out.Ioff ...
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
        global fitcounter
        global plotfitcounter
        fitcounter=fitcounter+1;
        if mod(fitcounter,plotfitcounter)==0
            clf;
        end
        color='rgbk';
        Rout=nan(size(speedsContsCell{1}));
        nSpeeds=numel(speedsContsCell{1})/numel(speedsContsCell{2});
        for c=1:numel(speedsContsCell{2})
            idx=(c-1)*nSpeeds+1:c*nSpeeds;
            R=speedResponseSimple( ...
                'domainDps',speedsContsCell{1}(idx) ...
                ,'contrast',speedsContsCell{2}(c) ...
                ,'Xsig',prms(1) ...
                ,'Xoff',prms(2) ...
                ,'Ioff',prms(3) ...
                ,'Isig',prms(4) ...
                ,'Igain',prms(5) ...
                ,'Ro',prms(6) ...
                ,'A',prms(7) ...
                ,'contPow',prms(8) ...
                ,'fitopts',fitopts);
            Rout(idx)=R;
            if mod(fitcounter,plotfitcounter)==0
                plot(speedsContsCell{3}(idx),'x','Color',color(c));
                hold on
                plot(R,'Color',color(c));
                %
                str=sprintf('\tXsig=%.2f, Xoff=%.2f, Ioff=%.2f, Isig=%.2f, Igain=%.2f, Ro=%.2f, A=%.2f, contPow=%.2f\n',prms);
                title(str);
            end
        end
        if mod(fitcounter,plotfitcounter)==0
            dpxText(num2str(fitcounter));
            drawnow;
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
    dpxText(['R2 = ' num2str(fit.r2,'%.2f')]);
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
    contr=ones(size(resp));
    resp=resp/max(resp)*90;
    resp=resp+10;
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
   % resp=resp-min(resp);
   % resp=resp/max(resp)*10;
   % resp=resp+1000;
end



function compareModels(M,modStrCell)
    if nargin==1 || isempty(modStrCell)
        modStrCell=fieldnames(M);
    end
    if numel(modStrCell)<2
        return;
    end
    dpxFindFig('compareModels');
    dpxScatStat([M.(modStrCell{1}).r2],[M.(modStrCell{2}).r2],'test','signtest');
    xlabel([modStrCell{1} ' R^2']);
    ylabel([modStrCell{2} ' R^2']);
    axis square
end


