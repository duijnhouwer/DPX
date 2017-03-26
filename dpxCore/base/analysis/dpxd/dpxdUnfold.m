function DPXD=dpxdUnfold(DPXD,fNames)
    
    % DPXD=dpxdUnfold(DXPD,fNames)
    %
    % Unfold a DXPD according to the list of fieldnames in 'fNames'. fNames can
    % be a string containing one fieldname, or a cell of multiple fieldnames.
    % The sub-dpxds are returned in cell array C.
    %
    % Unfolding means that the arrays contained within cell array
    % DPXD.fName gets expanded. This will increase DPXD.N with however more
    % elements are contained within the cells. Therefor, dpxdUnfold should
    % be treated with caution as memory requirements may sharply increase.
    %
    % EXAMPLE
    %   D=dpxdDummy
    %   D=dpxdUnfold(D,'f')
    %
    % Jacob 2017-03-25
    %
    % TODO: make this function work for multi-dim arrays too, not just cell
    % arrays.
       p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('DPXD', @dpxdIs);
    p.addRequired('fNames',@(x)iscell(x) | ischar(x));
    p.parse(DPXD,fNames);
    
    if iscell(fNames)
        for i=1:numel(fNames)
            DPXD=dpxdUnfold(DPXD,fNames{i});
        end
    elseif ischar(fNames)
        fName=fNames;
        flds=fieldnames(DPXD);
        if ~any(strcmp(flds,fName))
            error([fNames ' is not a fieldname of DPXD']);
        end
        if ~iscell(DPXD.(fName))
            error('dpxdUnfold currently only words for cell-array data');
        end
        DPXD=dpxdSplit(DPXD,'N');
        for i=1:numel(DPXD)
            DPXD{i}.(fName)=cell2mat(DPXD{i}.(fName));
            newN=size(DPXD{i}.(fName),2);
            for fi=1:numel(flds)
                if strcmp(flds{fi},fName)
                    continue;
                end
                DPXD{i}.(flds{fi})=repmat(DPXD{i}.(flds{fi}),1,newN);
            end
            DPXD{i}.N=newN;
        end
        DPXD=dpxdMerge(DPXD);
    end
end
        