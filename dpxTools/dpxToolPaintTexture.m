function dpxToolPaintTexture
    
    wid=1920/2;
    hei=1080/2;
    W=dpxCoreWindow;
    W.winRectPx=[0 0 wid hei];
    W.skipSyncTests=1;
    W.open;
    ShowCursor;

    M=false(wid,hei);
    col=true;
    holding=false;
    xy=[];
    while ~dpxGetEscapeKey
        [x,y,buttons]=GetMouse(W.windowPtr);
        if any(buttons)>0
            if buttons(1) && ~buttons(3)
                col=255;
            elseif buttons(3) && ~buttons(1)
                col=0;
            elseif buttons(1) && buttons(3)
            end
            x=min(max(round(x),1),wid);
            y=min(max(round(y),1),hei);
            if ~holding
                % draw a point where the user clicked
                M(x,y)=col;
                xy=[x;y];
            else
                % draw a line between previous and current point
                dx=x-lastx;
                dy=y-lasty;
                if any(abs([dx dy])>0)
                    alph=atan2(dy,dx);
                    len=hypot(dx,dy);
                    nSteps=ceil(max(abs([dx dy])));
                    steps=[len/nSteps:len/nSteps:len len];
                    xx=lastx+round(cos(alph)*steps);
                    yy=lasty+round(sin(alph)*steps);
                    M(sub2ind([wid hei],xx,yy))=col;
                    xy=[xx(:)';yy(:)'];
                end
            end
            holding=true;
            lastx=x;
            lasty=y;
            % draw the dots
            Screen('DrawDots',W.windowPtr,xy,3,col);
            Screen('Flip',W.windowPtr,0,1);
        else
            holding=false;
        end
    end
    ramp=25;
    for flash=[0:ramp*2:255 255 255:-ramp:0 0]
        Screen('FillRect',W.windowPtr,flash,[0 0 wid hei]);
        Screen('DrawDots',W.windowPtr,xy,1,255);
        Screen('Flip',W.windowPtr);
    end
    sca
end
