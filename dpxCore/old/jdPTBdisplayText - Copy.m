function jdPTBdisplayText(windowPtr,text,varargin)
    try
        w=WhiteIndex(windowPtr);
        p = inputParser;   % Create an instance of the inputParser class.
        p.addRequired('windowPtr',@(x)isnumeric(x));
        p.addRequired('instructStr',@(x)ischar(x));
        p.addParamValue('rgba',[w w w w],@(x)isnumeric(x) && numel(x)==4);
        p.addParamValue('rgbaback',[0 0 0 w],@(x)isnumeric(x) && numel(x)==4);
        p.addParamValue('fadeInSec',0.25,@isnumeric);
        p.addParamValue('fadeOutSec',.5,@isnumeric);
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
            [keyIsDown,~,keyCode]=KbCheck(-1);
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
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end

function fadeText(windowPtr,p,how)
    try
        instructStr=p.instructStr;
        if strcmpi(how,'fadein')
            durSecs=abs(p.fadeInSec);
            finalOpac=1;
        else
            durSecs=-abs(p.fadeOutSec);
            finalOpac=0;
        end
        framedur=Screen('GetFlipInterval',windowPtr);
        nFlips=abs(durSecs)/framedur;
        for f=1:nFlips
            opacity=1-(f-1)/(nFlips-1);
            if durSecs>0
                opacity=1-opacity;
            end
            printText(instructStr,windowPtr,p.rgba,p.rgbaback,opacity,p.dxdy);
            if jdPTBgetEscapeKey
                printText(instructStr,windowPtr,p.rgba,p.rgbaback,finalOpac,p.dxdy);
                break;
            end
        end
    catch me
        jdPTBendExperiment;
        disp(me.message);
        keyboard
    end
end



function printText(instructStr,windowPtr,RGBAfore,RGBAback,opacityFrac,dxdy)
    try
        if nargin<4 || isempty(opacityFrac)
            opacityFrac=1;
        end
        if nargin<5 || isempty(dxdy)
            dxdy=[0 0];
        end
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
            DrawFormattedText(windowPtr, instructStr, 'center','center', RGBAfore, [], [], [], vLineSpacing, [], winRect);
        end
        Screen('Flip',windowPtr);
    catch me
        jdPTBendExperiment;
        error(me.message);
    end
end
