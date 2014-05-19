function jdPTBdisplayText(windowPtr,text,varargin)
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('windowPtr',@(x)isnumeric(x));
    p.addRequired('instructStr',@(x)ischar(x));
    p.addParamValue('rgb',[255 255 255],@(x)isnumeric(x) && numel(x)==1 || numel(x)==3);
    p.addParamValue('rgbback',[0 0 0],@(x)isnumeric(x) && numel(x)==1 || numel(x)==3);
    p.addParamValue('fadeInSecs',0.25,@isnumeric);
    p.addParamValue('fadeOutSecs',.5,@isnumeric);
    p.addParamValue('fontname','Arial',@(x)ischar(x));
    p.addParamValue('fontsize',22,@(x)isnumeric(x));
    p.addParamValue('dxdy',[0 0],@(x)isnumeric(x) && numel(x)==2);
    p.parse(windowPtr,text,varargin{:});
    %
    oldFontName=Screen('Textfont',windowPtr,p.Results.fontname);
    oldTextSize=Screen('TextSize',windowPtr,p.Results.fontsize);
    [sourceFactorOld, destinationFactorOld]=Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    % Fade-in the instructions
    fadeText(windowPtr,p.Results,'fadein');
    % wait for input ...
    KbName('UnifyKeyNames');
    keyIsDown=false;
    while ~keyIsDown
        [keyIsDown,~,keyCode]=KbCheck;
    end
    if ~keyCode(KbName('Escape'))
        % Only fade-out the text if a key other than escape is pressed (indicates hurry!)
        fadeText(windowPtr,p.Results,'fadeout');
        KbReleaseWait; % wait for key to be released
    end
    % Reset the original screen settings
    Screen('BlendFunction',windowPtr,sourceFactorOld,destinationFactorOld);
    Screen('Textfont',windowPtr,oldFontName);
    Screen('TextSize',windowPtr,oldTextSize);
end

function fadeText(windowPtr,p,how)
    instructStr=p.instructStr;
    if strcmpi(how,'fadein')
        durSecs=abs(p.fadeInSecs);
    else
        durSecs=-abs(p.fadeOutSecs);
    end
    framedur=Screen('GetFlipInterval',windowPtr);
    nFlips=abs(durSecs)/framedur;
    for f=1:nFlips
        translucency=(f-1)/(nFlips-1);
        if durSecs>0
            translucency=1-translucency;
        end
        printText(instructStr,windowPtr,p.rgb,p.rgbback,translucency,p.dxdy);
    end
end



function printText(instructStr,windowPtr,RGBfore,RGBback,translucency,dxdy)
    if nargin<4 || isempty(translucency)
        translucency=0;
    end
    if nargin<5 || isempty(dxdy)
        dxdy=[0 o];
    end
    if numel(RGBfore)==1;
        RGBfore=[RGBfore RGBfore RGBfore];
    end
    if numel(RGBback)==1;
        RGBback=[RGBback RGBback RGBback];
    end
    RGB=jdPTBblend(RGBback,RGBfore,translucency);
    for eye=[0 1]
        % works also in mono mode
        Screen('SelectStereoDrawBuffer', windowPtr, eye);
        Screen('FillRect',windowPtr,RGBback);
        [w,h]=Screen('WindowSize',windowPtr);
        dx=dxdy(1);
        dy=dxdy(2);
        winRect=[max(0,dx) max(0,dy) min(w,w-dx) min(h,h-dy)];
        vLineSpacing=1.75;
        DrawFormattedText(windowPtr, instructStr, 'center','center', RGB, [], [], [], vLineSpacing, [], winRect);
    end
    Screen('Flip',windowPtr);
end
