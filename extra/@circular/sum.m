function s= sum(c,start,stop,binWindow)
% Calculate the sum or resultant vector of this dataset.
%
% INPUT
% c = A circular data object
% start = Starting angle to start binning
% stop = Stop angle to stop binning
% binWindow = size of the binwindow.
% NOTE: start, stop, binwindow should be in the same units as the 
% circular data.
% OUTPUT
% s = A circular data object representing the sum of the data in c.
%
% BK - 29.7.2001 - last change $Date: 2001/07/30 18:52:48 $ by $Author: bart $
% $Revision: 1.2 $
nin = nargin;
if nin ==1
    x = sum(cos(c.phi).*c.r);
    y = sum(sin(c.phi).*c.r);
    r   = sqrt(x.^2 + y.^2);
    phi = mod(2*pi+atan2(y,x),2*pi);
    if isdeg(c)
        phi = phi*180/pi;
    end
else
    % This assumes that the stop and start are really the same...(i.e. once
    % round the circle)
    phi = 0.5*binWindow + (start:binWindow:(stop-binWindow));
    nrWindows = length(phi);
    r = zeros(1,nrWindows);    
    for w = 1:nrWindows
        stay = distance(c,phi(w)) < 0.5*binWindow;
        x = sum(cos(c.phi(stay)).*c.r(stay));
        y = sum(sin(c.phi(stay)).*c.r(stay));
        r(w)   = sqrt(x.^2 + y.^2);
    end
end

s = circular(phi,r,c.units);
