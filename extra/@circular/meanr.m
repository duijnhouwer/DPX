function [mr,sr] = meanr(c,phiStart,phiStop)
% Determine the mean length of the vectors between angles phiStart and phiStop.
% This ignores directionality inside this range of angles.
% INPUT
% c =  A circular data object
% phiStart = Angle to start including vectors (DEG or RAD, depending on units of the circular data object)
% phiStop  = Angle to stop including vectros (DEG or RAD)
%
% OUTPUT
% mr = Mean length of the vectors in the range [phiStart,phiStop)
% sr = The standard deviation
%
% BK - 15.8.2001  - last change $Date: 2001/08/21 04:47:19 $ by $Author: bart $
% $Revision: 1.2 $



r =c.r;
stay = (distance(c,phiStart) < (phiStop-phiStart)) & (distance(c,phiStop) < (phiStop-phiStart));
r(~stay) = NaN;
[mr,sr] = bkmstd(r);
