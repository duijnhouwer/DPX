function out=calcNeuronMap(dpxd,cellNr,varargin)
    if nargin==1 && strcmp(dpxd,'info')
        out.per='file';
        return;
    end
    for i=1:numel(cellNr)
        thisMap=full(dpxd.(nrToXymap(cellNr(i))){1});
        if i==1
            M=zeros(size(thisMap));
        end
        M=M+thisMap*2^i;
    end
    out.map{1}=M;
    out.N=1;
end

function str=nrToXymap(nr)
    str=['resp_unit' num2str(nr,'%.3d') '_xymap'];
end