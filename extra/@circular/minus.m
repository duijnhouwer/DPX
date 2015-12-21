function d = minus(c1,c2)
% Subtract two circular data sets from each other. If either is a single vector, this vector is subtracted
% from all the data in the other set. If both are vectors or matrices, they should be of the same size.
% Units are inherited from c1 axiality only if c1 and c2 are axial.
% INPUT 
% c1 = A circular data object.
% c2 = A circular data object.
% OUTPUT
% cm = A circular data object.
% NOTE
% c1+c2 does something quite different: it adds data, not vectors!
%
% BK - 29.7.2001 - last change $Date: 2004/12/09 20:45:28 $ by $Author: bart $
% $Revision: 1.3 $

a = xprojection(c1) - xprojection(c2);
b = yprojection(c1) - yprojection(c2);
phi = atan2(b,a);
r = sqrt(a.^2 +b.^2);

if isdeg(c1)
    phi = phi *180/pi;
end
d = circular(phi,r,c1.units,c1.axial & c2.axial);