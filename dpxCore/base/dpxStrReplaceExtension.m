function ttr=dpxStrReplaceExtension(str,newext)

if nargin==1 || isempty(newext) % special case, remove extension and period
    a=find(str=='.',1,'last');
    ttr=[str(1:a-1) newext];
else
    if newext(1)=='.'
        newext=newext(2:end);
    end
    a=find(str=='.',1,'last');
    if isempty(a)
        ttr=[str '.' newext];
    else
        ttr=[str(1:a) newext];
    end
end