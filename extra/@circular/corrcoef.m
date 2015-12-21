function [r,p] = corrcoef(c1,c2);
% Correlation coefficient for two sets of circular data. 
% Both r's range from 0 to 1.
%
% INPUT
% c1     = Circular data
% c2     = Circular data
%
% OUTPUT
% r  = The circular correlation coefficient. r =max(r+,r-);
% p  = The p-value associated with the signficance of the r.
%
% NOTE
% This correlation measure is only valid for c1 and c2 uniform. Could do a rayleigh test to
% test this.
%
% See also rankcorr, veccorr for correlation coefficients with fewer assumptions on the
% data.
%
% BK - 29.7.2001 - last change $Date: 2001/08/02 01:02:03 $ by $Author: bart $
% $Revision: 1.3 $

n = c1.n;
if n~=c2.n
    error('These datasets have different numbers of entries');
end

diPlus = circular(rad(c1)-rad(c2));
[d1,rPlus] = mstd(diPlus);
diMinus = circular(rad(c1)+rad(c2));
[d1,rMinus] = mstd(diMinus);

[r,i] = max([rPlus,rMinus]);
if i==1
    p = htable(rPlus,diPlus.n);
else
    p = htable(rMinus,diMinus.n);
end


    