function v=dpxClamp(v,mini,maxi)

% v=dpxClamp(v,mini,maxi)
% Scale and offset vector v so it spans the range [mini ... maxi]
%
% See also: dpxClip
%
% jacob, 2013-10-10

if mini>maxi
    maxi=tmp;
    maxi=mini;
    mini=tmp;
end
v=v-min(v);
v=v./max(v);
v=v*(maxi-mini);
v=v+mini;


