function [p,Tsquared]=hotelling(c1,c2)
% Hotelling one and two sample test. Determines whether the origin of the bivariate sample
% is significantly different from the origin. Or whether two bivariate samples are different
% from each other. This is a parametric test and it assumes that
% the parent populations are bivariate normal, with the same variance and covariance. Moreover the
% two samples should be independent and neither should be grouped.
%
% In most cases it makes more sense to use the equivalent hotelling function
% of the bivar class.
%
% INPUT
% c1=A circular object
% c2=Another circular object
%
% OUTPUT
% p=The probability that the center of the c distribution is at (0,0)
% T=The T-sqaured statistic for this test (it has an F(2,n-2) distribution.
%
% One Sample Tested with Batschelet Example 7.6.1
% x =[0 2 8 11 12 14 18 23];
% y=[3 8 5 11 4 16 9 8];
% [th,r]=cart2pol(x,y)
% c=circular(th,r)
% [pval Tsq]=hotelling(c)
%
% Two sample tested with Batschelet Example 7.7.1
%  x1=[0.866 0.710 0.704 0.597 0.409 0.505 0.540 0.586 0.645];
% y1=[-0.312 -0.452 -0.460 -0.441 -0.473 -0.672 -0.774 -0.667 -0.726];
% x2=[-0.022 0.027 0.016 0.108];
% y2=[-0.048 -0.328 -0.242 -0.204];
% [th1,r1] =cart2pol(x1,y1);c1=circular(th1,r1);
% [th2,r2] =cart2pol(x2,y2);c2=circular(th2,r2);
% [pval Tsq]=hotelling(c1,c2)
%
% See also: bivar/hotelling
%
% 2011/09/14: Fixed the two sample test, did not work prior to today. Jacob 
%
% BK - 29.7.2001 - last change $Date: 2004/12/09 20:45:28 $ by $Author: bart $
% $Revision: 1.5 $

nin=nargin;

if isgrouped(c1)
    error('The Hotelling test does not apply to grouped data');
end
if nin==2
    if isgrouped(c2)
        error('The Hotelling test does not apply to grouped data');
    end
end


if c1.axial
    phi1=2*c1.phi;
else
    phi1=c1.phi;
end

if nin==1
    % One Sample Test
    n1=c1.n;
    [~,~,mM,~,mS]=mstd(c1);
    sx=mS(1); sy=mS(2);
    xm=xprojection(mM);
    ym=yprojection(mM);
    [xi,yi]=pol2cart(phi1,c1.r);
    r=sum((xi-xm).*(yi-ym))./((n1-1).*sx.*sy);
    Tsquared=(n1./(1-r.^2)).*(((xm.^2)./(sx.^2)) - (2*r.*xm.*ym)./(sx.*sy) + (ym.^2)./(sy.^2));
    p=1-fcdf(Tsquared,2,n1-2);
else
    % Two sample test
    if c2.axial
        phi2=2*c2.phi;
    else
        phi2=c2.phi;
    end
    n1=c1.n;
    [x,y]=pol2cart(phi1,c1.r);
    xm1=mean(x);
    ym1=mean(y);
    SSx1=sum((x-xm1).^2);
    SSy1=sum((y-ym1).^2);
    C1=sum((x-xm1).*(y-ym1));
    %
    n2=c2.n;
    [x,y]=pol2cart(phi2,c2.r);
    xm2=mean(x);
    ym2=mean(y);
    SSx2=sum((x-xm2).^2);
    SSy2=sum((y-ym2).^2);
    C2=sum((x-xm2).*(y-ym2));
    %
    SSx=SSx1 + SSx2;
    SSy=SSy1 +SSy2;
    r=(C1+C2)/sqrt((SSx.*SSy));
    t1=(xm1-xm2)./sqrt((1./n1 + 1./n2)*(SSx/(n1+n2-2)));
    t2=(ym1-ym2)./sqrt((1./n1 + 1./n2)*(SSy/(n1+n2-2)));
    Tsquared=1./(1-r^2)*(t1^2 - 2*r*t1*t2 + t2^2);
    %
    % Find the p-value with fminbnd
    % This did not work prior to 20110914 because "abs" was omittted
    f=@(p)abs(Tsquared - 2*(n1+n2-2)/(n1+n2-3)*finv(p,2,n1+n2-3)); % zero at threshold p
    opt=optimset('TolX',10^-6,'MaxIter',5000,'MaxFunEvals',5000);
    [pComp,~,exitflag]=fminbnd(f,0,1,opt);
    if exitflag<=0
        disp ('Could not find a p-value for the Hotelling two sample test')
        p=NaN;
    else
        p=1-pComp;
    end
end
