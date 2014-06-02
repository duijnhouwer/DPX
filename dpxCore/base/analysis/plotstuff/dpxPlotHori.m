function h=dpxPlotHori(Y,varargin)

% h=dpxPlotHori(offset,stystr)
% Plots a horizontal line in current plot at values in offset with style
% stystr (eg. 'r:'). X can be an array of values, resulting in a horizontal
% line at each value. 

if nargin==0
	Y=0;
end
areholding=ishold;
if ~areholding
	hold on
end

a=find(strcmpi(varargin,'XLim'));
if ~isempty(a)
    xlims=varargin{a+1};
    varargin([a a+1])=[];
else
    xlims=get(gca,'Xlim');
end

h=zeros(numel(Y),1); % handles to the lines
for i=1:numel(Y)
    yy=Y(i);
    h(i)=plot(xlims,[yy yy],varargin{:});
end

if ~areholding
	hold off
end