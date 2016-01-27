function strCell=dpxRightAlign(strCell)
    maxLen=max(cellfun(@numel,strCell));
    for i=1:numel(strCell)
        nSpaces=maxLen-numel(strCell{i});
        strCell{i}=[repmat(' ',1,nSpaces) strCell{i}];
    end
end
    