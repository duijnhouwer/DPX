function [dpxd,theRest]=dpxdLoad(filename)
    %
    % [dpxd,theRest]=dpxdLoad(filename) 
    % Controllably load a DPX data file.
    %
    % DPXD files are simply MAT files, so they can be loaded with
    %
    % load(filename)
    %
    % But that would instantiate the DPXD struct with whatever name it was
    % saved (typically 'data' but it could also be 'dpxd', or however you
    % might have renamed it at some point). Standard matlab
    %
    % D=load(filename)
    %
    % Would load the variable in the file as fields to structure D.
    % dpxdLoad function does that internally and output the recognized DPXD
    % structs into the first output argument which is a struct if only DPXD
    % is present (which is the intended design at the time of coding this
    % in Nov 2014) but will be a cell if multiple DPXDs are present.
    % The neatest part of this, I think, is that you can chose the variable
    % name in your analysis, and your not tied to the name given during
    % save (Which may have changed, as explained).
    %
    % All other variable are stowed in a struct which is output as the second
    % argument. I'm not using this currently, but this could be a means of
    % storing additional information about the experiment or the subject or
    % whatever in any number of variables and store them with the output.
    %
    % EXAMPLE
    %    dpxd=dpxdLoad('yourExpDataFile.mat');
    %
    % Jacob Duijnhouwer, 2014-11-25
    
    dpxd={};
    theRest=struct;
    K=load(filename);
    flds=fieldnames(K);
    for i=1:numel(flds)
        thisVar=K.(flds{i});
        if dpxdIs(thisVar)
            dpxd{end+1}=thisVar;
        else
            theRest.(flds{i})=thisVar;
        end
    end
    if numel(dpxd)==1
        % multiple dpxd structs will end up in a cell array, but as of
        % coding this function the intended purpose is to just have 1 dpxd
        % in a datafile and perhaps have some auxillary variables, notes,
        % or whatever in the file.
        % If there is only one dpxd in the cell array, copy that into a
        % singular dpxds-struct now.
        dpxd=dpxd{1};
    end
end