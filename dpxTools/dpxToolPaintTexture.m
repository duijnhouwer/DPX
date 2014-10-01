function dpxToolPaintTexture
    
    wid=1920/2;
    hei=1200/2;
    W=dpxCoreWindow;
    W.winRectPx=[0 0 wid hei];
    W.skipSyncTests=1;
    W.open;
    ShowCursor;
    
    canvas=zeros(wid,hei);
    
    maxDots=ceil(wid*hei+hypot(wid,hei));
    state.xx=nans(1,maxDots);
    state.yy=nans(1,maxDots);
    state.nDots=0;
    prevState=state;
    col=255;
    holding=false;
    while ~dpxGetEscapeKey
        [x,y,buttons]=GetMouse(W.windowPtr);
        if any(buttons)>0
            %if buttons(1) && ~buttons(3)
            %    col=255;
            %    prevState=state;
            %elseif buttons(3) && ~buttons(1)
            %    col=255;
            %    prevState=state;
            %elseif buttons(1) && buttons(3)
            %    tmp=state;
            %    state=prevState;
            %    prevState=tmp;
            %end
            % else
            %     col=0;
            % end
            x=min(max(round(x),1),wid);
            y=min(max(round(y),1),hei);
            if ~holding
                % draw a point where the user clicked
                state.nDots=state.nDots+1;
                state.xx(state.nDots)=x;
                state.yy(state.nDots)=y;
            else
                % draw a line between previous and current point
                dx=round(x-lastx);
                dy=round(y-lasty);
                if dx==0 && dy==0
                    newxx=x;
                    newyy=y;
                elseif dx==0
                    newyy=y:-sign(dy):lasty
                    newxx=ones(size(newyy))*x;
                else
                    newxx=x:-sign(dx):lastx;
                    newyy=round((newxx-x)*dy/dx+y);
                end
                nNew=numel(newxx);
                state.xx(state.nDots+1:state.nDots+nNew)=newxx;
                state.yy(state.nDots+1:state.nDots+nNew)=newyy;
                state.nDots=state.nDots+nNew;
            end
            if state.nDots==maxDots
                [~,ia]=unique(state.xx+state.yy*1i);
                state.xx=state.xx(ia);
                state.yy=state.yy(ia);
                state.nDots=numel(xx);
            end
            holding=true;
            lastx=x;
            lasty=y;
            % draw the dots
            xy=[state.xx(1:state.nDots);state.yy(1:state.nDots)];
            Screen('DrawDots',W.windowPtr,xy,3,255);
            Screen('Flip',W.windowPtr);
        else
            holding=false;
        end
    end
    ramp=25;
    xy=[state.xx(1:state.nDots);state.yy(1:state.nDots)];
    for flash=[0:ramp*2:255 255 255:-ramp:0 0]
        Screen('FillRect',W.windowPtr,flash,[0 0 wid hei]);
        Screen('DrawDots',W.windowPtr,xy,3,255);
        Screen('Flip',W.windowPtr);
    end
    sca
end
