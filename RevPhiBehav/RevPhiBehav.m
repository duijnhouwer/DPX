% revPhiBehav
% Jacob Duijnhouwer, April 2014

function revPhiBehav
    [E,stimwin]=prepExperiment;
    E=runExperiment(E,stimwin);
    saveExperiment(E)
    endExperiment(E)
end

% --- FUNCTIONS -----------------------------------------------------------

function [E,stimwin]=prepExperiment
    warning off %#ok<WNOFF>
    E.subjectID='123';%upper(input('Subject ID > ','s'));
    E.scriptinfo=getInfoCurrentScript;
    [~,E.psychtoolboxversion]=PsychtoolboxVersion;
    E.openglinfo=opengl('data');
    [E.cond,E.nBlocks]=revPhiBehavSettings;
    [E.physScr,stimwin]=openStimWindow(); % physScr contains info on all physical display properties and pointer to window
end


function E=runExperiment(E,stimwin)
    try
        tr=0;
        for b=1:E.nBlocks
            for i=randperm(numel(E.cond))
                tr=tr+1;
                E.trial(tr).stim=createStimBasedOnSettings(E.cond(i),E.physScr);
                fillBackgroundStimWindow(stimwin,E.trial(tr).stim);
                Screen('Flip',stimwin);
                [escape,E.trial(tr).resp]=showStimulus(E.physScr,stimwin,E.trial(tr).stim);
                if escape
                    disp('Escape was pressed, the experiment is terminated');
                    E.trial(tr).message='This experiment was terminated manually (ESC)';
                    break;
                end
            end
        end
    catch %#ok<CTCH>
        saveExperiment(E);
        endExperiment(E);
        psychrethrow(psychlasterror);
    end
end


function scriptinfo=getInfoCurrentScript
    % Get all the lines of this file for future reference
    scriptinfo.name=[mfilename('fullpath') '.m'];
    fid=fopen(scriptinfo.name,'r');
    tline = fgetl(fid);
    nLines=0;
    while ischar(tline)
        nLines=nLines+1;
        scriptinfo.line{nLines}=tline;
        tline = fgetl(fid);
    end
    fclose(fid);
end


function [physScr,stimwin]=openStimWindow
    physScr.oldVerbosityLevel = Screen('Preference', 'Verbosity', 3);
    Screen('Preference','VisualDebuglevel', 0);
    Screen('Preference','SkipSyncTests',0);
    AssertOpenGL;
    %HideCursor;
    scr=Screen('screens');
    physScr.scrNr=max(scr);
    if physScr.scrNr==0
        [physScr.widPx, physScr.heiPx]=Screen('WindowSize',physScr.scrNr);%deal(500,300)%
        [physScr.widMm, physScr.heiMm]=Screen('DisplaySize',physScr.scrNr);
    elseif physScr.scrNr>=1 %instelling voor 20" CRT in visuele lab
        [physScr.widPx, physScr.heiPx]=Screen('WindowSize',physScr.scrNr);
        physScr.widMm = 406;
        physScr.heiMm = 305;
    else
        erstr=['Not handled: physScr.scrNr is ' num2str(physScr.scrNr)];
        disp(['Error: ' erstr ]);
        error(erstr);
    end
    physScr.whiteIdx=WhiteIndex(physScr.scrNr);
    physScr.blackIdx=BlackIndex(physScr.scrNr);
    physScr.distMm=1000;
    physScr.mm2px=physScr.widPx/physScr.widMm;
    physScr.deg2px=tand(1)*physScr.distMm*physScr.widPx/physScr.widMm;
    physScr.distPx=round(physScr.distMm*physScr.mm2px);
    [stimwin, physScr.winRect]=Screen('OpenWindow',physScr.scrNr,0,[0 0 physScr.widPx physScr.heiPx],[],2);
    physScr.frameDurS=Screen('GetFlipInterval',stimwin);
    Screen('BlendFunction',stimwin,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    Screen('Textfont',stimwin,'Arial');
    Screen('TextSize',stimwin,22);
end


function fillBackgroundStimWindow(stimwin,stim)
    Screen('FillRect',stimwin,stim.gray);
end


function stim=createStimBasedOnSettings(set,physScr)
    N=set.ndots;
    stim.nFlips.total=round(set.durS/physScr.frameDurS);
    stim.nFlips.pre=round(set.preS/physScr.frameDurS);
    stim.nFlips.post=round(set.postS/physScr.frameDurS);
    stim.widPx=physScr.widPx;
    stim.heiPx=physScr.heiPx;
    stim.xPx=rand(1,N)*stim.widPx;
    stim.yPx=rand(1,N)*stim.heiPx;
    stim.dotsize=repmat(set.dotradiusdeg*physScr.deg2px,1,N);
    stim.dotage=floor(rand(1,N)*set.nsteps);
    stim.maxage=set.nsteps;
    stim.gray=(physScr.blackIdx+physScr.whiteIdx)/2;
    stim.lum.max=255;
    stim.lum.min=0;
    stim.lum.pol=[ones(1,floor(N/2)) -ones(1,ceil(N/2))];
    stim.nFlipsPerStep=set.nFlipsPerStep;
    % make the speed trace
    stim.dx=makeFilteredTrace(set.dxFilt,physScr.frameDurS,stim.nFlips,1);
    stim.maxdx=set.maxDps*physScr.deg2px*physScr.frameDurS*set.nFlipsPerStep;
    stim.dx=stim.dx*stim.maxdx;
    % make the contrast trace
    stim.contrast=makeFilteredTrace(set.contrastFilt,physScr.frameDurS,stim.nFlips,0);
    % set the initial dot luminances
    stim.dotlums=calcLums(stim.lum,stim.contrast(1));
end

function T=makeFilteredTrace(F,frameDurS,nFlips,prepostfraction)
    npre=round(nFlips.pre*prepostfraction);
    npost=round(nFlips.post*prepostfraction);
    kernelWidFlips=round(F.sigmaSeconds*F.widSigmas/frameDurS);
    sigmaFlips=F.widSigmas/frameDurS;
    H=fspecial('gaussian',[1 kernelWidFlips],sigmaFlips);
    if strcmpi(F.noise,'rand')
        I=rand(1,nFlips.total-npre-npost)-.5;
    elseif strcmpi(F.noise,'randn')
        I=randn(1,nFlips.total-npre-npost);
    elseif strcmpi(F.noise,'bin')
        I=(rand(1,nFlips.total-npre-npost)>.5)*2-1;
    else
        error(['Unknown noise function: ''' F.noise '''.' ]);
    end
    %I=cumsum(I);
    I=I-mean(I);
    I=[zeros(1,npre) I zeros(1,npost)];
    T=imfilter(I,H,0);
    T=T/max(abs(T)); % [-1 .. 1]
    % Apply compression 1 mean no compression, 0 means full compression,
    % i.e., all values are either -1 or 1
    T=sign(T).*(abs(T).^F.compression);
end

function drawStim(stimwin,stim)
    xy=[stim.xPx(:)' ; stim.yPx(:)'];
    Screen('DrawDots',stimwin,xy,stim.dotsize,stim.dotlums,[],1);
end

function dotlums=calcLums(L,contrast)
    % negative contrast means polarity will flip
    dotlums=(L.pol*contrast+1)/2*(L.max-L.min)+L.min;
    dotlums=repmat(dotlums,3,1);
end
    


function stim=stepStim(stim,flipnr)
    % Reposition the dots, use shorthands for clarity
    x=stim.xPx;
    y=stim.yPx;
    w=stim.widPx;
    h=stim.heiPx;
    dx=stim.dx(flipnr);
    % Update dot lifetime
    stim.dotage=stim.dotage+1;
    expired=stim.dotage>stim.maxage;
    x(expired)=rand(1,sum(expired))*w-dx;
    y(expired)=rand(1,sum(expired))*h;
    stim.dotage(expired)=0;
    % Move the dots
    x=x+dx;
    if dx>0 
        x(x>=w)=x(x>=w)-w;
    elseif dx<0
        x(x<0)=x(x<0)+w;
    end
    stim.xPx=x;
    stim.yPx=y;
    % Update the colors
    stim.dotlums=calcLums(stim.lum,stim.contrast(flipnr));
end


function [esc,resp]=showStimulus(physScr,stimwin,stim)
    vbl=Screen('Flip',stimwin);
    resp.dx=NaN(1,stim.nFlips.total);
    resp.dy=NaN(1,stim.nFlips.total);
    resp.pollSec=NaN(1,stim.nFlips.total);
    for f=1:stim.nFlips.total
        esc=checkEscapeKey;
        if esc
            break;  
        end
        %fillBackgroundStimWindow(stimwin,stim)
        drawStim(stimwin,stim);
        if mod(f-1,stim.nFlipsPerStep)==0
            stim=stepStim(stim,f);
        end
        vbl=Screen('Flip',stimwin,vbl+0.75*physScr.frameDurS);
        resp=getResp(resp,f,physScr);
    end
end


function resp=getResp(resp,f,physScr)
    [x,y]=GetMouse;
    resp.dx(f)=x-physScr.widPx/2;
    resp.dy(f)=y-physScr.heiPx/2;
    resp.pollSec(f)=GetSecs;
    SetMouse(physScr.widPx/2,physScr.heiPx/2);
end


function escapePressed=checkEscapeKey
    escapePressed=false;
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown
        escapePressed=keyCode(KbName('Escape'));
    end
end


function saveExperiment(data)
    mkdir data;
    stop=false;
    i=1;
    while ~stop
        filename=fullfile('data',[mfilename '-' data.subjectID '-' num2str(i,'%.3d') '.mat']);
        if exist(filename,'file')
            i=i+1;
        else
            save(filename, 'data')
            disp(['Saved data to ''' fullfile(pwd,filename) ''''])
            stop=true;
        end
    end
end


function endExperiment(E)
    warning on %#ok<WNON>
    ShowCursor;
    Screen('Preference', 'Verbosity', E.physScr.oldVerbosityLevel);
    Screen('CloseAll');
end


