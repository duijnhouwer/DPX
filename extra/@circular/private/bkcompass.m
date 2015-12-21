function hc = bkcompass(x,y,s,maxRho,nrSpokes)
%COMPASS Compass plot.
%   COMPASS(U,V) draws a graph that displays the vectors with
%   components (U,V) as arrows emanating from the origin.
%
%   COMPASS(Z) is equivalent to COMPASS(REAL(Z),IMAG(Z)). 
%
%   COMPASS(U,V,LINESPEC) and COMPASS(Z,LINESPEC) uses the line
%   specification LINESPEC (see PLOT for possibilities).
%
%   H = COMPASS(...) returns handles to line objects.
%
%   See also ROSE, FEATHER, QUIVER.

%   Charles R. Denham, MathWorks 3-20-89
%   Modified, 1-2-92, LS.
%   Modified, 12-12-94, cmt.
%   Modified, 99, BK.
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2001/08/23 19:16:06 $

a = ((0:4) + 1./2) ./ 4;
sq = sqrt(2) .* exp(-sqrt(-1) .* 2 .* pi .* a);

xx = [0 1 .8 1 .8].';
yy = [0 0 .08 0 -.08].';
arrow = xx + yy.*sqrt(-1);

if nargin == 2
   if isstr(y)
      s = y;
      y = imag(x); x = real(x);
     else
      s = [];
   end
  elseif nargin == 1
   s = [];
   y = imag(x); x = real(x);
end

x = x(:);
y = y(:);
if length(x) ~= length(y)
   error('X and Y must be same length.');
end

z = (x + y.*sqrt(-1)).';
a = arrow * z;

next = lower(get(gca,'NextPlot'));
isholdon = ishold;
[th,r] = cart2pol(real(a),imag(a));
if isempty(s),
  h = polar2(th,r,[]);
  co = get(gca,'colororder');
  set(h,'color',co(1,:))
else
  h = polar2(th,r,s);
end
if ~isholdon, set(gca,'NextPlot',next); end
if nargout > 0
   hc = h;
end
