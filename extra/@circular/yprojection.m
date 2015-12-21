function v = yProjection(c)
% Return the y-components of the circular data.
% INPUT
% c = a circular data object.
% OUTPUT
% v = The x-components of these vectors.
%
% BK - 29.7.2001 - last change $Date: 2004/12/09 20:45:28 $ by $Author: bart $
% $Revision: 1.1 $

v = sin(c.phi).*c.r;