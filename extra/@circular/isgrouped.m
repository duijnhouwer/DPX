function bool= isgrouped(c)
% Determine whether these circular data are grouped.
% INPUT 
% c = Circular data object
% OUTPUT 
% bool = 1 or 0.
%
% NOTE
% This depends ont he user specifyig this, there is no way to calculate this.
%
% BK - 29.7.2001 - last change $Date: 2001/07/30 18:52:47 $ by $Author: bart $
% $Revision: 1.2 $


bool = c.groups>0 & ~isinf(c.groups);