function [fig,create] = dpxFindFig(tag,varargin)
% function [fig_,create] = dpxFindfig(tag,varargin);
% DESCRIPTION
% Finds a figure specified by a tag or if it does not exist,
% creates one, gives it the tag as title and returns the handle.
%
% INPUT PARAMETERS
%	tag		Name of the figure, a string.
%    p.addOptional('visible',true,@islogical);
%    p.addOptional('position',[232 288 560 420],@(x)isnumeric(x) && numel(x)==4);
%
% OUTPUT PARAMETERS
%	fig_		Handle to the figure.
%	create		Flag.
%				1: Just created this figure.
%				0: Figure already existed.
% BK -8/1/97

% backward compatibility checks
if nargin>1
    tmp=[varargin{1}];
    if isnumeric(tmp) && numel(tmp)==4
        % this must be an old call to findfig. In the past, the optional second
        % argument was a position vector. I've changed that to a varargin for
        % input parsing. Jacob, 2012-10-12
        varargin={'position',tmp};
        warning('findfig(tag,position) is deprecated. Type ''edit findfig'' for info.');
    end
    clear tmp;
end
% end backward compatibility checks

p=inputParser;
p.addOptional('visible',true,@islogical);
p.addOptional('position',[232 288 560 420],@(x)isnumeric(x) && numel(x)==4);
p.parse(varargin{:});

if p.Results.visible, visi='on';
else visi='off';
end


fig_ = findobj(get(0,'children'),'flat','tag',tag);
if length(fig_) > 0
    %set(fig_,'visible',visi);
    figure(fig_);
    set(fig_,'visible',visi);
    create=0;
else
    fig_ = figure('visible','off');
    pause(0.01);
    set(fig_,'resize','on','tag',tag,...
        'visible','off','name',tag,'menubar','figure',...
        'numbertitle','off',...
        'paperunits','centimeters',...
        'position',p.Results.position);
    pause(0.01);
    set(fig_,'visible',visi);
    create=1;
end

if nargout >=1
    fig =fig_;
end
return;
