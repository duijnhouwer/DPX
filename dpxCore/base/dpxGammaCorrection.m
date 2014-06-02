function dpxGammaCorrection(option,scrNr,gammaValue)
    try
        if strcmpi(option,'set')
            oldscr.oldGammaTab=Screen('ReadNormalizedGammaTable', scrNr);
            oldscr.scrNr=scrNr;
            save(oldscrFilename,'oldscr');
            newGammaTab=repmat((0:1/WhiteIndex(scrNr):1)',1,3).^gammaValue;
            Screen('LoadNormalizedGammaTable',scrNr,newGammaTab);
        elseif strcmpi(option,'setnostore')
            newGammaTab=repmat((0:1/WhiteIndex(scrNr):1)',1,3).^gammaValue;
            Screen('LoadNormalizedGammaTable',scrNr,newGammaTab);
        elseif strcmpi(option,'restore')
            if exist(oldscrFilename,'file')
                load(oldscrFilename); % loads oldscr into memory
                Screen('LoadNormalizedGammaTable',oldscr.scrNr,oldscr.oldGammaTab);
                delete(oldscrFilename); % delete the temporary file
            else
                % assume original gamma was linear
                if exist('scrNr','var')
                    newGammaTab=repmat((0:1/WhiteIndex(scrNr):1)',1,3);
                    Screen('LoadNormalizedGammaTable',scrNr,newGammaTab);
                else
                    for scrNr=Screen('screens')
                        newGammaTab=repmat((0:1/WhiteIndex(scrNr):1)',1,3);
                        Screen('LoadNormalizedGammaTable',scrNr,newGammaTab);
                    end
                end
            end
        else
            error(['Unknown dpxGammaCorrection option ' option]);
        end
    catch me
        dpxEndExperiment; 
        error(me.message);
    end
end

function fname=oldscrFilename
    if ispc
        fname='C:\temp\oldscr.mat';
    elseif ismac || isunix
        fname='~/.oldscr.mat';
    else
        fname='oldscr.mat';
    end
end