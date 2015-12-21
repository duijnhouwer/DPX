function d = distance(phi,theta,signed)
% Calculates the angular distance between two angles. This is a non-circular quantity in the range
% [0, 180] (and linear% stats can be applied to it).
%
% INPUT
% phi   = A circular data object
% theta = An angle, a column vector of angles or a circular data object. Units must be the same as the units of phi.
% signed = Return the signed distance. Defaults to false
% OUTPUT
% d     = An angular distance, in the units of phi.
%
% BK - 29.7.2001 - last change $Date: 2001/08/21 03:50:12 $ by $Author: bart $
% $Revision: 1.3 $
if nargin<3
    signed = false;
end
        
if isa(theta,'CIRCULAR')
    t = rad(theta);
else
    if isdeg(phi)
        t = theta*pi/180;
    else
        t = theta;
    end
end

p = rad(phi);
if ~all(size(t)==size(p))
    if prod(size(t))==1
        t =repmat(t,size(p));
    elseif prod(size(p))==1
        p =repmat(p,size(t));
    else
        error ('Phi and Theta should be the same size (or a scalar)');
    end
end

d = acos(cos(p-t));

if signed
    if abs(mod(t+d,2*pi) -p)<=10*eps  % This seems to work for angles at least 0.5 deg apart...
        % Counterclockwise
    else
        %Clockwise
        d= -d;
    end
end
    
if isdeg(phi)
    d= d*180/pi;
end

if isempty(d) % Happens when phi or theta are empty...
    d= NaN;
end
    
