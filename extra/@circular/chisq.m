function [p,X,df] = chisq(c,e,df)
% Do a Chi-squared test on these circular data. This tests the null hypothesis that this sample
% is drawn from a random/uniform distribution. By specifying a particular model distribution
% in 'e', the goodness of fit of the sampling with a theoretical distribution can be tested.
% Note that if you use the samples to determine the parameters of the model distribution e,
% the degrees of freedom should be adjusted to reflect this. Specify the number of parameters
% in e you estimated from the data as the df argument
%
% The data must be grouped
% 
%
% INPUT
% c     = Circular data
% [e]   = Expected frequencies (optional, defaults to flat distribution)
% [df]  = Number of parameters of the expected distribution estimated from the data.
% OUTPUT
% p = The p-value to reject the null hypothesis.
% X = The Chi squared statistic
% df = The degrees of freedom of the Chi.
%
%
% BK - 27.7.2001 - last change $Date: 2001/08/21 04:47:18 $ by $Author: bart $
% $Revision: 1.2 $

nin =nargin;

if ~isgrouped(c)
    error('The Chi squared test needs grouped data!');
end

if nin <3
    df =0;
    if nin < 2
        e = sum(c.r)/c.groups .*ones(size(c.r));
end;end
% Make sure e is a column.
e = e(:);

if sum(c.r) < 5*c.groups
    warning('Chi squared test really needs more samples... (5*nrGroups)')
end

if any(size(e)~=size(c.r))
    error('The number of groups in the sample and in the model should be the same!')
end

if min(e)<4
    error('The ChiSquared test neeeds at least an expected count of four for each group')
end
    
X = sum(((c.r-e).^2)./e);
df = c.groups-1 -df;
p = 1- chi2cdf(X,df);




