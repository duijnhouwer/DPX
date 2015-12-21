function [r,p,X] = veccorr(c1,c2);
% Parametric correlation coefficients for two sets of circular data or for circular and linear data. 
% This correlation measure works for large n, whether or not c1 and c2 are uniformly distributed 
% (as in corrcoef) and there is no problem dealing with ties (as in rankcorr). Uses the chi-squared
% distribution to test significance.
%
% INPUT
% c1     = Circular data
% c2     = Circular data object or linear data (as a vector)
%
% OUTPUT
% r  = The circular correlation coefficient
% p  = The p-value associated with the signficance of the r.
% X  = The Chisquared statistic.
% 
%  
% BK - 29.7.2001 - last change $Date: 2001/08/21 04:47:19 $ by $Author: bart $
% $Revision: 1.4 $


n = c1.n;
if isa(c2,'CIRCULAR')
    mode ='CIRCCIRC';
    m = c2.n;
else
    mode = 'CIRCLIN';
    m = length(c2);
    c2 = c2(:);
end

if n~=m
    error('These datasets have different numbers of entries');
end

phi1 = rad(c1);
  
switch (mode)
case 'CIRCCIRC'
    phi2 = rad(c2);
    m = [cos(phi1) sin(phi1) cos(phi2) sin(phi2)];
    cc = corrcoef(m);
    rcc = cc(1,3);
    rsc = cc(2,3);
    rss = cc(2,4);
    rcs = cc(1,4);
    r1  = cc(1,2);
    r2  = cc(3,4);
    % From Batschelet: eq 9.3.8 - p190
    r =sqrt((rcc^2 +rcs^2 +rsc^2 +rss^2 + 2*(rcc*rss +rcs*rsc)*r1*r2 - 2*(rcc*rcs +rsc*rss)*r2 -2*(rcc*rsc+rcs*rss)*r1)/((1-r1^2)*(1-r2^2)));
    df =4;
case 'CIRCLIN'
    error('Circ-Lin vector correlation needs a fit-function to determine the acrophase. NIY')
    m = [c2 cos(phi1) sin(phi1)];
    cc = corrcoef(m);
    ryc = cc(1,2);
    rys = cc(1,3);
    rcs = cc(2,3);
    r = sqrt((ryc^2 +rys^2 -2*ryc*rys*rcs)/(1-rcs^2));
    df =2;
end

% Calculate significance level
X = n*r*r;
p = 1- chi2cdf(X,df);
