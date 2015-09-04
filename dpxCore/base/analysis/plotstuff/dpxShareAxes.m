function dpxShareAxes(handlesarr,whichaxis)

% dpxShareAxes(handlesarr,whichaxis)
% Set the limits of axis of different plots to the shared max and min
% handlesarr = array of handles to (sub) plots that need similar axes, e.g. [h1 h2]
% whicaxis = string of axes to manipulate, e.g. 'x', or 'xyz'

if nargin==0
    handlesarr=get(gcf,'Children');
    whichaxis='xyc';
elseif nargin==1
    whichaxis='xyc';
end
if nargin==2 && isempty(handlesarr)
    handlesarr=get(gcf,'Children');
end

if any(~ishandle(handlesarr))
    error('First argument should be a vector of handles');
elseif ~ischar(whichaxis)
    error('Second argument should be string with axes names, e.g. ''x'', or ''xyz''.');
end

% collect the current values
for a=upper(whichaxis)
    s.(a)=[];
    for h=handlesarr(:)'
        s.(a)=[ s.(a) get(h,[a 'lim']) ];
    end
end
% set to the global min and max
for a=upper(whichaxis)
    set(handlesarr,[a 'lim'],[min(s.(a)) max(s.(a))]);
end

