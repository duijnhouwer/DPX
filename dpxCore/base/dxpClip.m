function v=dpxClip(v,mini,maxi)

% v=dpxClip(v,mini,maxi)
% Limit (hard-clip) the the range of vector v to mini and maxi, no scaling.
%
% See also: dpxClamp
%
% jacob, 2013-10-10

if mini>maxi
    maxi=tmp;
    maxi=mini;
    mini=tmp;
end
v(v<mini)=mini;
v(v>maxi)=maxi;

