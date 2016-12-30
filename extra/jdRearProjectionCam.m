function jdRearProjectionCam
    
    maxHz=3;
    cam=selectCam();
    if isempty(cam)
        return;
    end
    hFig=figure(666);
    set(hFig,'menubar','none','name',mfilename,'NumberTitle','off');
    image(fliplr(snapshot(cam)));
    set(gca,'Units','normalized','position',[0 0 1 1]);
    axis equal off
    hold on
    set(hFig,'WindowKeyPressFcn',@escPress);
    ttt=tic;
    while ishandle(hFig)
        if ~escPress()
            if toc(ttt)>1/maxHz
                % pause(1/maxHz-toc(ttt)); % calls drawnow
                %M=snapshot(cam);
                I=ones(1080,1920,3,'uint8')*255;
                fullscreen(I,1);
                % ttt=tic;
            end
        else
            close(hFig);
            break;
        end
    end
    clear cam;
end

function bool=escPress(~,evnt)
    persistent escCounter;
    if isempty(escCounter)
        escCounter=0;
    end
    if nargin>0
        % called as an event
        if strncmp(evnt.Key,'esc',3)
            escCounter=escCounter+1;
        end
    end
    bool=escCounter>=1;
end

function cam=selectCam()
    try
        list=webcamlist();
        if isempty(list)
            error('No webcams detected on this system');
        elseif numel(list)==1
            cam=webcam(1);
        else
            sNum=listdlg('Name',mfilename,'PromptString','Select a webcam:',...
                'SelectionMode','single',...
                'ListString',list);
            if isempty(sNum)
                cam=[];
            else
                cam=webcam(sNum);
            end
        end
    catch me
        if strcmp(me.identifier,'MATLAB:webcam:connectionExists')
            disp(['Webcam is already claimed by some process. Try <a href="matlab:clear classes webcam;' mfilename '">clear classes matlab, and try again</a>']);
        else
            rethrow(me);
            
        end
        cam=[];
    end
end

function fullscreen(image,device_number)
    %FULLSCREEN Display fullscreen true colour images
    %   FULLSCREEN(C,N) displays 24bit UINT8 RGB matlab image matrix C on
    %   display number N (which ranges from 1 to number of screens). Image
    %   matrix C must be the exact resolution of the output screen since no
    %   scaling in implemented. If fullscreen is activated on the same display
    %   as the MATLAB window, use ALT-TAB to switch back.
    %
    %   If FULLSCREEN(C,N) is called the second time, the screen will update
    %   with the new image.
    %
    %   Use CLOSESCREEN() to exit fullscreen.
    %
    %   Requires Matlab 7.x (uses Java Virtual Machine), and has been tested on
    %   Linux and Windows platforms.
    %
    %   Written by Pithawat Vachiramon 18/5/2006
    
    
    ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
    gds = ge.getScreenDevices();
    height = gds(device_number).getDisplayMode().getHeight();
    width = gds(device_number).getDisplayMode().getWidth();
    
    if ~isa(image,'uint8')
        error('Image matrix must be of UINT8 type');
    elseif ~isequal(size(image,3),3)
        error('Image must be NxMx3 RGB');
    elseif ~isequal(size(image,1),height)
        error(['Image must have verticle resolution of ' num2str(height)]);
    elseif ~isequal(size(image,2),width)
        error(['Image must have horizontal resolution of ' num2str(width)]);
    end
    
    
    global frame_java;
    global icon_java;
    global device_number_java;
    
    if ~isequal(device_number_java, device_number)
        try frame_java.dispose(); end
        frame_java = [];
        device_number_java = device_number;
    end
    
    if ~isequal(class(frame_java), 'javax.swing.JFrame')
        frame_java = javax.swing.JFrame(gds(device_number).getDefaultConfiguration());
        frame_java.setUndecorated(true);
        icon_java = javax.swing.ImageIcon(im2java(image));
        label = javax.swing.JLabel(icon_java);
        frame_java.getContentPane.add(label);
        gds(device_number).setFullScreenWindow(frame_java);
    else
        icon_java.setImage(im2java(image));
    end
    frame_java.pack
    frame_java.repaint
    frame_java.show
end

function closescreen()
    %CLOSESCREEN Dispose FULLSCREEN() window
    global frame_java
    try
        frame_java.dispose();
    catch
        warning(me.message);
    end
end
