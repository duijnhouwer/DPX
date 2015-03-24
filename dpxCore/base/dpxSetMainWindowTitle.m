function dpxSetMainWindowTitle(ttl)

% Set the title of the main matlab window

try
    pause(0.05);     %This pause was added to prevent Matlab from freezing ("Not Responding")
    if ~exist('ttl','var')
        ttl=['MATLAB R'  version('-release')];
    end
    jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    jDesktop.getMainFrame.setTitle(ttl);
    clear jDesktop;
catch
    disp('Could not set window title');
    % Do this within a try-catch block so that
    % if it fails we can just continue, it's not that important and the
    % method of doing this is undocumented matlab use, so changes are it
    % might break in the future or not work on all platforms..
end