function [num,str]=dpxBridgeBurningDay
    
    % [num,str]=dpxBridgeBurningDay
    % Return the date at which marked backward compatibilities will be
    % removed (marker = 'dpxBridgeBurningDay')
    %
    % Jacob, 2015-11-29
    
    str='01-Mar-2017';
    num=datenum(str,'dd-mm-yyyy');
end