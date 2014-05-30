function resp=jdPTBgetResponseKey(commaSeparatedKbNames)
    % [whichNum, whichName]=jdPTBgetResponseKey(commaSeparatedKbNames)
    % Example:
    %       resp=jdPTBgetResponseKey('LeftArrow,RightArrow')
    %       resp=jdPTBgetResponseKey  without arguments to return empty
    %                response structure
    % Hint:
    %       Type KbName in the command window without arguments, wait a second, and press the key
    %       you want to use to figure out its name.
    %
    % Jacob, 2014-05-17
    
    resp.number={-1}; % cell because in future more keys per answer
    resp.keyName={''};
    resp.timeSecs={-1};
    if nargin==0 || isempty(commaSeparatedKbNames)
        return;
    end
    kbNames=regexp(commaSeparatedKbNames,',','split');
    KbName('UnifyKeyNames');
    [keyIsDown,keyTime,keyCode]=KbCheck;
    if keyIsDown
        for i=1:numel(kbNames)
            if keyCode(KbName(strtrim(kbNames{i})));
                resp.number={i};
                resp.keyName={kbNames{i}};
                resp.timeSecs={keyTime};
                break;
            end
        end
    end
end