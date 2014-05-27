function C=jdPTBblend(A,B,frac)

% function C=jdPTBblend(A,B,perc)
%
% mix A into B with percentage perc
% if perc==100 output C equals A, 
% if perc==0, output C equals B

C=frac*A+(1-frac)*B;