function A=jdMovieArrayToSpaceTime(A,y)
    
    % XT=jdMovieArrayToSpaceTime(A,y)
    % Create a single frame (image) of a horizontal cross section of movie
    % array A at level y (default y is middle row of movie)
    %
    % EXAMPLE:
    %    jdMovieRandomDots('filename','test')
    %    A=jdMovieToArray('test.avi');
    %    XT=jdMovieArrayToSpaceTime(A);
    %    image(XT);
    %
    % See also: jdMovieToArray; jdMovieRandomDots, jdMovieGrating    
    %
    % Jacob 2015-07-17
    
    if ~exist('y','var') || isempty(y)
        y=round(size(A,1)/2);
    end
    if numel(size(A))==4
        % RGB color array, 3rd dimension is color
        if size(A,3)~=3
            error('unknown movie array format, expected 3rd of 4 dimensions to represent RGB color, i.e., have 3 elements');
        end
        A=squeeze(A(y,:,:,:))/255;
        A=permute(A,[3 1 2]);
    elseif numel(size(A))==3
        A=squeeze(A(y,:,:))/255;
        A=permute(A,[2 1]);
    else
        error('unknown movie array format, expected 3 (grayscale) or 4 (RGB color) dimensions');
    end 

    