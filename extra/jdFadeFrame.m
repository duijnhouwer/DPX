function M=jdFadeFrame(M,fadePx,meanLum)
    
    % M=jdFadeFrame(M,fadePx,meanLum)
    %
    % apply a circular aperture to image M (grayscale, 1 layer depth); meanLum
    % will be the color outside the aperture; fadePx is number of pixels for
    % linear fade toward the outside (use 0 for hard egde)
    %
    % Jacob, 2015-06-26
    %
    % See also: jdMovieGrating, jdMovieRandomDots
    
    if fadePx<0
        return;
    end
    if ~exist('meanLum','var') || isempty(meanLum)
        meanLum=mean(M(:));
    end
    [h,w]=size(M);
    wRange=-w/2:-floor(w/2)+w-1;
    hRange=-h/2:-floor(h/2)+h-1;
    [x,y]=meshgrid(wRange,hRange);
    or=min([w h])/2;
    if fadePx>0
        ir=min([w h])/2-fadePx;
        I=(hypot(x,y)-ir)/(or-ir);
    else
        I=hypot(x,y)>=or;
    end
    O=dpxClip(I,[0 1]); % opacity level field (0..1)
    F=ones(size(M))*meanLum; % fade color field
    M=O.*F+(1-O).*M; % blend M and F according to O
end