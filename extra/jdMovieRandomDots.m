function jdMovieRandomDots(varargin)
    
    % jdMovieRandomDots(varargin)
    % Function to generate animated random dot movies
    %
    % EXAMPLE:
    %    % A 4-second movie of a 3.5-pixels per frame leftward grating:
    %    jdMovieRandomDots('dX',-3.5,'frHz',30,'frN',120)
    %
    % See also: jdMovieToArray
    %
    % Jacob Duijnhouwer, October 2014
    
    p=inputParser;
    p.addOptional('folder',pwd,@(x)exist(x,'file')); %
    p.addOptional('filename','',@(x)ischar(x) || isempty(x));
    p.addOptional('pxHor',200,@(x)isnumeric(x) && ~rem(x,1) && x>0 && numel(x)==1); % width of movie
    p.addOptional('pxVer',200,@(x)isnumeric(x) && ~rem(x,1) && x>0 && numel(x)==1); % height of movie
    p.addOptional('rPx',100,@(x)isnumeric(x)); % radius of the stimulus aperture
    p.addOptional('frN',90,@(x)isnumeric(x) && ~rem(x,1) && x>0 && numel(x)==1); % number of frames
    p.addOptional('frHz',30,@(x)isnumeric(x) && x>0 && numel(x)==1); % frame rate
    p.addOptional('nDots',500,@(x)isnumeric(x) && ~rem(x,1) && numel(x)==1); % number of dots
    p.addOptional('dX',3,@(x)isnumeric(x) && numel(x)==1); % pixels displacement per frame
    p.addOptional('dY',0,@(x)isnumeric(x) && numel(x)==1); % pixels displacement per frame
    p.addOptional('dotRadiusPx',6,@(x)isnumeric(x) && x>0 && numel(x)==1 && ~mod(x,2)); % dot radius in pixels, must be even!
    p.addOptional('stepFr',Inf,@(x)isnumeric(x) && x>0 && numel(x)==1); % number of steps a dot takes befores being refreshed
    p.addOptional('coherence',1,@(x)isnumeric(x) && x>=0 && x<=1 && numel(x)==1); % coherent motion fraction
    p.addOptional('revphi',false,@(x)islogical(x) || x==1 || x==0);
    p.addOptional('deltaDeg',[0 90],@isnumeric); % angular deviations of transparent motion components from dx dy values, e.g. [0 180] two opposite motions
    p.addOptional('RGB0',[.5 .5 .5],@(x)isnumeric(x) && all(x>=0) && all(x<=1) && numel(x)==3); % rgb background
    p.addOptional('RGB1',[0 0 0],@(x)isnumeric(x) && all(x>=0) && all(x<=1) && numel(x)==3); % rgb dots 1
    p.addOptional('RGB2',[1 1 1],@(x)isnumeric(x) && all(x>=0) && all(x<=1) && numel(x)==3); % rgb dots 2
    p.addOptional('aaPx',8,@(x)isnumeric(x) && ~rem(x,1) && x>=0 && numel(x)==1); % Prevent jagged, pixelated images by oversampling the frames followed by linear downscaling. 0 means no anti-aliasing, 8 is a sensible value
    p.addOptional('verbosity_',1,@(x)any(x==[0 1 2]) && numel(x)==1); % verbosity level (disp), _ denotes don't include in auto-filename
    p.parse(varargin{:});
    p=p.Results;
    
    if p.nDots>0
        [recom,nCombis]=recommendDotNr(p);
        while p.nDots~=recom
            disp(['The requested number of dots (' num2str(p.nDots) ' is not a multiple of ' num2str(nCombis) ' i.e, Nr(stepFr)*Nr(deltaDeg)*(noise+signal)*Nr(dotcolors)']);
            disp('If it was all properties such as lifetime, transparancy group, and color would be equally distributed among the dots');
            disp('[Note, You can override this check by providing a negative nDots, the absolute will be used without complaint.]');
            s=input(['The recommended nDots is ' num2str(recom) '. Would you like to use this recommendation? [Y/n] > '],'s');
            if ~strcmpi(strtrim(s),'n')
                p.nDots=recom;
            end
        end
    else
        % negative dot numbers can be used to override the recommendation dialog
        p.nDots=abs(p.nDots);
    end
    
    
    if isempty(p.filename)
        p.filename=autoGenerateFilename(p);
    end
    %
    wObj=VideoWriter(fullfile(p.folder,p.filename),'Uncompressed AVI');
    wObj.FrameRate=p.frHz;
    open(wObj);
    %
    if p.verbosity_>0
        disp(['Creating movie file ''' fullfile(wObj.Path,wObj.Filename) ''' ... ']);
        str='';
    end
    %
    rdk.x=[];
    rdk.y=[];
    rdk.age=[];
    rdk.dirGroup=[];
    rdk.colorGroup=[];
    rdk.cohereGroup=[];
    %
    for f=1:p.frN
        [frame.cdata,rdk]=drawFrame(f,p,rdk);
        frame.colormap=[];
        writeVideo(wObj,frame);
        if p.verbosity_>0
            fprintf(repmat('\b',1,numel(str)));
            str=['Progress: ' num2str(round(f/p.frN*100),'%.3d') '%'];
            fprintf('%s',str);
        end
    end
    close(wObj);
    if p.verbosity_>0
        fprintf(repmat('\b',1,numel(str)));
        fprintf('%s\n','Done.');
    end
    implay(fullfile(wObj.Path,wObj.Filename));
end

% --- HELP FUNCTIONS ------------------------------------------------------

function fname=autoGenerateFilename(p)
    fname=mfilename;
    flds=fieldnames(p);
    for i=1:numel(flds)
        thisField=flds{i};
        if thisField(end)=='_'
            continue;
        end
        thisValue=unique(p.(thisField));
        if isnumeric(thisValue) && ~isempty(thisValue) || islogical(thisValue)
            fname=[fname ' ' thisField '=' num2str(1.0*thisValue,'%.6g')]; %#ok<AGROW>
        end
    end
end


function [M,rdk]=drawFrame(f,p,rdk)
    % all spatial units are pixels
    % step=pars.aaPx;
    w=(p.pxHor+2*ceil(p.dotRadiusPx))*p.aaPx;
    h=(p.pxVer+2*ceil(p.dotRadiusPx))*p.aaPx;
    dotr=round(p.dotRadiusPx*p.aaPx);
    if f==1
        rdk.x=rand(p.nDots,1)*w+1;
        rdk.y=rand(p.nDots,1)*h+1;
        tel=0;
        if p.nDots==recommendDotNr(p)
            % make the properties as evenly distrubuted as possible (no clustering of dark
            % dots in the one transparency component for example)
            %rdk.age=nan(p.nDots,1);
            %rdk.dirGroup=nan(p.nDots,1);
            %rdk.colorGroup=nan(p.nDots,1);
            if p.stepFr<=0 || isinf(p.stepFr)
                nLifetimes=1;
            else
                nLifetimes=p.stepFr;
            end
            for a=0:nLifetimes-1
                for dd=1:numel(p.deltaDeg)
                    for col=1:(1+~all(p.RGB1==p.RGB2))
                        tel=tel+1;
                        rdk.age(tel,1)=a;
                        rdk.dirGroup(tel,1)=dd;
                        rdk.colorGroup(tel,1)=col;
                    end
                end
            end
            rdk.age=repmat(rdk.age,p.nDots/tel,1);
            rdk.dirGroup=repmat(rdk.dirGroup,p.nDots/tel,1);
            rdk.colorGroup=repmat(rdk.colorGroup,p.nDots/tel,1);
        else
            % fully random
            rdk.age=floor(rand(p.nDots,1)*p.stepFr); % 0s 1s 2s ... (nStepFr-1)s
            rdk.dirGroup=ceil(rand(p.nDots,1)*numel(p.deltaDeg)); % 1s and 2s
            rdk.colorGroup=ceil(rand(p.nDots,1)*(1+~all(p.RGB1==p.RGB2))); % 1s and 2s
        end
    else
        if p.stepFr>=0 && ~isinf(p.stepFr)
            % Update age
            rdk.age=rdk.age+1;
            % If too old, replace in screen, and reset age.
            tooOld=rdk.age>p.stepFr;
            rdk.x(tooOld)=rand(sum(tooOld),1)*w+1;
            rdk.y(tooOld)=rand(sum(tooOld),1)*h+1;
            rdk.age(tooOld)=0;
        end
        % Update position of coherent dots per transparency plane
        signal=false(p.nDots,1);
        signal(1:round(p.coherence*p.nDots))=true;
        for tr=1:numel(p.deltaDeg)
            thisSheet=rdk.dirGroup==tr & signal;
            thisDxDy=[p.dX p.dY]*jdRotationMatrix(p.deltaDeg(tr));
            rdk.x(thisSheet)=rdk.x(thisSheet)+thisDxDy(1)*p.aaPx;
            rdk.y(thisSheet)=rdk.y(thisSheet)+thisDxDy(2)*p.aaPx;
        end
        % Check boundaries, wrap around
        tooRight=rdk.x>w;
        tooLeft=rdk.x<1;
        tooHigh=rdk.y>h;
        tooLow=rdk.y<1;
        rdk.x(tooRight)=rdk.x(tooRight)-w;
        rdk.x(tooLeft)=rdk.x(tooLeft)+w;
        rdk.y(tooHigh)=rdk.y(tooHigh)-h;
        rdk.y(tooLow)=rdk.y(tooLow)+h;
    end
    % Create the matrix in which the dots are drawn
    M=zeros(h,w);
    % Create the dot patch (offset of pixels around center)
    dPatchX=[];
    dPatchY=[];
    for di=-dotr:dotr
        for dj=-dotr:dotr
            if hypot(di,dj)<sqrt(dotr)
                dPatchX=[dPatchX di]; %#ok<AGROW>
                dPatchY=[dPatchY dj]; %#ok<AGROW>
            end
        end
    end
    % Insert each dot in M, fill out the color-group number
    for i=1:p.nDots
        x=rdk.x(i);
        y=rdk.y(i);
        for j=1:numel(dPatchX)
            yy=round(y+dPatchY(j));
            xx=round(x+dPatchX(j));
            if xx>=1 && xx<w && yy>=1 && yy<h
                M(yy,xx)=rdk.colorGroup(i);
            end
        end
    end
    % Blank out everything outside the stimulus radius
    [maskxx,maskyy]=meshgrid(fix(-size(M,2)/2):fix(size(M,2)/2),fix(-size(M,1)/2):fix(size(M,1)/2));
    widmask=size(maskxx,2);
    heimask=size(maskxx,1);
    if size(M,1)==heimask-1
        zerocol=maskxx(1,:)==0;
        maskxx(:,zerocol)=[]; % remove the central zero column;
        maskyy(:,zerocol)=[]; % remove the central zero column;
    end
    if size(M,2)==widmask-1
        zerorow=maskyy(:,1)==0;
        maskxx(zerorow,:)=[]; % remove the central zero row;
        maskyy(zerorow,:)=[]; % remove the central zero row;
    end
    M(hypot(maskxx,maskyy)>p.rPx*p.aaPx)=0;    
    % Cut the edges of M that were added to fit the entire dot pathces
    hIdx=p.dotRadiusPx*p.aaPx+1:p.dotRadiusPx*p.aaPx+p.pxVer*p.aaPx;
    wIdx=p.dotRadiusPx*p.aaPx+1:p.dotRadiusPx*p.aaPx+p.pxHor*p.aaPx;
    M=M(hIdx,wIdx);
    % Create the RGB layers of the frame
    % Optimization for grayscale movies
    isGrayscale=std(p.RGB0)==0 && std(p.RGB1)==0 && std(p.RGB2)==0;
    R=ones(size(M))*p.RGB0(1);
    if ~isGrayscale
        G=ones(size(M))*p.RGB0(2);
        B=ones(size(M))*p.RGB0(3);
    end
    % Replace the dot-numbers with the color that each dot should have
    if all(p.RGB1==p.RGB2)
        % Only one color of dot, fill them all at once
        idx=M>0;
        R(idx)=p.RGB1(1);
        if ~isGrayscale
            G(idx)=p.RGB1(2);
            B(idx)=p.RGB1(3);
        end
    elseif ~p.revphi % Two colors used, regular phi
        % draw M==1 dots in RGB1
        % draw M==2 dots in RGB1
        idx=M==1;
        R(idx)=p.RGB1(1);
        if ~isGrayscale
            G(idx)=p.RGB1(2);
            B(idx)=p.RGB1(3);
        end
        idx=M==2;
        R(idx)=p.RGB2(2);
        if ~isGrayscale
            G(idx)=p.RGB2(2);
            B(idx)=p.RGB2(3);
        end
    else % two color used, reverse phi
        % draw rdk.colorGroup==1 dots in RGB1 on odd frames and RGB2 of even frames
        % draw rdk.colorGroup==2 dots in RGB2 on odd frames and RGB1 of even frames
        idx=M==mod(f,2)+1;
        R(idx)=p.RGB1(1);
        if ~isGrayscale
            G(idx)=p.RGB1(2);
            B(idx)=p.RGB1(3);
        end
        idx=M~=mod(f,2)+1;
        R(idx)=p.RGB2(2);
        if ~isGrayscale
            G(idx)=p.RGB2(2);
            B(idx)=p.RGB2(3);
        end
    end
    if isGrayscale
        M=cat(3,R,R,R)*255;
    else
        M=cat(3,R,G,B)*255;
    end
    M=imresize(M,1/p.aaPx,'bicubic');
    M=uint8(M);
end


function [recommended,nCombis]=recommendDotNr(p)
    if p.stepFr<=0 || isinf(p.stepFr)
        nLifetimes=1;
    else
        nLifetimes=p.stepFr;
    end
    nCombis=nLifetimes*numel(p.deltaDeg)*(1+~all(p.RGB1==p.RGB2));
    recommended=round(p.nDots/nCombis)*nCombis;
end





