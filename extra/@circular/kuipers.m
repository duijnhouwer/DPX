function [p,K] = kuipers(c,model)
% Do a one or two-sample Kuipers test on these circular data. I.e. test the null hypothesis that this sample
% is drawn from the given distribution. If the theoretical distribution is not specified, the homogeneous
% distribution is assumed, hence this becomes a test of non-randomness or directedness. 
%
% Data should not be grouped (or groupsize < 5 degrees) (If they are grouped, use Chisquared test,
% but Kuipers is more powerful)
% 
% NOTE 
% I cannot get the numbers right as in B78, but they are very close...
%
% INPUT
% c     = Circular data
% model = Model distribution to test again. Optional, defaults to homogeneous. Others must be
%           given as a circular data object,hence this becomes a two-sample test
%
% OUTPUT
% p = The p-value to reject the null hypothesis.
% R = The Kuipers statistic.
%
% BK - 29.7.2001 - last change $Date: 2001/08/21 03:48:02 $ by $Author: bart $
% $Revision: 1.3 $

nin =nargin;

if isgrouped(c) 
    warning('The Kuipers test is not ideal for grouped data!');
    if c.groups <72
        error('These groups are too large for the Kuipers  test! (Groupsize >5 degrees)')
    end
end

% Find the smallest change in Phi in Sample and Model
[phi1,index1]  = sort(c.phi);
dphi = diff(phi1);
dphi1 = min(dphi(dphi>0));
if nin==2
    [phi2,index2]  = sort(model.phi);
    dphi = diff(phi2);
    dphi2 = min(dphi(dphi>0));
else
    dphi2 = dphi1;
    phi2  = (0:dphi1:2*pi);
end
dphi = min(dphi1,dphi2);
u = 0:dphi:2*pi;
% Add the edges just to the left of a discontinuity.
u =[u u-eps];
u =sort(u);

s1 = nans(length(u),1);
s2 = nans(length(u),1);
cntr =1;
for i =u;
    s1(cntr,1) = sum(phi1<=i);
    s2(cntr,1) = sum(phi2<=i);
    cntr =cntr+1;
end

s1 =s1./s1(end);
s2 =s2./s2(end);

d       = (s2 - s1);
dPlus   = max(d(d>0));
dMinus  = min(d(d<0));
V       = abs(dPlus) + abs(dMinus);
K       = sqrt(c.n)*V;
p       = pFromCritical(K,c.n,'ntable');

if nargout ==0
    clf;
    plot(u,s1,'r*');
    hold on
    plot(u,s2,'b-');
    legend('Sample','Theory',2);
end

