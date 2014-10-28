function escPressed=dpxDisplayText(windowPtr,text,varargin)
    % escPressed=dpxDisplayText(windowPtr,text,varargin)
    %
    % EXAMPLES:
    %
    % Display 'Press a key' that fades in 1 s and that fades out and
    % continues the after a key press and release
    % dpxDisplayText(windowPtr,'Press a key' ,'fadeOutSec',.5,,'fadeOutSec',-1);
    %
    % Display 'Saving...' that fades in for .5 s and then continues without
    % clearing the screen (text stays visible)
    % dpxDisplayText(windowPtr,'Saving...',,'fadeInSec',.5,'forceAfterSec',0,'fadeOutSec',-1);
    %
    
    % DO NOT REPLACE addParamValue WITH addParamter AS SUGGESTED BY MATLAB
    % 2014B BECAUSE IT WILL BREAK ON MATLAB <=2012B !!!
    % jacob, 2014-10-21
    
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('windowPtr',@(x)isnumeric(x));
    p.addRequired('str',@(x)ischar(x));
    p.addParamValue('rgba',[1 1 1 1],@(x)isnumeric(x) && numel(x)==4 && all(x<=1) && all(x>=0));
    p.addParamValue('rgbaback',[0 0 0 1],@(x)isnumeric(x) && numel(x)==4 && all(x<=1) && all(x>=0));
    p.addParamValue('fadeInSec',0.25,@isnumeric);
    p.addParamValue('fadeOutSec',.5,@isnumeric); % 0 = instant fade, <0 leave text on screen
    p.addParamValue('fontname','DefaultFontName',@(x)ischar(x));
    p.addParamValue('fontsize',25,@(x)isnumeric(x));
    p.addParamValue('dxdy',[0 0],@(x)isnumeric(x) && numel(x)==2);
    p.addParamValue('forceAfterSec',Inf,@isnumeric);
    p.addParamValue('commandWindowToo',true,@islogical);
    p.parse(windowPtr,text,varargin{:});
    %
    if p.Results.commandWindowToo
        str=regexp(p.Results.str,'\\n','split');
        for i=1:numel(str)
            disp(str{i});
        end
    end
    %
    oldFontName=Screen('Textfont',windowPtr,p.Results.fontname);
    oldTextSize=Screen('TextSize',windowPtr,p.Results.fontsize);
    [srcFactorOld, destFactorOld]=Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    startSec=GetSecs;
    % Fade-in the instructions
    fadeText(windowPtr,p.Results,'fadein');
    % wait for input ...
    KbName('UnifyKeyNames');
    FlushEvents([],[],'keyDown');
    pause(0.05);
    [~,~,keyCode]=KbCheck(-1);
    while ~keyCode(KbName('space')) && ~keyCode(KbName('Escape'));
        if GetSecs-startSec>p.Results.forceAfterSec
            keyCode(KbName('space'))=true; % emulate button press when time is up
        else
            [~,~,keyCode]=KbCheck(-1);
        end
    end
    escPressed=keyCode(KbName('Escape'));
    if escPressed
        % Dont fade out if escape is pressed, hurry up instead
    else
        escPressed=fadeText(windowPtr,p.Results,'fadeout');
        KbReleaseWait; % wait for key to be released
    end
    % Reset the original screen settings
    Screen('BlendFunction',windowPtr,srcFactorOld,destFactorOld);
    Screen('Textfont',windowPtr,oldFontName);
    Screen('TextSize',windowPtr,oldTextSize);
end

function escPressed=fadeText(windowPtr,p,how)
    escPressed=false;
    if ~any(strcmpi(how,{'fadein','fadeout'}))
        error(['Unknown fade option: ' how]);
    end
    framedur=Screen('GetFlipInterval',windowPtr);
    if strcmpi(how,'fadeout')
        if p.fadeOutSec<0
            return;
        end
        nFlips=floor(p.fadeOutSec/framedur)+1;
    else
        if p.fadeInSec<=0
            printText(p.str,windowPtr,p.rgba,p.rgbaback,1,p.dxdy);
            return;
        end
        nFlips=floor(p.fadeInSec/framedur)+1;
    end
    for f=1:nFlips
        opacity=(f-1)/(nFlips-1);
        if strcmpi(how,'fadeout')
            opacity=1-opacity;
        end
        printText(p.str,windowPtr,p.rgba,p.rgbaback,opacity,p.dxdy);
        if dpxGetKey('Escape')
            escPressed=true;
            break;
        end
    end
end



function printText(str,windowPtr,RGBAfore,RGBAback,opacityFrac,dxdy)
    if nargin<4 || isempty(opacityFrac)
        opacityFrac=1;
    end
    if nargin<5 || isempty(dxdy)
        dxdy=[0 0];
    end
    RGBAfore=RGBAfore*WhiteIndex(windowPtr);
    RGBAback=RGBAback*WhiteIndex(windowPtr);
    RGBAfore(4)=RGBAfore(4)*opacityFrac;
    for eye=[0 1]
        % works also in mono mode
        Screen('SelectStereoDrawBuffer', windowPtr, eye);
        Screen('FillRect',windowPtr,RGBAback);
        [w,h]=Screen('WindowSize',windowPtr);
        dx=dxdy(1);
        dy=dxdy(2);
        winRect=[max(0,dx) max(0,dy) min(w,w-dx) min(h,h-dy)];
        vLineSpacing=1.75;
        DrawFormattedText(windowPtr, str, 'center','center', RGBAfore, [], [], [], vLineSpacing, [], winRect);
    end
    Screen('Flip',windowPtr);
end

    
    