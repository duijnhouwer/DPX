function dpxLabel(varargin)

% xlabel ylabel zlabel in one
%
% Example:
% dpxLabel('x',[],'y','yaxis-label','z','z-values','FontSize',12)
% leaves the x-label as is, and changes the y and z string to the values
% indicated. The remainder of the inputs, like FontSize,12 in this example
% is passed on to the set axis-string command.
%
% jacob 2013-6-18

pipeToSet={};
[xstr,ystr,zstr]=deal([],[],[]); % set default values: do nothing
tel=1;
for i=1:numel(varargin)
    if strcmp(varargin{tel},'x')
        xstr=varargin{tel+1};
        tel=tel+2;
    elseif strcmp(varargin{tel},'y')
        ystr=varargin{tel+1};
        tel=tel+2;
    elseif strcmp(varargin{tel},'z')
        zstr=varargin{tel+1};
        tel=tel+2;
    else
        pipeToSet{end+1}=varargin{tel}; %#ok<AGROW>
        tel=tel+1;
    end
    if tel>numel(varargin)
        break;
    end
end

if ischar(xstr)
    set(get(gca,'Xlabel'),'String',xstr,pipeToSet{:});
end
if ischar(ystr)
    set(get(gca,'Ylabel'),'String',ystr,pipeToSet{:});
end
if ischar(zstr) 
    set(get(gca,'Zlabel'),'String',zstr,pipeToSet{:});
end