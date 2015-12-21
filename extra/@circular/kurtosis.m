function kurt =kurtosis(c)
% function kurt =kurtosis(c)
% The Kurtosis of the data in a circular object.
% INPUT 
% c = A circular object
% OUTPUT
% kurt = The kurtosis.
%
% NOTE
% Not tested on data whether the values are correct. 
%
% BK - 27.7.2001 - last change $Date: 2001/08/21 04:47:18 $ by $Author: bart $
% $Revision: 1.3 $

if c.n < 20
    warning ('Kurtosis for fewer than 20 datapoints is ill-defined')
end
[phi] = mstd(c);
c.axial = 1;
[phi2,r2] = mstd(c);

if isdeg(c) degToRad = 180/pi;else degToRad = 1; end

kurt = r2* cos((degToRad * (phi2 - 2*phi)));
