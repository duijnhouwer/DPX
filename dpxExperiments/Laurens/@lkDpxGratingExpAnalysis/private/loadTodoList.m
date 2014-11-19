function [files, neuronsInFiles]=loadTodoList(todoListFileName)
    files={};
    neuronsInFiles={};
    fid=fopen(todoListFileName,'r');
    if fid==-1
        error(['Could not open file ''' todoListFileName '''']);
    end
    try
        timeToReadFileName=true;
        lineCount=0;
        while true % keep reading lines till end of file is reached
            line=fgets(fid);
            if isnumeric(line)
                % if end of file is reached, fgets returns the number -1
                break; % jump out of the while loop
            end
            line=strtrim(line);
            lineCount=lineCount+1;
            line=strtrim(line); % remove whitespace from beginning and end of string
            % check if this line is empty or has been commented out
            % using a %. If so, skip this line and go to next
            if isempty(line) || line(1)=='%';
                continue; % go to next iteration of while-loop
            end
            if timeToReadFileName
                % test if this file exists...
                if ~exist(line,'file')
                    error(['File ''' line ''' does not exist.']);
                end
                files{end+1}=line; %#ok<*AGROW>
                timeToReadFileName=false;
            else % time to read a neuron number list
                nrs=str2num(line); %#ok<ST2NM>
                % check the validity of the neuronNrs;
                if isempty(nrs)
                    error('Could not extract neuron identifiers from this line. It should only include number.');
                end
                nrs=round(nrs);
                nOld=numel(nrs);
                nrs=unique(nrs);
                if numel(nrs)~=nOld
                    error('There are non-unique numbers in this identifier list');
                end
                if ~all(nrs==0) && ~all(nrs>0) && ~all(nrs<0)
                    error('All neuron numbers should be 0 ("analyze all") OR all should be positive ("analyze none but these") OR all should be negative ("analyze all except these")');
                end
                % we can't yet check if any number exceeds the range, we would have
                % to load the corresponding datafile for that
                % first, too cumbersome, we'll check that later
                neuronsInFiles{end+1}=nrs;
                timeToReadFileName=true;
            end
        end
        fclose(fid);
        if numel(files)~=numel(neuronsInFiles)
            error('Not all files have a corresponding neuron-identifier list');
        end
    catch me
        % if an error occurs in the try-block, execution continues
        % here.
        fclose(fid);
        where=['Error in todo-list file '''  todoListFileName ''' on line ' num2str(lineCount) ': '];
        what=me.message;
        error('lkDpxGratingExpAnalysis:loadTodoList',[where '\n' line '\n\n' what]);
    end
end