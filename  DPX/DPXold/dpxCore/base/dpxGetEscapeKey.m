function b=dpxGetEscapeKey
    b=false;
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck(-1);
    if keyIsDown && keyCode(KbName('Escape'))
        b=true;
    end
end