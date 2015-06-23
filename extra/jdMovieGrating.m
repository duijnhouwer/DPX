function jdMovieGrating(varargin)
    
    % jdMovieGrating(varargin)
    % Function to generate animated grating movies
    %
    % EXAMPLE:
    %    % A 4-second movie of a 3.5-pixels per frame left-up grating:
    %    jdMovieGrating('pxPerFr',3.5,'aDeg',135,'frHz',30,'frN',120)
    %
    % Jacob Duijnhouwer, Sept 2014
    % 
    % 2015-06-23: Major overhaul. Added direction option, renamed parameters
    
    p=inputParser;
    p.addOptional('folder',pwd,@(x)exist(x,'file'));
    p.addOptional('filename','',@(x)ischar(x) || isempty(x));
    p.addOptional('pxWid',200,@(x)isnumeric(x) && ~rem(x,1) && x>0); % width of movie 
    p.addOptional('pxHei',100,@(x)isnumeric(x) && ~rem(x,1) && x>0); % height of movie
    p.addOptional('cycPx',100,@(x)isnumeric(x) && x>0); % bar width
    p.addOptional('frN',51,@(x)isnumeric(x) && ~rem(x,1) && x>0); % number of frames
    p.addOptional('frHz',25,@(x)isnumeric(x) && x>0); % frame rate
    p.addOptional('aDeg',0,@isnumeric); % 
    p.addOptional('pxPerFr',4,@isnumeric); % pixels displacement per frame
    p.addOptional('lum1P',0,@(x)isnumeric(x) && x>=0 && x<=1); % luminance 1, P means value [0..1] 
    p.addOptional('lum2P',1,@(x)isnumeric(x) && x>=0 && x<=1); % luminance 2, P means value [0..1] 
    p.addOptional('startDg',0,@isnumeric); % start phase of pattern in degrees
    p.addOptional('aaPx',4,@(x)isnumeric(x) && ~rem(x,1) && x>=0); % oversampling factor of picture to prevent aliasing, 0 means no antialiasing
    p.addOptional('sqw',true,@islogical); % square wave or not
    p.addOptional('verbosity_',1,@(x)any(x==[0 1 2])); % verbosity level (disp), _ denotes don't include in auto-filename
    p.addOptional('play',true,@islogical);
    p.parse(varargin{:});
    p=p.Results;
    %
    % Generate a desciptive output file name if none was provided
    if isempty(p.filename)
        p.filename=autoGenerateFilename(p);
    end
    %
    % Set up the video writer object
    wObj=VideoWriter(fullfile(p.folder,p.filename),'MPEG-4');
    wObj.Quality=100;
    wObj.FrameRate=p.frHz;
    open(wObj);
    %
    if p.verbosity_>0
        disp(['Creating moviefile ''' fullfile(wObj.Path,wObj.Filename) ''' ... ']);
    end
    % 
    % Add the frames one after the other to the wObj, then close for recording
    for f=1:p.frN
        frame.cdata=drawFrame(f,p);
        frame.colormap=[];
        writeVideo(wObj,frame);
    end
    close(wObj);
    %
    if p.verbosity_>0
        disp('Done.');
    end
    %
    % Play the video, if requested
    if p.play
        implay(fullfile(wObj.Path,wObj.Filename));
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
        if ~isempty(thisValue) && isnumeric(thisValue) || islogical(thisValue)
            fname=[fname ' ' thisField '=' num2str(thisValue,'%.5g')]; %#ok<AGROW>
        end
    end
end
            

function M=drawFrame(f,pars)
    % all spatial units are pixels
    aa=pars.aaPx;
    [XX,YY]=meshgrid(1:pars.pxWid*aa,1:pars.pxHei*aa);
    P=cosd(pars.aDeg)*XX-sind(pars.aDeg)*YY;
    P=P-((f-1)*pars.pxPerFr+pars.startDg*2)*aa;
    M=sin(P/pars.cycPx*2*pi/aa);
    if pars.sqw
        neg=M<0;
        M(neg)=pars.lum1P*255;
        M(~neg)=pars.lum2P*255;
    else
        M=(M+1)/2*255;
    end
    M=imresize(M,1/aa);
    M=uint8(M); % rounds properly (unlike C-style cast)
    M=repmat(M,[1 1 3]);
end



