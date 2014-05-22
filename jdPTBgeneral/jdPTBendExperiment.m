
function jdPTBendExperiment
    try
        warning on %#ok<WNON>
        ShowCursor;
        jdPTBgammaCorrection('restore');
        Screen('CloseAll');
    catch me
        error(me.message);
    end
end