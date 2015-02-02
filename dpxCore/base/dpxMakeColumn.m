function v=dpxMakeColumn(v)

% function v=jdMakeColumn(v)
% checks if v is a vector (row or column) and makes sure v is a column on
% return.
% See also: dpxMakeRow

if isempty(v), return; end
if ndims(v)>2 || min(size(v))~=1 %#ok<ISMAT>
    error('Input should be a vector')
end
v=v(:);