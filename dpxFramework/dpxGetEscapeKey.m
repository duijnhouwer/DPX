function b=dpxGetEscapeKey
    b=false;
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown && keyCode(KbName('Escape'))
        b=true;
    end
end