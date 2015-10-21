function neuronNrs=getNeuronNrs(dpxd)
    % maxCellNr=neuronNrs(dpxd)
    % Find the maximum cell
    %
    %tic
    MAXCELLSPERFILE=2000; % expected with current use max ~50, safety factor 40
    neuronNrs=[];
    for cellNr=1:MAXCELLSPERFILE
        resp_field=['resp_unit' num2str(cellNr,'%.3d') '_type'];
        if isfield(dpxd,resp_field)
            neuronNrs=[neuronNrs cellNr];
        end
    end
    if any(neuronNrs>MAXCELLSPERFILE/2)
        warning(['getNeuronNrs assumes max ' num2str(MAXCELLSPERFILE) ' neurons per file, any neuron with a higher number won''t be counted!']);
    end
    %toc % tested with 1:43 neurons in file and MAXCELLSPERFILE=2000; Elapsed time is 0.169123 seconds on 2013 Asus N550jv laptop 
end