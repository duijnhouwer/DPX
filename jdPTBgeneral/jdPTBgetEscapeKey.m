function escapePressed=jdPTBgetEscapeKey
    escapePressed=false;
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown
        escapePressed=keyCode(KbName('Escape'));
    end
end