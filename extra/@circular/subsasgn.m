function c = subsasgn(c,subscript,value)
% function c = subsasgn(c,subscript,value)
% Subscript assignmemt for the @circular object. 
%
% BK  - 27.7.2001  - Last Change $Date: 2001/07/30 02:06:58 $ by $Author: bart $
% $Revision: 1.2 $

if length(subscript)>1
    error(c,'Cannot handle multiple subscript levels in assignment');
end

switch subscript.type   
case '.'   
    switch upper(subscript.subs)
        %----------------------- BASIC Properties ----------------------------------%
    case 'GROUPS'
        c.groups = value;
    case 'AXIAL'
        c.axial = value;
    otherwise 
        error (c, ['Property ' subscript.subs ' cannot be set']);
    end 	
end
