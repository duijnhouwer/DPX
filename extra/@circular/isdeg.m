function bool = isdeg(c)
% Return whether the units are in degrees.
% INPUT 
% c = Circular data.
% OUTPUT
% bool = Yes or No
%
% BK - 27.7.2001 - last change $Date: 2001/08/21 04:47:18 $ by $Author: bart $
% $Revision: 1.3 $

bool = strcmpi(c.units,'DEG');