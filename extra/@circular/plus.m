function s = plus(c1,c2);
% Add the data in two circular objects.
% INPUT 
% c1 = A circular data object
% c2  = A circular data object
% OUTPUT
% s = A circular data object representing the union of the data in c1 and c2. Units are the units of c1.
%
% NOTE
% Axiality is inherited if both are axial
% 
% BK - 29.7.2001 - last change $Date: 2001/07/30 18:52:48 $ by $Author: bart $
% $Revision: 1.2 $


phi= [rad(c1); rad(c2)];
r = [c1.r; c2.r];

if isdeg(c1)
    phi = phi*180/pi;
end

s = circular(phi,r,c1.units,c1.axial & c2.axial);
