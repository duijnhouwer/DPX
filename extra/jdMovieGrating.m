function jdMovieGrating(varargin)
    
    % jdMovieGrating(varargin)
    % Function to generate animated grating movies
    %
    % EXAMPLE:
    %    % A 4-second movie of a 3.5-pixels per frame leftward grating:
    %    jdMovieGrating('dxdfrPx',-3.5,'frHz',30,'frN',120)
    %
    % Jacob Duijnhouwer, Sept 2014
    
    p=inputParser;
    p.addOptional('folder',pwd,@(x)exist(x,'file'));
    p.addOptional('filename','',@(x)ischar(x) || isempty(x));
    p.addOptional('pxHor',400,@(x)isnumeric(x) && ~rem(x,1) && x>0); % width of movie 
    p.addOptional('pxVer',300,@(x)isnumeric(x) && ~rem(x,1) && x>0); % height of movie
    p.addOptional('barPx',40,@(x)isnumeric(x) && x>0); % bar width
    p.addOptional('frN',560,@(x)isnumeric(x) && ~rem(x,1) && x>0); % number of frames
    p.addOptional('frHz',40,@(x)isnumeric(x) && x>0); % frame rate
    p.addOptional('dXdFrPx',4,@isnumeric); % pixels displacement per frame
    p.addOptional('lum1P',0,@(x)isnumeric(x) && x>=0 && x<=1); % luminance 1, P means value [0..1] 
    p.addOptional('lum2P',0,@(x)isnumeric(x) && x>=0 && x<=1); % luminance 2, P means value [0..1] 
    p.addOptional('startDg',0,@isnumeric); % start phase of pattern in degrees
    p.addOptional('aaPx',4,@(x)isnumeric(x) && ~rem(x,1) && x>=0); % oversampling factor of picture to prevent aliasing,  0 means no antialiasing
    p.addOptional('verbosity_',1,@(x)any(x==[0 1 2])); % verbosity level (disp), _ denotes don't include in auto-filename
    p.parse(varargin{:});
    p=p.Results;
    
    if isempty(p.filename)
        p.filename=autoGenerateFilename(p);
    end
    %
    wObj=VideoWriter(fullfile(p.folder,p.filename),'MPEG-4');
    wObj.Quality=100;
    wObj.FrameRate=p.frHz;
    open(wObj);
    %
    if p.verbosity_>0
        disp(['Creating moviefile ''' fullfile(wObj.Path,wObj.Filename) ''' ... ']);
    end
    % 
    for f=1:p.frN
        frame.cdata=drawFrame(f,p);
        frame.colormap=[];
        writeVideo(wObj,frame);
    end
    close(wObj);
    if p.verbosity_>0
        disp('Done.');
    end
    
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
        thisValue=p.(thisField);
        if isnumeric(thisValue) && ~isempty(thisValue)
            fname=[fname ' ' thisField '=' num2str(thisValue,'%.5g')]; %#ok<AGROW>
        end
    end
end
            

function M=drawFrame(f,pars)
    % all spatial units are pixels
    step=pars.aaPx;
    x=1:pars.pxHor * step;
    % make the 1D sinewave, range between [-1 to 1]
    yy=sind((x-f*pars.dXdFrPx*step)*360/pars.barPx/(2*step)+pars.startDg);
    % make squarewave
    dark=yy<0;
    lite=yy>=0;
    yy(dark)=pars.lum1P*255;
    yy(lite)=pars.lum2P*255;
    %
    y=1:step:numel(yy);
    tel=1;
    for i=y(:)'
        y(tel)=mean(yy(i:i+step-1));
        tel=tel+1;
    end
    % make a wid x hei x RGB matrix
    M=repmat(y,[pars.pxVer 1 3]);
    % cast to unsinged 8-bit integers
    M=uint8(M);
end



