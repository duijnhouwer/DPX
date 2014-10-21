function b=dpxGetEscapeKey
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck(-1);
    b=keyIsDown && keyCode(KbName('Escape'));
end