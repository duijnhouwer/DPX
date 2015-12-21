function [p,U]=  mardia(c1,c2)
% Marida non-parameteric two sample bivariate test. Determines whether the centres of two bivariate samples
% differ significantly from each other  Assumes that the parent populations are continuous and identical except for 
% the possible location shift. The two samples should be independent and not grouped.
%
% Uses ranksum to do the final test.
%
% INPUT 
% c1 =  A circular object
% c2 = Another circular object
%
% OUTPUT
% p = The probability that the center of the c distribution is at (0,0)
% w = The ranksum statistic
%
%
% BK - 29.7.2001 - last change $Date: 2001/08/21 04:47:18 $ by $Author: bart $
% $Revision: 1.4 $

if isgrouped(c1) | isgrouped(c2)
    error('The Mardia test does not apply to grouped data');
end

if c1.axial
    phi1 = 2*c1.phi;
else
    phi1 = c1.phi;
end
if c2.axial
    phi2 = 2*c2.phi;
else
    phi2 = c2.phi;
end

all = circular([phi1 ; phi2],[c1.r ; c2.r]);
[d1,d2,cM] = mstd(all);
% Subtract this origin and discard the length inforamtion
c1 = circular(rad(c1 -cM));
c2 = circular(rad(c2 -cM));
% Now do a univariate ranksum test for circular data. (Mardia Watson Wheeler test would
% be an alternative but that is niy)
[p,U,w] = ranksum(c1,c2);

