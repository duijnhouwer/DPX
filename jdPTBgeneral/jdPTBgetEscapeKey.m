function str=jdPTBgetEscapeKey
    str=[];
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown && keyCode(KbName('Escape'))
        str='EscPressed';
    end
end