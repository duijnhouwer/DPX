function s=dpxBytesToStr(b,forceunit)
    if nargin==1
        dyn=true;
    else
        dyn=strcmpi(forceunit,'dynamic');
    end
    kilo=1024;
    mega=kilo*kilo;
    giga=kilo*mega;
    tera=kilo*giga;
    peta=kilo*tera;
    exa=kilo*peta;
    if b<kilo && dyn || strcmpi(forceunit,'B');
        s=[num2str(b) ' B'];
    elseif b>=kilo && b<mega  && dyn || strcmpi(forceunit,'kB') || strcmpi(forceunit,'k');
        s=[num2str(b/kilo,'%.2f') ' kB'];
    elseif b>=mega && b<giga && dyn|| strcmpi(forceunit,'MB') || strcmpi(forceunit,'M');
        s=[num2str(b/mega,'%.2f') ' MB'];
    elseif b>=giga && b<tera && dyn|| strcmpi(forceunit,'GB') || strcmpi(forceunit,'G');
        s=[num2str(b/giga,'%.2f') ' GB'];
    elseif b>=tera && b<peta && dyn|| strcmpi(forceunit,'TB') || strcmpi(forceunit,'T');
        s=[num2str(b/tera,'%.2f') ' TB'];
    elseif b>=peta && b<exa && dyn|| strcmpi(forceunit,'PB') || strcmpi(forceunit,'P');
        s=[num2str(b/peta,'%.2f') ' PB'];
    elseif b>=exa && dyn || strcmpi(forceunit,'EB') || strcmpi(forceunit,'E');
        s=[num2str(b/exa,'%.2f') ' EB'];
    else
        s=[num2str(b) ' B'];
    end
end
