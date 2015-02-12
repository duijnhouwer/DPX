function v=dpxMakeRow(v)

% function v=dpxMakeRow(v)
% checks if v is a vector (row or column) and makes sure v is a row on
% return.
% See also: dpxMakeColumn

if isempty(v), return; end
if ndims(v)>2 || min(size(v))~=1 %#ok<ISMAT>
    error('Input should be a 1D vector')
end
v=v(:)';