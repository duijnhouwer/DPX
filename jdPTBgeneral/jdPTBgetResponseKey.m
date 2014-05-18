function [whichNum, whatTime, whichName]=jdPTBgetResponseKey(commaSeparatedKbNames)
    % [whichNum, whichName]=jdPTBgetResponseKey(commaSeparatedKbNames)
    % Example:
    %       jdPTBgetResponseKey('LeftArrow,RightArrow')
    % Hint:
    %       Type KbName in the command window without arguments, wait a second, and press the key
    %       you want to use to figure out its name.
    %
    % Jacob, 2014-05-17
    
    whichNum=[];
    whatTime=[];
    whichName='';
    kbNames=regexp(commaSeparatedKbNames,',','split');
    KbName('UnifyKeyNames');
    [keyIsDown,keyTime,keyCode]=KbCheck;
    if keyIsDown
        for i=1:numel(kbNames)
            if keyCode(KbName(strtrim(kbNames{i})));
                whichNum=i;
                whichName=kbNames{i};
                whatTime=keyTime;
                break;
            end
        end
    end
end