function current=dpxXaxis(mn,mx,tickstep,tickbase)
    
    % current=dpxXaxis(mn,mx,tickstep,tickbase)
    % Set the minimum and maximum x-axis values
    % Optionally set the tick spacing, offset
    % See also: dpxYaxis
    
    ax=axis;
    current=ax([1 2]);
    if nargin==0
        return;
    end
    if isempty(mn) || isnan(mn)
        mn=current(1);
    end
    if isempty(mx) || isnan(mx)
        mx=current(2);
    end
    if mn==mx
        warning('[dpxXaxis] minimum equals maximum, returning without doing anything');
        return;
    end
    % set the new values
    axis([mn mx ax(3) ax(4)]);
    % return the new values (that are now current)
    current=ax([1 2]);
    
    if exist('tickstep','var')
        if exist('tickbase','var')
            up=tickbase:tickstep:mx;
            do=sort(tickbase-tickstep:-tickstep:mn,2,'ascend');
            ticks=[do(:)' up(:)'];
        else
            ticks=mn:tickstep:mx;
        end
        set(gca,'XTick',ticks);
    end
end