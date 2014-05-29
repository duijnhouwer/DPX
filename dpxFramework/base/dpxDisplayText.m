function keyIsDown=dpxDisplayText(windowPtr,text,varargin)
    try
        w=WhiteIndex(windowPtr);
        p = inputParser;   % Create an instance of the inputParser class.
        p.addRequired('windowPtr',@(x)isnumeric(x));
        p.addRequired('instructStr',@(x)ischar(x));
        p.addParamValue('rgba',[w w w w],@(x)isnumeric(x) && numel(x)==4);
        p.addParamValue('rgbaback',[0 0 0 w],@(x)isnumeric(x) && numel(x)==4);
        p.addParamValue('fadeInSecs',0.25,@isnumeric);
        p.addParamValue('fadeOutSecs',.5,@isnumeric);
        p.addParamValue('fontname','Arial',@(x)ischar(x));
        p.addParamValue('fontsize',22,@(x)isnumeric(x));
        p.addParamValue('dxdy',[0 0],@(x)isnumeric(x) && numel(x)==2);
        p.addParamValue('forceContinueAfterSecs',Inf,@isnumeric);
        p.parse(windowPtr,text,varargin{:});
        %
        oldFontName=Screen('Textfont',windowPtr,p.Results.fontname);
        oldTextSize=Screen('TextSize',windowPtr,p.Results.fontsize);
        [sourceFactorOld, destinationFactorOld]=Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
        startSecs=GetSecs;
        % Fade-in the instructions
        fadeText(windowPtr,p.Results,'fadein');
        % wait for input ...
        KbName('UnifyKeyNames');
        keyIsDown=false;
        keyIsDown=false;
        while ~keyIsDown && GetSecs-startSecs<p.Results.forceContinueAfterSecs
            [keyIsDown,~,keyCode]=KbCheck;
        end
        if keyIsDown && ~keyCode(KbName('Escape'))
            % Only fade-out the text if a key other than escape is pressed (indicates hurry!)
            fadeText(windowPtr,p.Results,'fadeout');
            KbReleaseWait; % wait for key to be released
        end
        % Reset the original screen settings
        Screen('BlendFunction',windowPtr,sourceFactorOld,destinationFactorOld);
        Screen('Textfont',windowPtr,oldFontName);
        Screen('TextSize',windowPtr,oldTextSize);
    catch me
        dpxEndExperiment;
        error(me.message);
    end
end

function fadeText(windowPtr,p,how)
    try
        if ~any(strcmpi(how,{'fadein','fadeout'}))
            error(['Unknown fade option: ' how]);
        end
        framedur=Screen('GetFlipInterval',windowPtr);
        nFlips=p.fadeOutSecs/framedur;
        for f=1:nFlips
            opacity=1-(f-1)/(nFlips-1);
            if strcmpi(how,'fadeout')
                opacity=1-opacity;
            end
            printText(p.instructStr,windowPtr,p.rgba,p.rgbaback,opacity,p.dxdy);
            if KbCheck
                break;
            end
        end
    catch me
        dpxEndExperiment;
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
        dpxEndExperiment;
        error(me.message);
    end
end
