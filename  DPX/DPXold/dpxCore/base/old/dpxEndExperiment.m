
function dpxEndExperiment
    try
        warning on %#ok<WNON>
    catch
    end
    try
        ShowCursor;
    catch
    end
    try
        jdPTBgammaCorrection('restore');
    catch
    end
    try
        Screen('CloseAll');
    catch
    end
    try
        ListenChar(0);
    catch
    end
end