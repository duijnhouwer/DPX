function jdPTBerror(err)
    % jdPTBerror(err,windowPtr)
    % jacob 2014-05-21
    % display err (a string or an MException object such as thrown by
    % try/catch me).  
    % If optional argumen windowPtr is passed, restores the old gamma table
    % from a temporary file that has been saved during jdPTBprepExperiment
    %
    % See also: jdPTBunknown 
    warning('on');
    jdPTBgammaCorrection('restore');
    Screen('CloseAll');
    if nargin==0 || isempty(err)
        warning('Should always pass an error message');
        error('Uknown error');
    end
    if ischar(err)
        error(err);
    elseif isobject(err)
        % assuming the class is MException
        error(err.identifier,err.message);
    else
        error('Uknown error');
    end
end