function [hl,hb]=dpxPlotBounded(varargin)
    
    p = inputParser;   % Create an instance of the inputParser class.
    p.addParamValue('x',[],@(x)jdIsVector(x));
    p.addParamValue('y',[],@(x)jdIsVector(x));
    p.addParamValue('eu',[],@(x)jdIsVector(x));
    p.addParamValue('ed',[],@(x)jdIsVector(x));
    p.addParamValue('Color','',@(x)isempty(x)||ischar(x)||(isnumeric(x)&&numel(x)==3));
    p.addParamValue('FaceColor','k',@(x)isempty(x)||ischar(x)||(isnumeric(x)&&numel(x)==3));
    p.addParamValue('LineColor','k',@(x)isempty(x)||ischar(x)||(isnumeric(x)&&numel(x)==3));
    p.addParamValue('FaceAlpha',1/3,@(x)isnumeric(x));
    p.addParamValue('LineWidth',.5,@(x)isnumeric(x));
    p.addParamValue('LineStyle','-',@(x)isnumeric(x));
    % Note that you can always change the properties of the line and the bounds
    % using the output handles 'hl' and 'hb' respectively
    p.parse(varargin{:});
    %
    x=p.Results.x(:)';
    y=p.Results.y(:)';
    eu=p.Results.eu(:)';
    ed=p.Results.ed(:)';
    assert(~any(diff([numel(x) numel(y) numel(eu) numel(ed)])),'X Y EU ED must have same dimensionality');
    if ~isempty(p.Results.Color)
        lineCol=p.Results.Color;
        faceCol=lineCol;
    else
        lineCol=p.Results.LineColor;
        faceCol=p.Results.FaceColor;
    end
    %
    PVX=[x x(end:-1:1)]; % Patch vertices X
    PVY=[y-ed y(end:-1:1)+eu(end:-1:1)]; % Patch vertices Y
    hb=patch(PVX(:),PVY(:),faceCol,'FaceAlpha',p.Results.FaceAlpha,'LineStyle','none');
    wasHold=ishold;
    if ~wasHold, hold on; end
    hl=plot(x,y,'-','Color',lineCol,'LineWidth',p.Results.LineWidth,'LineStyle',p.Results.LineStyle);
    if ~wasHold, hold off; end
end