function [IN,OUT]=dpxdToolSplitByTime(D,varargin)
    
    % [IN,OUT]=dpxdToolSplitByTime(D,varargin)
    % EXAMPLES
    %   [E,L]=dpxdToolSplitByTime(D,'scope','withinruns')
    %   E will contain the trails of each run per subject that happened in
    %   the first half of the runs, L the second half
    %
    %   [E,L]=dpxdToolSplitByTime(D,'scope','betweenruns')
    %   E will contain the data of the first half of the run ever done by
    %   each subject, L will contain the rest
    %
    %   D=dpxdToolSplitByTime(D,'scope','withinruns','interval',[.1 .9]) 
    %   D will contain only the trails that happened between 10% and 90%
    %   into each run.
    %
    %   Jacob, 20170322
    
    
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('D',@dpxdIs);
    p.addOptional('persubject',true,@(x)islogical(x) || x==1 || x==0);
    p.addOptional('scope','withinruns',@(x)any(strcmpi(x,{'withinruns','betweenruns'}))); % sessions
    p.addOptional('interval',[0 .5],@(x)numel(x)==2 && min(x)>=0&&max(x)<=1);
    p.parse(D,varargin{:});
   
    if p.Results.persubject
        D=dpxdSplit(D,'exp_subjectId');
    else
        D={D};
    end
    IN=cell(size(D));
    OUT=cell(size(D));
    for i=1:numel(D)
        if strcmpi(p.Results.scope,'withinruns')
            IN{i}=dpxdSplit(D{i},'exp_startTime'); % split into runs
            OUT{i}=cell(size(IN{i}));
            for r=1:numel(IN{i})
                mn=quantile(IN{i}{r}.startSec,min(p.Results.interval));
                if isnan(mn)
                    mn=-Inf;
                end
                mx=quantile(IN{i}{r}.startSec,max(p.Results.interval));
                if isnan(mx)
                    mx=Inf;
                end
                [IN{i}{r},OUT{i}{r}]=dpxdSubset(IN{i}{r},IN{i}{r}.startSec>=mn & IN{i}{r}.startSec<mx);
            end
            IN{i}=dpxdMerge(IN{i});
            OUT{i}=dpxdMerge(OUT{i});
        elseif strcmpi(p.Results.scope,'betweenruns')
            expStarts=unique(D{i}.exp_startTime);
            if numel(expStarts)==1
                mn=expStarts; mx=expStarts;
            else
                mn=quantile(expStarts,min(p.Results.interval));
                if isnan(mn)
                    mn=-Inf;
                end
                mx=quantile(expStarts,max(p.Results.interval));
                if isnan(mx)
                    mx=Inf;
                end
            end
            [IN{i},OUT{i}]=dpxdSubset(D{i},D{i}.exp_startTime>=mn & D{i}.exp_startTime<mx);
        else
            error(['unknown scope: ' p.Results.scope]);
        end
    end
    IN=dpxdMerge(IN);
    OUT=dpxdMerge(OUT);
end
