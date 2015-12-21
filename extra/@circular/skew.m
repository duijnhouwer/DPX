function skew =skew(c)
% function skew =skew(c)
% The skewness of the data in a circular object.
% INPUT 
% c = A circular object
% OUTPUT
% s = The skewness.
% Not tested on data whether the values are correct. 
% Batschelet p44.
%
% BK - 27.7.2001 - last change $Date: 2001/08/02 01:02:03 $ by $Author: bart $
% $Revision: 1.2 $
 


if c.n < 20
    warning ('Skewness for fewer than 20 datapoints is ill-defined')
end
[phi] = mstd(c);
c.axial = 1;
[phi2,r2] = mstd(c);
if isdeg(c) degToRad = 180/pi;else degToRad = 1; end
skew = r2* sin((degToRad * (phi2 - 2*phi)));
