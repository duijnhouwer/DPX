function deg = deg(c)
% Returns the angles in degrees.
% INPUT 
% c = Circular object
% OUTPUT
% deg = Degrees
%
% BK - 29.7.2001 - last change $Date: 2001/07/30 18:52:47 $ by $Author: bart $
% $Revision: 1.2 $


deg = c.phi.*180/pi;
