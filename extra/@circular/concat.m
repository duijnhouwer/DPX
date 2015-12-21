function cn = concat(ca)
% Merge the circular objects in array of circular objects ca. The output
% object takes the unit (deg or rad) from ca(1). Axial and non-axial data
% cannot be combined.
% 
% INPUT
% c = A circular data object.
% d = An array of circular object
%
% OUTPUT
% cn = A new cicrcular data object with all angular and radial values of c
% and d concatenated
%
% EXAMPLE
% c=circ


cn=ca(1);
axia=cn.axial;
degr=isdeg(cn);
for i=2:numel(ca)
    tmp=ca(i); % method calls on index circobj (e.g. ca(i).r) don't work 
    if tmp.axial~=axia
        error('axial and non-axial circular objects can not be concatenated');
    end
    if degr
        cn =circular([deg(cn); deg(tmp)],[cn.r;  tmp.r],'deg',axia);
    else
        cn =circular([rad(cn); rad(tmp)],[cn.r; tmp.r],'rad',axia);
    end
end
