function [newFileName,changed]=dpxSanitizeFileName(oldFileName,replacewith)
    
    % [newFileName,changed]=dpxSanitizeFileName(oldFileName,replacewith)
    % replace characters that are illegal in filenames with replacewith
    % (empty, i.e., remove characters by default)
    % Jacob, 2014-06-04
    
    fauxpas='(<)|(>)|(:)|(")|(/)|(\)|(|)|(?)|(*)';
    if nargin==1 || isempty(replacewith)
        replacewith='';
    end
    %[^\d\w~!@#$%^&()_\-{}.]*
    newFileName=regexprep(oldFileName,fauxpas,replacewith);
    if nargout>1
        changed=~strcmp(newFileName,oldFileName);
    end
end
    
    
