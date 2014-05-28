
function dpxEndExperiment
    try
        warning on %#ok<WNON>
        ShowCursor;
        jdPTBgammaCorrection('restore');
        Screen('CloseAll');
        ListenChar(0);
    catch me
        error(me.message);
    end
end