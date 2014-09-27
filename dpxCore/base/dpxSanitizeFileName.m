function [newFileName,changed]=dpxSanitizeFileName(oldFileName,fauxpas,replacewith)
    
    % [newFileName,changed]=dpxSanitizeFileName(oldFileName,replacewith)
    % replace characters that are illegal in filenames with replacewith
    % (empty, i.e., remove characters by default)
    % Jacob, 2014-06-04
    
    if nargin<2 || isempty(fauxpas)
        fauxpas='<>:"/\?*';
    end
    if nargin<3 || isempty(replacewith)
        replacewith='';
    end
    % prep fauxpas for regexprep
    reFauxpas='';
    for i=1:numel(fauxpas)
        reFauxpas=[reFauxpas '(' fauxpas(i) ')|']; %#ok<AGROW>
    end
    reFauxpas(end)='';
    %[^\d\w~!@#$%^&()_\-{}.]*
    newFileName=regexprep(oldFileName,reFauxpas,replacewith);
    if nargout>1
        changed=~strcmp(newFileName,oldFileName);
    end
end
    
    
