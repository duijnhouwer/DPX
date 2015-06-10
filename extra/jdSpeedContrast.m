function jdSpeedContrast(contrast)
    
    
    
    if nargin==0
        for i=(6:-.5:1).^2
            jdSpeedContrastCore(1/i);
        end
    else
        jdSpeedContrastCore(contrast);
    end
end




function jdSpeedContrastCore(contrast)
    
    gray=.9-sqrt([contrast contrast contrast])*.9;
    
    if nargin==0
        clf
        contrast=1;
    end
    
    
    sRange=-512:512;
    
    if true
        % perfect S1 (symmetric around 0)
        Xoff=64;
        Xsig=64;
        Ioff=0;
        Isig=32;
        Moff=0;
        Msig=64;
    else
        % perfect S2
        Xoff=64;
        Xsig=128;
        Ioff=-64;
        Isig=64;
        Moff=0;
        Msig=64;
    end
    
    
    
    %  Xpeak=normpdf(0,0,Xsig);
    %  Ipeak=normpdf(0,0,Isig);
    
    X=normpdf(sRange,Xoff,Xsig);
    I=normpdf(sRange,Ioff,Isig);
    M=normpdf(sRange,Moff,Msig);
    
    X=X./sum(X);
    I=I./sum(I);
    M=M./sum(M);
    
    X=X./max(X);
    I=I./max(I);
    M=M./max(M);
    
    
    
    X=X*sqrt(contrast);
    I=I*contrast;
    
    R=(.2+(X-I)).*M;%.*cumGauss;
    
    subplot(2,1,1)
    plot(sRange,R,'Color',gray,'LineWidth',2); hold on, axis tight
    subplot(2,1,2);
    semilogx(sRange(sRange>0),R(sRange>0),'Color',gray,'LineWidth',2); hold on, axis tight
    semilogx(sRange(R==max(R)),max(R),'+','MarkerEdgeColor',gray,'LineWidth',2);
    
    
end



function r=logGaussian(sRange,Ro,A,sig,So,Sp)
    % where r is the firing rate and s the
    % stimulus speed in degrees per second. The function has five free
    % parameters: R0, the spontaneous firing of the cell;A, the peak amplitude;
    % ? , the (logarithmic) tuning width; s0, anoffset speed; and sp, the
    % preferred speed (Nover et al., 2005) --- Krekelberg et al., 2006)
    
    r=Ro+A*exp(-(1/(2*sig^2))*(log((sRange+So)/(Sp+So))).^2);
end