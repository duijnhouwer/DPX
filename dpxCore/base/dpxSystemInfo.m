function info=dpxSystemInfo
    % return a struct with system information
    ogl=opengl('data');
    ptb=Screen('version');
    info.os=computer;
    info.matlab=version;
    info.opengl=ogl.Version;
    info.renderer=ogl.Renderer;
    info.ptb=ptb.version;
    info.dpx=dpxVersion('checkonline',true,'offerupdate',false);
end

