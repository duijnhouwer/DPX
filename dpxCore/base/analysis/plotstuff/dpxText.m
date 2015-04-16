function h=dpxText(str,varargin)
    
    % function dpxText(str,varargin)
    %
    % Annotate a figure.
    %
    % Jacob Duijnhouwer, 2008
    %
    % See also: text
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Handle varargin list
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('str', @(x)ischar(x) || iscell(x));
    p.addParamValue('location','topleft',@(x)any(strcmpi(x,{'topleft','topright','bottomleft','bottomright','free'})));
    p.addParamValue('xgain',.98,@(x)x>=0&&x<=1);
    p.addParamValue('ygain',.98,@(x)x>=0&&x<=1);
    p.addParamValue('FontSize',12, @(x)x>0); % if smaller than 1, interpreted as proportional to Y-axis, otherwise a points
    p.addParamValue('Color', 'k');
    p.parse(str, varargin{:});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    plotwid=getMaxXaxis-getMinXaxis;
    plothei=getMaxYaxis-getMinYaxis;
    
    % take care of plots that may have reversed axis orientations (e.g. default imagesc)
    loc=p.Results.location;
    if strcmpi(get(gca,{'XDir'}),'reverse')
        if strfind(loc,'left')
            loc=regexprep(loc, 'left', 'right'); % e.g. topleft->topright
        else
            loc=regexprep(loc, 'right', 'left');
        end
    end
    if strcmpi(get(gca,{'YDir'}),'reverse')
        if strfind(loc,'bottom')
            loc=regexprep(loc, 'bottom', 'top');
        else
            loc=regexprep(loc, 'top', 'bottom');
        end
    end
    
    switch lower(loc)
        case 'topleft'
            x=getMinXaxis+plotwid*(1-p.Results.xgain);
            y=getMinYaxis+plothei*p.Results.ygain;
            hAlign='left';
            vAlign='top';
        case 'topright'
            x=getMinXaxis+plotwid*p.Results.xgain;
            y=getMinYaxis+plothei*p.Results.ygain;
            hAlign='right';
            vAlign='top';
        case 'bottomleft'
            x=getMinXaxis+plotwid*(1-p.Results.xgain);
            y=getMinYaxis+plothei*(1-p.Results.ygain);
            hAlign='left';
            vAlign='bottom';
        case 'bottomright'
            x=getMinXaxis+plotwid*p.Results.xgain;
            y=getMinYaxis+plothei*(1-p.Results.ygain);
            hAlign='right';
            vAlign='bottom';
        case 'free'
            x=getMinXaxis+plotwid*p.Results.xgain;
            y=getMinYaxis+plothei*p.Results.ygain;
            hAlign='center';
            vAlign='middle';
        otherwise
            error(['[' mfilename '] Unknown location option: ' loc ]);
    end
    if p.Results.FontSize>1
        fu='points';
    else
        fu='normalized';
    end
    h=text(x,y,str,'FontUnits',fu,'VerticalAlignment',vAlign,'HorizontalAlignment',hAlign,'Color',p.Results.Color);
    set(h,'FontSize',p.Results.FontSize);
end

function a=getMaxXaxis
    a=axis;
    a=max(a(1:2));
end
function a=getMinXaxis
    a=axis;
    a=min(a(1:2));
end
function a=getMaxYaxis
    a=axis;
    a=max(a(3:4));
end
function a=getMinYaxis
    a=axis;
    a=min(a(3:4));
end

