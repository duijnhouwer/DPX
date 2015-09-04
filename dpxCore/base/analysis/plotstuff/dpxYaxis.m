function current=dpxYaxis(mn,mx,tickstep,tickbase)
    
    % current=dpxYaxis(mn,mx,tickstep,tickbase)
    % Set the minimum and maximum y-axis values
    % Optionally set the tick spacing, offset
    % See also: dpxXaxis
    
    ax=axis;
    current=ax([3 4]);
    if nargin==0
        return;
    end
    if isempty(mn) || isnan(mn)
        mn=ax(3);
    end
    if isempty(mx) || isnan(mx)
        mx=ax(4);
    end
    axis([ax(1) ax(2) min([mn mx]) max([mn mx])]);
    current=ax([3 4]);
    % Set the tickmarks if requested
    if exist('tickstep','var')
        if exist('tickbase','var')
            up=tickbase:tickstep:mx;
            do=sort(tickbase-tickstep:-tickstep:mn,2,'ascend');
            ticks=[do(:)' up(:)'];
        else
            ticks=mn:tickstep:mx;
        end
        set(gca,'YTick',ticks);
    end
end