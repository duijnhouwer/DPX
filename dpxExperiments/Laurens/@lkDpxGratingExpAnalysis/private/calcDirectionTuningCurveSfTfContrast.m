function tc=calcDirectionTuningCurveSfTfContrast(dpxd,cellNr,varargin)
    % This function calculates a direction tuning curve from a
    % lkDpxExpGrating-DPXD struct, it's output can be plot with the
    % complementary plotDirectionTuningCurveSfTfContrast
    %
    % This function is a wrapper to the calcDirectionTuningCurve. This function
    % splits the structure according to spatial frequency (SF) temporal
    % frequency (TF) and contrast, and then passes the result to
    % calcDirectionTuningCurve to get a direction for each subset of data.
    %
    % See also: plotDirectionTuningCurveSfTfContrast
    
    % Standard: if the argument to this function is 'info', return for what
    % level of analysis it was designed for (e.g., 'cell'). This is required
    % functionality for all the lkDpxGratingExpAnalysis functions
    if nargin==1 && strcmp(dpxd,'info')
        tc.per='cell';
        return;
    end
    tc={};
    splitidx=0;
    %keyboard
    C=dpxdSplit(dpxd,'test_contrastFrac');
    
    for c=1:numel(C)
        CS=dpxdSplit(C{c},'test_cyclesPerDeg');
        for s=1:numel(CS)
            CST=dpxdSplit(CS{s},'test_cyclesPerSecond');
            for t=1:numel(CST)
                KK=calcDirectionTuningCurve(CST{t},cellNr,varargin{:}); % KK = Komplete+Komponents
                % Since february 2015 or so calcDirectionTuningCurve returns a cell-array
                % with first element the analysis ran on all the (merged) data and the
                % optional other elements ran on components of the data (individual runs).
                % calcDirectionTuningCurveSfTfContrast will henceforth (date>30-Mar-2015)
                % also output a cell array like that.
                splitidx=splitidx+1;
                for iKK=1:numel(KK)
                    tc{iKK}{splitidx}=KK{iKK}; %#ok<AGROW>
                    tc{iKK}{splitidx}.contrast=CST{t}.test_contrastFrac(1); %#ok<AGROW>
                    tc{iKK}{splitidx}.SF=CST{t}.test_cyclesPerDeg(1);
                    tc{iKK}{splitidx}.TF=CST{t}.test_cyclesPerSecond(1);
                end
            end
        end
    end
    for i=1:numel(tc)
        tc{i}=dpxdMerge(tc{i});
    end
end