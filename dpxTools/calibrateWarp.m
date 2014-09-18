function calibrateWarp
    
    wid=192;
    hei=108;
    step=6;
    filename='calib.mat';
    
    W=dpxCoreWindow;
    W.winRectPx=[0 0 wid hei];
    W.open;
    
    XX=1:step:wid;
    YY=1:step:hei;
    YY=YY(randperm(numel(YY)));
    
    tel=1;
    cal=struct('xPx',[],'yPx',[],'aziDeg',[],'eleDeg',[]);
    try
        for x=XX(:)'
            for y=YY(:)'
                Screen('DrawDots',W.windowPtr,[x y],5,[255 255 255]);
                Screen('Flip',W.windowPtr);
                azi=[];
                ele=[];
                while isempty(azi)
                    s=input(['Point Nr ' num2str(tel) ' / ' num2str(numel(XX)*numel(YY)) ': azimuth in deg? (type nan if invisible) > '],'s');
                    azi=str2num(s); %#ok<*ST2NM>
                end
                while isempty(ele)
                    s=input(['Point Nr ' num2str(tel) ' / ' num2str(numel(XX)*numel(YY)) ': elevation in deg? (type nan if invisible) > '],'s');
                    ele=str2num(s);
                end
                cal.xPx(end+1)=x;
                cal.yPx(end+1)=y;
                cal.aziDeg(end+1)=azi;
                cal.eleDeg(end+1)=ele;
                save(filename,'cal');
                tel=tel+1;
            end
        end
    catch me
        sca
        rethrow(me);
    end
    
end