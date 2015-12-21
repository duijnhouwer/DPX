function [p,R] = rao(c)
% Do a one-sample Rao test on these circular data. This tests the null hypothesis that this sample
% is drawn from a random/uniform distribution.  Where Rayleigh and V test are only powerful for
% unimodal distributions, this Rao tests also works for multimodal distributions.
%
% The data cannot be grouped
% 
% INPUT
% c = Circular data
% OUTPUT
% p = The p-value to reject the null hypothesis.
% R = The Rao statistic in degrees or radians, depending on the units of c.
%
% BK - 27.7.2001 - last change $Date: 2001/08/21 03:45:37 $ by $Author: bart $
% $Revision: 1.2 $

if isgrouped(c) 
    warning('The Rao test is not suitable for grouped data');
end

if c.axial
    phi = sort(2*c.phi);
else
    phi = sort(c.phi);
end

Ti = [diff(phi) ; 2*pi+phi(1)-phi(end)];
R = 0.5* sum(abs(Ti-2*pi/c.n));
p = pFromCritical(180/pi*R,c.n,'ltable');

if isdeg(c)
    R = 180/pi*R;
end

if c.axial
    R = R/2;
end


