function [mPhi,mR,meanC,mConf,mS,p] = mstd(c,alpha)
% function [mPhi,mR,meanC,mConf,mS,p] = mstd(c,alpha)
% Determine the circular mean and its (1-alpha)% confidence interval as well as the p-value associated
% with the rayleigh test for non-randomness (i.e. is there a mean?)
%
% Corrects for grouping/binning if c.groups is set to the number of bins, and deals appropriately
% with axial data if c.axial =1.
%
% INPUT
% c = The circular object
% alpha = The alpha value for the confidence interval. Optional, defaults to 95% (alpha =0.05) 
%
% OUTPUT
% phi       = The mean angle.
% r         = The length of the mean vector
% meanC     = The mean circular data object.
% conf      = The x% confidence interval.
% s         = The standard deviation
% p         = P-value of the Rayleigh test
% NOTE
% The calculation of the confidence interval assumes linear statistics, hence only makes sense for
% small dispersions. 
%
% BK - 28.7.2001 - last change $Date: 2006/02/24 18:06:31 $ by $Author: micah $
% $Revision: 1.10 $

persistent warned;

if isempty(warned)
    warned = 0;
end
if nargin<2
    alpha =0.05;
end

if c.axial
    phi = mod(2*c.phi,2*pi);
else
    phi = c.phi;
end
r =c.r;

% 1. Possible nans reduce the n.
out = isnan(phi) | isnan(r);
n = sum(~out);

if (n==0)
    warning('CIRCULAR:mstd','No Data to determine circular mean');    
    mPhi=NaN;
    mR=NaN;
    meanC = circular(NaN,NaN,c.units,c.axial);
    mConf=NaN;
    mS=NaN;
    p=NaN;
    return;
end
%-----------------------------------------------------
% 2. Convert to cartesian and determine centre of mass
[a,b] = pol2cart(phi,r);
% Average
mX = bkmstd(a);
mY =  bkmstd(b);
mPhi = mod(2*pi+atan2(mY,mX),2*pi);
mPhi(mY==0 & mX==0) = NaN; % All average components are zero: No direction defined: NaN
mR   = sqrt(mX.^2 + mY.^2);
%-----------------------------------------------------
% 3. Correct for grouping and return to original coordinates.
if isgrouped(c)
    % Correct for the bias in the estimate of r that occurs when
    % the angles are binned in groups. (Batschelet, p.37)
    if c.axial
        % Doubling angles halves the number of groups/bins
        groupedCorrection = (2*pi/c.groups)./sin(2*pi/c.groups);
    else
        groupedCorrection = (pi/c.groups)./sin(pi/c.groups);
    end
    mR =mR * groupedCorrection;   
end
if c.axial
    mPhi = 0.5*mPhi;
end
if strcmpi(c.units,'DEG')
    mPhi = mPhi*180/pi;    
end
%-----------------------------------------------------
% 4. Create a new circular object
meanC = circular(mPhi,mR,c.units,c.axial);


%-----------------------------------------------------
% Part 2. Dependeing on output arguments, calculate 
% confidence intervals and statistics.
%-----------------------------------------------------
nout = nargout;
if nout >3
    %-----------------------------------------------------
    % 1. Confidence Intervals for the mean
    %-----------------------------------------------------
    if all(c.r==1)
        % Calculate the confidence interval for mean angle. Univariate problem.
        % (2 tailed t-test at p =alpha)
        mS = sqrt(2*(1-mR));
        if c.axial  mS = mS/2; end
        if isdeg(c) mS = mS*180/pi; end
        mConf = tinv(1-0.5*alpha,n-1)*mS./(sqrt(n)+eps);% Avoid divide by zero
    else 
        % Treat this as a bivariate problem: the lengths of the vectors play a role.
        if ~warned
            disp('Conf for bivariate not implemented yet'); 
            warned = 1;
        end
        mConf =[NaN NaN];
        nrTrials = size(a,1);
        aDiff = (a- repmat(mX,[nrTrials 1])).^2;
        aDiff(out) = 0;
        bDiff = (b - repmat(mY,[nrTrials 1])).^2;
        bDiff(out) = 0;
        mS = sqrt([sum(aDiff)./(n-1+eps) sum(bDiff)./(n-1+eps)]);
    end
    if nout >5
        %-----------------------------------------------------
        % 2. Statistics for directedness/non-randomness
        %-----------------------------------------------------        
        if all(r==1)
   			if n<30
   				p = pfromp(mR,n,'htable');
			else
%				p = pfromcritical(n*mR.^2,n,'hlargen');    

                % MDR 11/01/05 A Rayleigh distribution is simply a X2
                p = 1-chi2cdf(mR.^2.*n/2,2);
			end            
        else
            % Moore test (B. P.212) that takes the length of the vectors into account (in a second order
            % analysis they represent the certainty of that phi).
            t = bkrank(r);
            co = cos(phi).*t;
            co(isnan(co)) =0; % Get rid of nans
            si = sin(phi).*t;
            si(isnan(si)) = 0; % Get rid of nans
            C = sum(co);
            S = sum(si);
            Dstar = sqrt(C.^2 + S.^2)./(n.^(3/2)); % n is already aware of the nans.
%            p = pfromcritical(Dstar,n,'ptable');
            
            % MDR 11/01/05, the D* distribution is simply a X2
            % distribution.  The variance of C (and S) is n^3/6. So summing
            % them together makes a X2 distrubtion with two degrees of 
            % freedom.
            p = 1-chi2cdf((C.^2+S.^2)./(n.^3/6),2);
        end
    end    
end
    
    
    
