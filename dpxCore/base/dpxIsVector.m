function b=dpxIsVector(v)

b=ndims(v)==2 && (size(v,1)==1 || size(v,2)==1);
