function [p,F] = watsonwilliams(varargin);
% Do a Watson-Williams n-sample test to determine whether the means of these 
% circular data distributions are significantly different. No posthoc test is available
%
% NOTE
% Assumption for this test is that all data drawn from a von Mises distrbutions with the
% same parameter of concentration (k) and the concentration of the averaged distribution 
% is sufficiently large k>2. (This is tested). 
% 
% INPUT
% c1 = A circular data object.
% c2 = A second circular data object.
% cn = The n-th circular data object.
% OUTPUT
% p = The p-value 
% F = The F-statistic.
%
% BK - 27.7.2001 - last change $Date: 2001/08/21 03:43:32 $ by $Author: bart $
% $Revision: 1.4 $

sets = nargin;
joint =circular;
n=0;
for i =1:sets
    [d1,R(i)]   = mstd(sum(varargin{i}));
    joint         = joint+varargin{i};
end
[d1,Rj] = mstd(sum(joint));

n = sum(joint.r); % The r variable contins the number of observations per angle.
rm = sum(R)/n;
% Find the corresponding k of the underlying von Mises distribution.
k = vonmisestable(n/sets,Rj);
if k<=2
    disp('The concentration of this distribution is too small to use the Watons Williams test');
    p = -1;
    F= NaN;
else
    g = 1+3/(8*k);
    F = g*(n-sets)./(sets-1) * (sum(R)-Rj)./(n -sum(R));
    p = 1-fcdf(F,sets-1,n-sets);
end