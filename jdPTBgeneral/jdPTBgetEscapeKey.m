function b=jdPTBgetEscapeKey
    b=false;
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown && keyCode(KbName('Escape'))
        b=true;
    end
end