function jdSpeedContrast
    
    
    [speedDomain,targetResp]=rodmanAlbrightData('6A');
    rodmanAlbright1987;

end

function rodmanAlbright1987
    findfig('RodmanAlbright');
    clf;
    %
    [speedDomain,targetResp]=rodmanAlbrightData('6A');
    out=fitSimpleToData(speedDomain,targetResp);
    plotDataAndFit(speedDomain,targetResp,out,[2 4 1]);
    %
    [speedDomain,targetResp]=rodmanAlbrightData('6B');
    out=fitSimpleToData(speedDomain,targetResp);
    plotDataAndFit(speedDomain,targetResp,out,[2 4 2]);
    %
    [speedDomain,targetResp]=rodmanAlbrightData('7A');
    out=fitSimpleToData(speedDomain,targetResp);
    plotDataAndFit(speedDomain,targetResp,out,[2 4 3]);
    %
    [speedDomain,targetResp]=rodmanAlbrightData('7B');
    out=fitSimpleToData(speedDomain,targetResp);
    plotDataAndFit(speedDomain,targetResp,out,[2 4 4]);

end

function [R,X,I]=speedResponseSimple(varargin)
    
    p=inputParser;
    p.addParamValue('domainDps',-512:512,@isnumeric);
    p.addParamValue('contrast',1,@isnumeric);
    p.addParamValue('Xsig',128,@isnumeric);
    p.addParamValue('Xoff',64,@isnumeric);
    p.addParamValue('Isig',32,@isnumeric);
    p.addParamValue('Igain',1,@isnumeric);
    p.addParamValue('contrastPow',0.5,@isnumeric);
    p.addParamValue('Ro',0,@isnumeric);
    p.addParamValue('A',1,@isnumeric);
    p.parse(varargin{:});
    %
    dom=p.Results.domainDps;
    X=normpdf(dom,p.Results.Xoff,p.Results.Xsig);
    
   %   X=normpdf(dom, 0 ,p.Results.Xsig);
      
      
    I=normpdf(dom,-p.Results.Xoff,p.Results.Isig);
    X=X./sum(X);
    I=I./sum(I);
    X=X./max(X);
    I=I./max(I);
    X=X*p.Results.contrast.^p.Results.contrastPow;
    I=I*p.Results.contrast*p.Results.Igain;
    R=((X-I));
    R=R*p.Results.A;
    R=R+p.Results.Ro;
    
end

function [R,dom,M,X,I]=speedResponseComplex(varargin)
    
    p=inputParser;
    p.addParamValue('domainDps',-512:512,@isnumeric);
    p.addParamValue('Msig',256,@isnumeric);
    p.addParamValue('Xsig',128,@isnumeric);
    p.addParamValue('Xoff',64,@isnumeric);
    p.addParamValue('Isig',32,@isnumeric);
    p.addParamValue('Ioff',-64,@isnumeric);
    p.addParamValue('Igain',1,@isnumeric);
    p.addParamValue('contrast',1,@isnumeric);
    p.addParamValue('contrastPow',0.5,@isnumeric);
    p.addParamValue('restIn',0.1,@isnumeric);
    p.addParamValue('Ro',0,@isnumeric);
    p.addParamValue('A',1,@isnumeric);
    p.parse(varargin{:});
    %
    dom=p.Results.domainDps;
    X=normpdf(dom,p.Results.Xoff,p.Results.Xsig);
    I=normpdf(dom,p.Results.Ioff,p.Results.Isig);
    M=normpdf(dom,0,p.Results.Msig);
    X=X./sum(X);
    I=I./sum(I);
    M=M./sum(M);
    X=X./max(X);
    I=I./max(I);
    M=M./max(M);
    X=X*p.Results.contrast.^p.Results.contrastPow;
    I=I*p.Results.contrast*p.Results.Igain;
    R=(p.Results.restIn+(X-I)).*M;
    R=((X-I)).*M;
    R=R*p.Results.A;
    R=R+p.Results.Ro;
    
end


function out=fitSimpleToData(speedDomain,targetResp)
    %
    % Set sensible estimated and boundaries
    maxS=max(speedDomain);
    minS=min(speedDomain);
    %
    XsigEst=maxS/3;
    XoffEst=speedDomain(find(targetResp==max(targetResp),1));
    IsigEst=maxS/3;
    IgainEst=1;
    RoEst=min(targetResp(:));
    AEst=max(targetResp(:));
    EST=[ XsigEst XoffEst IsigEst  IgainEst  RoEst AEst ];
    LOB=[ 25      0       25       eps       -100  eps  ];
    UPB=[ maxS*10 maxS*2  maxS*10  10        100   100  ];
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
        [FIT,~,residual] = lsqcurvefit(@fitFunc, EST, speedDomain, targetResp, LOB, UPB, options);  
        thisR2=jdR2(targetResp(:),residual(:));
        if thisR2>bestR2
            out.speedDomain=speedDomain;
            out.fitCurve=targetResp+residual;
            out.Xsig=FIT(1);
            out.Xoff=FIT(2);
            out.Isig=FIT(3);
            out.Igain=FIT(4);
            out.Ro=FIT(5);
            out.A=FIT(6);
            out.rss=sum(residual(:).^2);
            out.r2=jdR2(targetResp(:),residual(:));
            bestR2=thisR2;
            disp(['Current (' num2str(i) '/' num2str(nrStarts) ') best R2=' num2str(bestR2) ' NEW!']);
        else
            disp(['Current (' num2str(i) '/' num2str(nrStarts) ') best R2=' num2str(bestR2)]);
        end
        if bestR2>=1-eps
            break;
        end
    end
    function R=fitFunc(prms,speedDomain)
        R=speedResponseSimple( ...
            'domainDps',speedDomain ...
            ,'Xsig',prms(1) ...
            ,'Xoff',prms(2) ...
            ,'Isig',prms(3) ...
            ,'Igain',prms(4) ...
            ,'Ro',prms(5) ...
            ,'A',prms(6) );
    end
end




function out=fitComplexToData(speedDomain,targetResp)
    %
    % Set sensible estimated and boundaries
    maxS=max(speedDomain);
    minS=min(speedDomain);
    %
    MsigEst=maxS/2;
    XsigEst=maxS/3;
    XoffEst=speedDomain(find(targetResp==max(targetResp),1));
    IsigEst=maxS/3;
    IoffEst=-XoffEst/2;
    IgainEst=1;
    restInEst=.01;
    RoEst=min(targetResp(:));
    AEst=max(targetResp(:));
    EST=[MsigEst XsigEst XoffEst IsigEst IoffEst IgainEst restInEst RoEst AEst];
    LOB=[25      25      0       25      minS*2  eps        0       -100  eps ];
    UPB=[maxS*10 maxS*10 maxS*2  maxS*10  maxS*2 10       10        100   100 ];
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
        [FIT,~,residual] = lsqcurvefit(@fitFunc, EST, speedDomain, targetResp, LOB, UPB, options);  
        thisR2=jdR2(targetResp(:),residual(:));
        if thisR2>bestR2
            out.speedDomain=speedDomain;
            out.fitCurve=targetResp+residual;
            out.Msig=FIT(1);
            out.Xsig=FIT(2);
            out.Xoff=FIT(3);
            out.Isig=FIT(4);
            out.Ioff=FIT(5);
            out.Igain=FIT(6);
            out.restIn=FIT(7);
            out.Ro=FIT(8);
            out.A=FIT(9);
            out.rss=sum(residual(:).^2);
            out.r2=jdR2(targetResp(:),residual(:));
            bestR2=thisR2;
            disp(['Current (' num2str(i) '/' num2str(nrStarts) ') best R2=' num2str(bestR2) ' NEW!']);
        else
            disp(['Current (' num2str(i) '/' num2str(nrStarts) ') best R2=' num2str(bestR2)]);
        end
        if bestR2>=1-eps
            break;
        end
    end
    function R=fitFunc(prms,speedDomain)
        R=speedResponseComplexSimple( ...
            'domainDps',speedDomain ...
            ,'Msig',prms(1) ...
            ,'Xsig',prms(2) ...
            ,'Xoff',prms(3) ...
            ,'Isig',prms(4) ...
            ,'Ioff',prms(5) ...
            ,'Igain',prms(6) ...
            ,'restIn',prms(7) ...
            ,'Ro',prms(8) ...
            ,'A',prms(9) );
    end
end


function plotDataAndFit(speeds,targetResp,fit,spn)
    %
    % Plot the data
     subplot(spn(1),spn(2),spn(3),'align');
    plot(speeds,targetResp,'ko');
    hold on
    %
    % Plot the fitted curve decreasing contrast
    fineDomain=min(speeds):max(speeds);
    peakx=[];
    peaky=[];
    for contr=[.2:.2:1];
        opac=.05+contr*.95;
        [R,X,I]=speedResponseSimple( ...
            'domainDps',fineDomain ...
            ,'Xsig',fit.Xsig ...
            ,'Xoff',fit.Xoff ...
            ,'Isig',fit.Isig ...
            ,'Igain',fit.Igain ...
            ,'Ro',fit.Ro ...
            ,'A',fit.A ...
            ,'contrast',contr);
        subplot(spn(1),spn(2),spn(3),'align');
        plot(fineDomain,R,'Color',[0 0 0 opac],'LineWidth',2);
        hold on;
        if spn(1)>1
            subplot(spn(1),spn(2),spn(3)+spn(2),'align');
            plot(fineDomain,X,'Color',[1 0 0 opac],'LineWidth',2);
            hold on;
            plot(fineDomain,I,'Color',[0 0 1 opac],'LineWidth',2);
            axis tight
        end
        %
        peakx(end+1)=fineDomain(find(R==max(R),1));
        peaky(end+1)=max(R);
    end
    subplot(spn(1),spn(2),spn(3),'align');
    plot(peakx,peaky,'xr-');
    axis tight;
    %
    xlabel('Speed (deg/s)');
    ylabel('Response (IPS)');
    jdText(['R2 = ' num2str(fit.r2,'%.2f')]);
end
    
 


function [speed,resp]=rodmanAlbrightData(figStr)
    % Data copied form Rodman & Albright 1987 figure 6 and 7
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
        error('No such rodmanAlbrightData');
    end
    % set the minimum response to zero + somehting
  resp=resp-min(resp)+5;
  %  resp=resp/max(resp)*100;
end





function old
    findfig('jdSpeedContrast');
    clf;
    
    Xoff=[0 20 50]
    colNr=1;
    for i=1:numel(Xoff)
        for contr=[0 2.^[-6:1:0]]
            [R,dom,M,X,I]=speedResponse('Xsig',150,'Ioff',-Xoff(i),'Isig',100,'Xoff',Xoff(i),'contrast',contr);
            opacity=.1+sqrt(contr)*.9;
            %
            % M, X, I
            subplot(3,numel(Xoff),0*numel(Xoff)+colNr,'align')
            plot(dom,M,'Color',[0 1 0 opacity],'LineWidth',3); hold on
            plot(dom,X,'Color',[1 0 0 opacity],'LineWidth',2);
            plot(dom,I,'Color',[0 0 1 opacity],'LineWidth',2); axis tight
            %
            % (X-I)*M linear
            subplot(3,numel(Xoff),1*numel(Xoff)+colNr,'align')
            plot(dom,R,'Color',[0 0 0 opacity],'LineWidth',2); hold on, axis tight
            %
            % (X-I)*M semilogx
            subplot(3,numel(Xoff),2*numel(Xoff)+colNr,'align')
            semilogx(dom(dom>0),R(dom>0),'Color',[0 0 0 opacity],'LineWidth',2); hold on, axis tight
            %semilogx(dom(R==max(R)),max(R),'o','MarkerFaceColor',[0 0 0 opacity],'LineWidth',2);
        end
        colNr=colNr+1;
    end
    % tilefigs
end
