function ax=dpxPlotUnityLine(varargin)
    
    % dpxPlotUnityLine adds a diagonal line (y=x) to the current plot
    % h=dpxPlotUnityLine(varargin) 
    % Style arguments (optional) can be passed that will be passed on to
    % Matlab's default plot command that draws the line. Jacob Duijnhouwer -
    % 20090411
    
    if nargin==-1
        style={'-k'};
    else
        style=varargin;
    end
    areholding=ishold;
    if ~areholding
        hold on
    end
    a=axis;
    mini=min(a);
    maxi=max(a);
    ax=[mini maxi mini maxi];
    axis(ax);
    if nargin==0
        plot([mini maxi],[mini maxi],'-k');
    else
        plot([mini maxi],[mini maxi],varargin{:});
    end
    if ~areholding
        hold off
    end
end