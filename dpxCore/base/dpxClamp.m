function [cv,didclamp]=dpxClamp(v,range)

% [CV,DIDCLAMP]=dpxClamp(V,RANGE)
% Scale and offset vector V so it spans min(RANGE) to max(RANGE)
%
% See also: dpxClip
%
% jacob, 2013-10-10

mini=min(range);
maxi=max(range);
cv=v-min(v);
cv=cv./max(cv);
cv=cv*(maxi-mini);
cv=cv+mini;
if nargout>1
    didclamp=any(cv~=v);
end

