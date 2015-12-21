function [m,s,se] = bkMSTD(matrix,dim)
% function [m,s,se] = bkMSTD(matrix)
% DESCRIPTION
% Function determines the mean and the standard deviation and standard
% error of the values in the matrix columnwise. NaN values in the matrix 
% are removed first.
%
% INPUT PARAMETERS 
% 	matrix		The matrix to analyse.
%
% OUTPUT PARAMETERS
% 	m		The mean of each column in 'matrix'.
% 	s		The standard deviation of each column.
%  se 	The standard error of each column
% BK 5/97.

nout =nargout;
nin = nargin;

if prod(size(matrix)) == length(matrix)
   matrix= matrix(:);
end

if nin ==1
   dim =1;
end



if nout >=2  & nin ==1
	[rows,columns]=size(matrix);
	m  = zeros(columns,1);
   s  = zeros(columns,1);
 	se = zeros(columns,1);
	for i=1:columns;
		tmp= matrix(:,i);
      tmp = tmp(~isnan(tmp));
		if (~isempty(tmp))
			m(i) 	= mean(tmp);
         s(i)	= std(tmp);
         se(i) = s(i)/sqrt(length(tmp));
		else
			m(i) = NaN;
         s(i) = NaN;
         se(i)= NaN;
		end
   end
else
   	nrDims = ndims(matrix);
      dims =1:nrDims;
      dims(dim) = [];
      dims = [dim dims];
      matrix = permute (matrix,dims); % Now the dimension to sum over is the first.
   	% Large  N-dim matrices run into problems here.... Split up into columns?
   	out = isnan(matrix);
	   matrix(out)=0;
	   nrNans = sum(out,1);
      totalNr = size(matrix,1);
   	nr = totalNr-nrNans;
	   nr(nr==0) = NaN; % If none of the values is a real value, default to NaN for the mean. 		
	   m = sum(matrix,1)./nr;
      %Now the standard deviation
      if nargout >1
         deviation= matrix - repmat(m,[totalNr ones(1,nrDims-1)]);
         deviation(out) = 0;
         nr(nr==1) = NaN; % Only one sample: no sd defined
         s = sqrt(sum(deviation.^2,1)./(nr-1));
			se = s./sqrt(nr);         
         s =squeeze(s);
         se = squeeze(se);
      end
    %  m = ipermute(m,dims);
      m =squeeze(m);
 end