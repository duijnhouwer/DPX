function calibrateWarp
    
    filename='calib.mat';
    wid=1920;
    hei=1080;
   
    W=dpxCoreWindow;
    W.winRectPx=[wid 0 wid*2 hei];
    W.open;
    
    XX=120 : 120 : 1800;
    YY=120 : 120 : 1080-120; 
    YY=YY(randperm(numel(YY)));
    
    tel=1;
    cal=struct('xPx',[],'yPx',[],'aziDeg',[],'eleDeg',[]);
    try
        Screen('DrawDots',W.windowPtr,[wid/2 hei/2],15,[255 255 255]);
        Screen('Flip',W.windowPtr);
        input('<< There should be a huge central dot visible, Press ENTER to start calibrating >>');
        for x=XX(:)'
            for y=YY(:)'
                Screen('DrawDots',W.windowPtr,[x y],5,[255 255 255]);
                Screen('Flip',W.windowPtr);
                azi=[];
                ele=[];
                while isempty(azi)
                    s=input(['Point Nr ' num2str(tel) ' / ' num2str(numel(XX)*numel(YY)) ': [x y]=[' num2str(x) ' ' num2str(y) '] --> AZI in deg? (type nan if invisible) > '],'s');
                    azi=str2num(s); %#ok<*ST2NM>
                    if isnan(azi)
                        ele=nan;
                    end
                end
                while isempty(ele)
                    s=input(['--- Point Nr ' num2str(tel) ' / ' num2str(numel(XX)*numel(YY)) ': [x y]=[' num2str(x) ' ' num2str(y) '] --> ELE in deg? (type nan if invisible) > '],'s');
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