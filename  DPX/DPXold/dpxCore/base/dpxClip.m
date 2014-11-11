function [cv,didclip]=dpxClip(v,range)

% [v, didclip]=dpxClip(v,range) 
% Limit (hard-clip) the the range of vector v to
% [min(range) max(range)], no scaling.
%
% See also: dpxClamp
%
% jacob, 2013-10-10

mini=min(range);
maxi=max(range);
cv=v;
cv(cv<mini)=mini;
cv(cv>maxi)=maxi;
if nargout>1
    didclip=any(cv~=v);
end


