function info=dpxSystemInfo
    
    % info=dpxSystemInfo
    % Returns a struct with system information.
    % Jacob, 2014-06-11
    % See also: dpxVersion
    
    ogl=opengl('data');
    ptb=Screen('version');
    info.os=computer;
    info.matlab=version;
    info.opengl=ogl.Version;
    info.renderer=ogl.Renderer;
    info.ptb=ptb.version;
    info.dpx=dpxVersion('checkonline',false,'offerupdate',false);
end

