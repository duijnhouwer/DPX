function h=dpxPlotVert(X,varargin)

% h=dpxPlotVert(offset,stystr)
% Plots a vertical line in current plot at x value X and style
% stystr (eg. 'r:'). X can be an array of values, resulting in a vertical
% line at each value. 

if nargin==0
	X=0;
end
areholding=ishold;
if ~areholding
	hold on
end

a=find(strcmpi(varargin,'YLim'));
if ~isempty(a)
    ylims=varargin{a+1};
    varargin([a a+1])=[];
else
    ylims=get(gca,'Ylim');
end

h=zeros(numel(X),1); % handles to the lines
for i=1:numel(X)
    xx=X(i);
    h(i)=plot([xx xx],ylims,varargin{:});
end

if ~areholding
	hold off
end
