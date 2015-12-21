function [p,F,df1,df2] = ftest(c1,c2)
% Do a two-sample RF-test test on these circular data. I.e. test the null hypothesis that these samples
% are drawn from a von Mises distribution with the same k value (i.e. the same parameter of concentration)
% Two tailed, divide p by two for one tailed.
% INPUT
% c1     = Circular data
% c2     = Circular data
%
% OUTPUT
% p = The p-value to reject the null hypothesis.
% F = The F statistic
%
% BK - 29.7.2001 - last change $Date: 2001/08/02 01:02:03 $ by $Author: bart $
% $Revision: 1.2 $


nin =nargin;

if (c1.groups >0 & c1.groups  < 24) | ( c2.groups >0 & c2.groups  < 24) 
    warning('The groups are too large for the F-Test')
end

[d1,R1] = mstd(sum(c1));
[d1,R2] = mstd(sum(c2));
F = ((c2.n -1)*(c1.n-R1))./((c1.n-1)*(c2.n-R2));

if (F>1) 
    df1 = c1.n-1;    
    df2 = c2.n-1;
else
    F= 1./F; 
    df2 = c1.n-1;    
    df1 = c2.n-1;
end

p =2*(1-fcdf(F,df1,df2)); %Two tailed