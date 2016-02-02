function DPXD=dpxdDummy(N)
    
    % DPXD=dpxdDummy(N)
    % Produce a dummy DPXD for testing.
    % ARGUMENTS:
    %   N (optional, default 10): number of data
    %
    % See also dpxdLoad, dpxdMerge, dpxdSplit, dpxdSubset, dpxdMergeGUI
    %
    % Jacob 2016-01-30
    
    if ~exist('N','var') || isempty(N)
        N=10;
    end
    DPXD.a=1:N;
    DPXD.b=round(rand(1,N)*3);
    DPXD.c=repmat({randperm(10)},1,N);
    DPXD.d=char(round(rand(1,N)*3)+'A');
    DPXD.e=rand(1,N);
    DPXD.f=repmat({rand(10,20)},1,N);
    DPXD.N=N;
    
end
    
    
