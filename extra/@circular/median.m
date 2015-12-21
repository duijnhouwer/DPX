function [cMedian,m,phi,r] = median(c,start)
% function [cMedian,m,phi,r] = median(c,start)
% Determine the circular median.
% INPUT
% c = The circular object
% [start] = Angle at which to start counting (CounterClockWise). Defaults to zero. Can be a circular object or a number in the units of c.
% OUTPUT
% cMedian = The median direction, as a circular object.
% m        = The median direction as a 2-vector
% phi       = The median angle.
% r         = The length of the median vector
% 
% BK - 28.7.2001 - last change $Date: 2001/08/02 01:02:03 $ by $Author: bart $
% $Revision: 1.2 $

if nargin <2
    start = 0;
end

if isa(start,'CIRCULAR')
    start = rad(start);
end

if c.axial
    % Double the angles in the original (c should not be passed back!)
    c.phi = mod(2*c.phi,2*pi);
end

[phi,sorted] = sort(c.phi);
r = c.r(sorted);

% Put the starting point below the first angle
% by warping back 360 degrees.
while( start > max(phi) )
    start = start -2*pi;
end

first = min(find(phi>=start));
if c.n/2 == round(c.n/2)
    %Even number: the mean between the two straddling the median.
    left            =  mod(first+c.n/2-2,c.n)+1;
    right           =  mod(left,c.n)+1;
    mPhi 			   = mstd(circular([phi(left) phi(right)]));
    mR              = 1;
else
    % Odd number of data. 
    index           = mod(first+floor(c.n/2)-1,c.n)+1;
    mPhi            = phi(index);
    mR              = 1;
end


if c.axial
    mPhi = [0.5* mPhi ; pi+0.5*mPhi];
    mR   = [mR; mR];
end


[m(1),m(2)] = pol2cart( mPhi(1),mR(1));
if strcmpi(c.units,'DEG')
   mPhi = mPhi.*180/pi;    
end

% Create a new circular object
cMedian = circular(mPhi,mR,c.units);
