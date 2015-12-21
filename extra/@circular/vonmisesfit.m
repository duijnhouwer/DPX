function [vmf, est, estci, r2, ftest, residual]=vonmisesfit(c,varargin)

% Fit a Von Mises-based model to the circular object c using nlinfit. The
% fit model is a Von Mises curve spanned between the range of 0 and 1,
% multiplied by a gain and shifted by an offset. Sine skew is optional.
%
% INPUT
%   c: circular object containing data to be fit
%   varargin, string/value pairs:
%   'alpha' 100(1-alpha)% confidence intervals, default 0.05 (use 0.00269 for 3 sigma)
%   'fitopts' statset fit options. Default: statset(statset('nlinfit'),'Robust','on')
%   'allowskew' unlocks a fifth parameter that governs skew (Abe & Pewsey, 2009), default: false.
%   'domain' direction vector to use in vmf. Default: unique(rad(c)). Must be in the same units as used in c.
%
% OUTPUT
%   vmf: circular object containing fit values over the domain of c (c.phi)
%   est: struct with parameter estimates [theta,k,offset,gain,(skew)]
%   estci: 1-alpha confidence limits corresponding to est
%   r2: r-squared value of model (compared to mean)
%   ftest: nested f-test comparing the model to just an offset
%   resid: vector (numel=c.n) of residuals
%   
% Jacob Dec-2011
%
% TODO: fix circular/vonmises to produce a correct (starting) estimate for kappa
%
% See also circular/vonmises

p=inputParser;
p.addParamValue('c',@(x)isa(x,'circular'));
p.addParamValue('alpha',.05,@(x)isnumeric(x) && x>=0 && x<=1);
p.addParamValue('fitopts',statset(statset('nlinfit'),'Robust','on'),@isstruct);
p.addParamValue('allowskew',false,@(x)islogical(x));
p.addParamValue('domain',[],@(x)isempty(x) || isnumeric(x));
p.addParamValue('upsidedown',false,@islogical); 
p.parse(varargin{:});

if isempty(p.Results.domain)
    % make the domain for the circular object output vmf
    domain=unique(rad(c));
end

% all the fitting is done in radians
Xrad=rad(c);
if isdeg(c)
    c=circular(rad(c),c.r,'RAD');
    wasdeg=true;
else
    wasdeg=false;
end
% Y to be fit
Y=c.r;
if p.Results.upsidedown, Y=-Y; end

% Try a couple of starting estimates that best fit possible scenarios, pick
% the best fit afterwards
%beta0 = [prefdirrad,concentration,baserate,amplirate,skewfactor]
if p.Results.allowskew, skew=0; else skew=[]; end
Xpeak=Xrad(mod(round(median(find(Y==max(Y))))-1,numel(Xrad))+1); % complicated because the max value might occur a couple of times. this solution not really circular correct
beta0{1}=[ mstd(c) 5 min(Y) max(Y)-min(Y) skew];                        % peak at mean
beta0{2}=[ Xpeak 5 min(Y) max(Y)-min(Y) skew];                % peak at max
beta0{3}=[ mstd(c) .5 min(Y) max(Y)-min(Y) skew];                       % different kappa guess    
beta0{4}=[ Xpeak .5 min(Y) max(Y)-min(Y) skew];               % different kappa guess
beta0{5}=[ mstd(circular(rad(c),c.r)) .5 max(Y) min(Y)-max(Y) skew];    % from here on ... 
beta0{6}=[ Xpeak 5 max(Y) min(Y)-max(Y) skew];                % ... inverted ...
beta0{7}=[ mstd(circular(rad(c),c.r)) .5 max(Y) min(Y)-max(Y) skew];    % ... vonmises ...
beta0{8}=[ Xpeak .5 max(Y) min(Y)-max(Y) skew];               % ... (peak downward)
% Do the fits
sse=Inf; % keep track of best fit
nSuccesfullFits=0; % keep track of number fits that did not throw an error (happens)
for i=1:numel(beta0)
    try
        warning off
        [tmpbeta,tmpresidual,tmpJ,tmpCOVB,tmpmse] = nlinfit(Xrad,Y,@scaledsineskewvonmises,beta0{i},p.Results.fitopts);
        warning on
    catch me
        continue
    end
    if sumsqr(tmpresidual)<sse
        beta=tmpbeta;
        residual=tmpresidual;
        J=tmpJ;
        COVB=tmpCOVB;
        mse=tmpmse;
        sse=sumsqr(residual);
        nSuccesfullFits=nSuccesfullFits+1;
    end
end
if  nSuccesfullFits==0
    warning('[vonmisesfit] could not fit data'); 
    [vmf, est, estci, r2, ftest, residual]=deal(nan);
    return
end
% Get the confidence intervals
switch lower(p.Results.fitopts.Robust)
    case 'off'
        beci = nlparci(beta,residual,'jacobian',J,'alpha',p.Results.alpha);
    case 'on'
        if all(isnan(COVB(:))) % perfect fit, noisefree data, nlparci doesn't work
            beci=[beta(:) beta(:)];
        else
            beci = nlparci(beta,residual,'covar',COVB,'alpha',p.Results.alpha);
        end 
    otherwise, error(['Unknown option ''' p.Results.fitopts.Robust '''  for ''Robust''.']);
end
% nlinfit does not allow bounadary conditions, kappa can be negative. A
% negative kappa vonmises is pi radians rotated with respect to a the
% abs(kappa) equivalent). Translate into positive kappa vonmises here.
if beta(2)<0
    beta(2)=-beta(2);
    beci(2,:)=sort(-beci(2,:),'ascend');
    beta(1)=beta(1)+pi;
    beci(1,:)=beci(1,:)+pi;
end 
% make a circular object containing the fit over domain unique(rad(c)), or domainrad if it is specified
yh=scaledsineskewvonmises(beta,domain);
% calculate r-square
if nargout>=4
    tmpr=scaledsineskewvonmises(beta,rad(c));
    SStot=sum(power(c.r-nanmean(c.r),2));
    SSerr=sum(power(c.r-tmpr,2));
    r2=1-SSerr/SStot;
end
% compare model to just and offset with nested F-test
%See http://en.wikipedia.org/wiki/F-test (regression problems)
if nargout>=5
    Ns=1; % nr simple model params
    Nc=numel(beta); % nr complex model params
    ftest.Npar=[Ns Nc];
    ftest.ndata=c.n;
    ftest.F=((SStot-SSerr) / (Nc-Ns)) / (SStot/(ftest.ndata-Nc));
    ftest.Findex=[Nc-Ns ftest.ndata-Nc];
    ftest.p=1-fcdf(ftest.F,Nc-Ns,ftest.ndata-Nc);
    if ftest.p<p.Results.alpha
        ftest.str=sprintf('The scaled Von Mises model fitted significantly better than an offset at the p<%.3f level (nested F-test: F(%d,%d)=%.3f; p=%.4f).',p.Results.alpha,ftest.Findex(1),ftest.Findex(2),ftest.F,ftest.p);
    elseif ftest.p>=p.Results.alpha
        ftest.str=sprintf('The scaled Von Mises model did not fit better than an offset at the p<%.3f level (nested F-test: F(%d,%d)=%.3f; p=%.4f).',p.Results.alpha,ftest.Findex(1),ftest.Findex(2),ftest.F,ftest.p);
    end
end
% Convert output to deg if input was in deg format
if wasdeg
    beta(1)=beta(1)*180/pi;
    beci(1,:)=beci(1,:)*180/pi;
    vmf=circular(domain/pi*180,yh,'DEG');
else
    vmf=circular(domain,yh,'RAD');
end
% turn parameter array in readable struct
est.theta=mod(beta(1),2*pi);
estci.theta=mod(beci(1,:),2*pi);
est.k=beta(2);
estci.k=beci(2,:);
est.offset=beta(3);
estci.offset=beci(3,:);
est.gain=beta(4);
estci.gain=beci(4,:);
if p.Results.allowskew
    est.skew=beta(5);
    estci.skew=beci(5,:);
end
   

% Functions ------------------------------------------------------------


function S=scaledsineskewvonmises(prms,domainrad) % scaledsineskewvonmises
arad=prms(1); % direction pos of peak
k=prms(2); % von mises concetration (inv. prop. to width)
base=prms(3); % base firing rate
amp=prms(4); % peak firing rate (measured from base)
if numel(prms)>=5
    skew=prms(5);
else
    skew=0;
end
S=VonMisesSineSkew(domainrad,arad,k,skew);
if skew==0
    if k>=0
        globmin=VonMisesSineSkew(0,pi,k,skew);
        globmax=VonMisesSineSkew(0,0,k,skew);
    else
        % negative k gives 180 deg phase shift
        globmin=VonMisesSineSkew(0,0,k,skew);
        globmax=VonMisesSineSkew(0,pi,k,skew);
    end
else
    smoothdensedomain=-pi:pi/18000:pi-pi/18000;
    SS=VonMisesSineSkew(smoothdensedomain,arad,k,skew);
    globmin=min(SS);
    globmax=max(SS);
end
if globmin>globmax
    sibwarn('globmin>globmax, this was deemed impossible!!!, check code!');
    tmp=globmin;
    globmin=globmax;
    globmax=tmp;
end
S=S-globmin; % span range between 0 ... 
S=S/(globmax-globmin); % ... and 1
S=S*amp+base;


function o=VonMisesSineSkew(domainrad,a,k,lambda)
% function o=VonMisesSineSkew(x_rad,a,k,lambda) Returns a vector containing
% a Von Mises pdf with shape k and mean a, skewed by sine. The amount of
% skew is controlled by parameter lamba. Lambda zero means the pdf is
% unskewed and a regular Von Mises. Reference: Sine Skewed Circular Distr.,
% Abe & Pewsey, Stat Papers 2009
R=mod(domainrad-a+pi,2*pi)-pi;
o = exp(k*cos(R)) ./ (2*pi*besseli(0,k)) .* (1+lambda*sin(R));

