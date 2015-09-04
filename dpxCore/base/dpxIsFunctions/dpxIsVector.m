function b=dpxIsVector(v)
    
    % b=dpxIsVector(v)
    % Is this a vector, i.e., an 1xN or Nx1 matrix.

    b=ndims(v)==2 && (size(v,1)==1 || size(v,2)==1);
end