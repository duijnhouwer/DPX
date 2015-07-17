function A=jdMovieToArray(filename)
    
    % A=jdMovieToArray(filename)
    % Convert a AVI file to an array with size [yPix * xPix * nFrames] for indexed and
    % grayscale movies or [yPix * xPix * 3 * nFrames] for RGB movies
    %
    % Use A=squeeze(mean(A,3)) to convert a RGB movie to a grayscale movie-array
    %
    % See also: jdMovieRandomDots, jdMovieGrating, jdMovieArrayToSpaceTime
    
    if nargin==0
        [filename,pathname] = uigetfile( ...
            {'*.avi;', 'AVI container file'; ...
            '*.*', 'All Files (*.*)'}, ...
            'Pick a Video file');
        filename=fullfile(pathname,filename);
    end
            
    obj=VideoReader(filename);
    obj.CurrentTime=0;
    if strcmpi(obj.VideoFormat,'RGB24')
        A=nan(obj.Height,obj.Width, 3 ,floor(obj.duration*obj.FrameRate));
    else
        A=nan(obj.Height,obj.Width, 1 ,floor(obj.duration*obj.FrameRate));
    end
    fr=0;
    while obj.CurrentTime<obj.duration
        fr=fr+1;
        A(:,:,:,fr)=obj.readFrame;
    end
    A=squeeze(A);
end

    
    
    