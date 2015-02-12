function tc=calcDirectionTuningCurveSfTfContrast(dpxd,cellNr,varargin)
    % This function calculates a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, it's output can be plot with the
    % complementary plotDirectionTuningCurveSfTfContrast
    %
    % This function is a wrapper to the calcDirectionTuningCurve. This
    % function splits the structure according to spatial frequency (SF)
    % temporal frequency (TF) and contrast, and then passes the result to
    % calcDirectionTuningCurve to get a direction for each subset of data.
    %
    % See also: plotDirectionTuningCurveSfTfContrast
    if nargin==1 && strcmp(dpxd,'info')
        tc.per='cell';
        return;
    end
    tc={};
    C=dpxdSplit(dpxd,'grating_contrastFrac');
    for c=1:numel(C)
        CS=dpxdSplit(C{c},'grating_cyclesPerDeg');
        for s=1:numel(CS)
            CST=dpxdSplit(CS{s},'grating_cyclesPerSecond');
            for t=1:numel(CST)
                tc{end+1}=calcDirectionTuningCurve(CST{t},cellNr,varargin{:}); %#ok<*AGROW>
                tc{end}.contrast=CST{t}.grating_contrastFrac(1);
                tc{end}.SF=CST{t}.grating_cyclesPerDeg(1);
                tc{end}.TF=CST{t}.grating_cyclesPerSecond(1);
            end
        end
    end
    % Combine the separate TuningCurves in one structure, this way we have
    % one structure per cell. The plot function that corresponds to this
    % calc function will split the data again and plot several panels
    tc=dpxdMerge(tc);
end