function bytes=dpxBytes(Obj)    %#ok<INUSD>
    
    % bytes=dpxBytes(Obj)
    % Return the size of the Obj in bytes This DOES NOT double the memory requirement of
    % the inquired object (variable). Matlab obly copies the object in when it is about to
    % be changed, which this function does not. That is, this function is pass by
    % reference
    W=whos('Obj');
    bytes=W.bytes;
end
