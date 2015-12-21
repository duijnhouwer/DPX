function cn = normalise(c)
% Normalise the vectors in this circular data object.
% 
% INPUT
% c = A circular data object.
% OUTPUT
% cn = A new cicrcular data object whose vectors all have length 1.
%
% BK - 1.8.2001 - last change $Date: 2001/08/02 00:45:02 $ - by $Author: bart $
% $Revision: 1.1 $

if isdeg(c)
    cn =circular(deg(c),ones(c.n,1),'deg',c.axial);
else
    cn =circular(rad(c),ones(c.n,1),'rad',c.axial);
end

cn.groups = c.groups;