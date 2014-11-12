function [tsList]=jdGetLasafTimestamps(filename)
    
    % Parse the timestamp list from a Las AF properties.xml file
    % Jacob Duijnhouwer, 2014-11-07
    
    nTS=0;
    tsList=nan(10^5,1); % preallocate liberal estimate of timestamps (for speed)
    fid=fopen(filename,'r');
    while true
        ln=fgets(fid, 1000);
        if ln==-1 % end of file reached
            break;
        elseif isTimestampLine(ln)
            ln=strtrim(ln); % remove leading and trailing whitespace
            nTS=nTS+1;
            tsList(nTS)=parseTimestamp(ln);
        end
    end
    fclose(fid);
    tsList=tsList(1:nTS); % truncate to actual number of timestamp
    
    function b=isTimestampLine(ln)
        b=strncmp(ln,'<TimeStamp',numel('<TimeStamp'));
    end
    
    function ms=parseTimestamp(ln)
        nrs=regexp(ln,'\d+\.?\d*','match');
        ms=nrs(3);
    end
    
end
