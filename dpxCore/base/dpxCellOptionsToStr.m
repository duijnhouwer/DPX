function str=dpxCellOptionsToStr(C)
    
    % STR=dpxCellOptionsToStr(C)
    % convert C a cell containing string options to a str with spaces and ''
    % delimiting the options. Designed to be used in error messages when an
    % unknown option is selected:
    %
    % EXAMPLE
    %   function set.pause(A,value)
    %      try
    %          options={'perCell','perFile','never'};
    %          if ~any(strcmpi(value,options))
    %              error
    %          end
    %          A.pause=value;
    %      catch me
    %          error(['pause should be one these strings: ' dpxCellOptionsToStr(options) ]);
    %      end
    %  end
    %
    % Jacob Duijnhouwer 2014-11/21
    
    str='';
    for i=1:numel(C)
        str=[str ' ''' C{i} '''']; %#ok<AGROW>
    end
    str=strtrim(str);
    