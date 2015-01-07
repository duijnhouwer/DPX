function h=dpxText(str,varargin)

% function dpxText(str,varargin)
%
% Annotate a figure.
%
% p.addRequired('str', @isstr);
% p.addOptional('location','topleft',@(x)any(strcmpi(x,{'topleft','topright','bottomleft','bottomright'})));
% p.addParamValue('xoffset', 5);
% p.addParamValue('yoffset', 5);
% p.addParamValue('FontSize', 8, @(x)x>0);
%
% Jacob Duijnhouwer, 2008
% 
% See also: text

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Handle varargin list
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('str', @(x)ischar(x) || iscell(x));
p.addParamValue('location','topleft',@(x)any(strcmpi(x,{'topleft','topright','bottomleft','bottomright'})));
p.addParamValue('xoffset', 5);
p.addParamValue('yoffset', 5);
p.addParamValue('FontSize', 8, @(x)x>0);
p.addParamValue('Color', 'k');
p.parse(str, varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
dx=p.Results.xoffset/100;
dy=p.Results.yoffset/100;

plotwid=jdGetMaxXaxis-jdGetMinXaxis;
plothei=jdGetMaxYaxis-jdGetMinYaxis;

% take care of plots that may have reveresed axes orientations (e.g. default imagesc)
xoffset=plotwid*dx;
yoffset=plothei*dy;
loc=p.Results.location;
if strcmpi(get(gca,{'XDir'}),'reverse')
     if strfind(loc,'left'), loc=regexprep(loc, 'left', 'right'); 
     else loc=regexprep(loc, 'right', 'left'); 
     end
     xoffset=-xoffset;
end
if strcmpi(get(gca,{'YDir'}),'reverse')
     if strfind(loc,'bottom'), loc=regexprep(loc, 'bottom', 'top'); 
     else loc=regexprep(loc, 'top', 'bottom'); 
     end
      yoffset=-yoffset;
end

switch lower(loc)
	case 'topleft'
		x=jdGetMinXaxis+xoffset;
		y=jdGetMaxYaxis-yoffset;
	case 'topright'
		x=jdGetMaxXaxis-xoffset;
		y=jdGetMaxYaxis-yoffset;
	case 'bottomleft'
		x=jdGetMinXaxis+xoffset;
		y=jdGetMinYaxis+yoffset;
	case 'bottomright'
		x=jdGetMaxXaxis-xoffset;
		y=jdGetMinYaxis+yoffset;
	otherwise
		error('Unknown location');
end
h=text(x,y,str);
set(h,'FontSize',p.Results.FontSize,'VerticalAlignment','top','Color',p.Results.Color);
