function labelHandles=dpxSubplotLabels(h,labels,varargin)
   
    % labelHandles=dpxSubplotLabels(h,labels,varargin)
    %
    % DESCRIPTION:
    %   Provide labels A B C etc to the subplots in a figure.
    %   Optional argument H can be a handle to a figure, or a string representing the
    %   title of the figure. When omitted, the current figure window wil be used (gcf)
    %
    % EXAMPLES:
    %   % Standard
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,[3 4]);
    %   dpxSubplotLabels;
    %
    %   % Bigger, bold font
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,[3 4]);
    %   dpxSubplotLabels([],[],'FontSize',14,'FontWeight','bold');
    %
    %   %alternatively, set the properties afterwards
    %   subplot(2,2,1);
    %   subplot(2,2,[2 4]);
    %   subplot(2,2,3);
    %   h=dpxSubplotLabels;
    %   set(h,'Color',[0 0 1],'FontSize',18)
    %
    %   % Explicit figure referencing, two methods
    %   h = findfig('Test2');
    %   subplot(2,1,1);
    %   subplot(2,1,2);
    %   if rand>.5
    %       dpxSubplotLabels(h); % handle reference
    %   else
    %       dpxSubplotLabels(Test2'); % title reference
    %   end
    %
    %   % Freestyle labels (but limited to 1 or no character)
    %   h = findfig('Test2');
    %   subplot(2,2,1);
    %   subplot(2,2,2);
    %   subplot(2,2,3);
    %   subplot(2,2,4); 
    %   dpxSubplotLabels(h,'A2 Z');
    %
    % AUTHOR:
    %   Jacob Duijnhouwer, 2015-12-10
    %
    % See also: text, findfig

    if ~exist('h','var') || isempty(h)
        h=gcf;
    end
    if ischar(h)
        h=findfig(h,'create',false);
        if isempty(h)
            error(['Could not find figure with title ''' h '''.']);
        end
    end
    if isa(h,'matlab.ui.Figure')
        
    end
    A=findobj(h,'Type','Axes');
    if isempty(A)
        warning('No axes to label');
        return;
    end
    A=A(end:-1:1);
    if ~exist('labels','var') || isempty(labels)
        labels=char(64+(1:numel(A)));
    elseif numel(A)~=numel(labels)
        error('order vector and number of panels don''t match up. Use whitespace to skip panels');
    elseif ~ischar(labels)
        error('labels should be char or empty');
    end
    wids=nans(size(A));
    for i=1:numel(A)
        if labels(i)==' ';
            continue;
        end
        oldUnits=A(i).Units;
        A(i).Units='pixels';
        wids(i)=A(i).Position(3);
        A(i).Units=oldUnits;
    end
    medianWid=nanmedian(wids); clear wids;
    labelHandles=[];
    for i=1:numel(A)
        if isnan(labels(i))
            continue;
        end
        axes(A(i)); %#ok<LAXES>
        oldUnits=A(i).Units;
        A(i).Units='pixels';
        wid=A(i).Position(3);
        A(i).Units=oldUnits;
        xOffset=-0.1*medianWid/wid;
        try
            t=text(xOffset,1,labels(i),varargin{:},'Units','normalized');
        catch me
            try
                warning(me.message)
                t=text(xOffset,1,labels(i),'Units','normalized');
            catch me
                rethrow(me);
            end
        end  
        % If fontsize wasn't defined, use default 14
        if ~any(strcmpi('FontSize',varargin))
            t.FontSize=14;
        end
        t.HorizontalAlignment='right';
        t.VerticalAlignment='bottom';
        labelHandles(end+1)=t;
    end
end