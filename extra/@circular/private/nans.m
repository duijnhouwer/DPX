function m = nans(varargin);
% Return a matrix of NaNs. Same use as zeros or ones()
% INPUT
%  varargin = A variable length list of commar separated arguments.
% OUTPUT
% m = An N-dimensional matrix where each element is a NaN.
% EXAMPLE
% m = nans(3,2) 
% returns a 3 rows, 2 columns matrix of NaNs.
%
% BK - 14.8.2000 - last change $Date: 2001/08/23 19:16:05 $ by $Author: bart $
% $Revision: 1.1 $
m = NaN.*zeros(varargin{:});