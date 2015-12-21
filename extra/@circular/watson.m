function [p,U] = watson(c,model)
% Do a one-sample Watson U test on these circular data. I.e. test the null hypothesis that this sample
% is drawn from the given distribution. If the theoretical distribution is not specified, the homogeneous
% distribution is assumed, hence this becomes a test of non-randomness or directedness.
%
% Data should not be grouped (If they are grouped, use Chisquared test, but Watson is more powerful, especially
% for small sample sizes.)
% 
%
% INPUT
% c     = Circular data
% model = Model distribution to test against. Optional, defaults to homogeneous. Others not implemented yet.
%
% OUTPUT
% p = The p-value to reject the null hypothesis.
% U = The Watson U statistic.
%
% BK - 27.7.2001 - last change $Date: 2001/08/21 03:43:58 $ by $Author: bart $
% $Revision: 1.3 $
nin =nargin;

if isgrouped(c) 
    error('The Watson test cannot be used for grouped data!');
end

[phi,index] = sort(c.phi);

if nin <2
    vi =  (phi./(2*pi));
else
    error( 'NIY')
end;
% Make sure vi is a column.
vi   = vi(:);

N = sum(c.r);
vm  = sum(vi)./N;
ci = 2*(1:c.n)'-1;
U  =  sum(vi.^2) - sum(ci.*vi/N) + N*(1/3 - (vm-0.5)^2);
p  = pFromCritical(U,c.n,'otable');

