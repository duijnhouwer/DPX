function k = vonmisestable(n,r)
% Given a number of samples n and the mean length of the vector of a sample, returns the 
% maximum likelihood estimate of the concentration parameter (kappa) of  the von Mises 
% distribution
% INPUT
% n = Number of samples
% r = Mean vector length 
% OUTPUT
% k = Von Mises concentration parameter.
%
% NOTE
% Solved by finding a solution to the Bessel equations. Batschelet gives a table up to k=10, apparently,
% higher values are uncommon (extremely peaked), hence the search for k in [0,100] should suffice, but could
% be extended in this file.
% 
% I have not been able to test the precise values yet, although it works for B101.
%
% BK -  16.8.2001 - last change $Date: 2001/08/21 04:47:19 $ by $Author: bart $
% $Revision: 1.2 $



lowerBnd = 0;
upperBnd = 100;
A= inline('besseli(1,x)./besseli(0,x)-r*besseli(1,n*r*x)./besseli(0,n*r*x)','x','n','r');
[k,fval,exitflag,output]= fminbnd(A,lowerBnd,upperBnd,optimset,n,r);
if exitflag==0
    warning('Could not find a von Mises fit to this function. Using bound.')
end
