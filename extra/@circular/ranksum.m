function [p,u,w] = ranksum(c1,c2)
% Do a two-sample Ranksum test on these circular data. I.e. test the null hypothesis that these samples
% are drawn from a distribution with the same mean value. 
%
% Data should not be grouped: ties in ranking will be broken randomly!.
% NOTE
% The U value is correctly calculated for the example on B120, the corresponding P-value,
% which uses code copied from Matlab ranksum.m, is somehwat lower than the value in Table U
% of Batschelet.
%
% INPUT
% c1     = Circular data
% c2     = Circular data
%
% OUTPUT
% p = The p-value to reject the null hypothesis.
% U = The U statistic, as used by Batschelet, table U.
% w = The ranksum, the p-value is calculated on this basis, with Mathworks code.
%
% BK - 29.7.2001 - last change $Date: 2001/07/30 18:52:48 $ by $Author: bart $
% $Revision: 1.2 $

nin =nargin;

if isgrouped(c1) | isgrouped(c2) 
    warning('The Ranksum test is not ideal for grouped data! (too many tied ranks)');
end

mltpl = multiplex([c1.r; c2.r]);
phi = [c1.phi ; c2.phi];
set = [ones(c1.n,1); 2*ones(c2.n,1)];

phi = phi(mltpl);
set = set(mltpl);

ties = length(phi) - length(unique(phi));
if ties>0
    warning(['Breaking ' num2str(ties) ' ties']);
    phi = phi + eps.*randn(size(phi));
end

[m,smallest] = min([c1.n c2.n]);

[minPhi,minIndex] = min(phi(set==smallest));
[maxPhi,maxIndex] = max(phi(set==smallest));

% Attempt one. CCW.
[d,index] = sort(mod(phi-minPhi,2*pi));
ccwRankSumSmallest = sum(find(set(index)==smallest));

% Attempt two. CW.
[d,index] = sort(phi-maxPhi);
index = flipud(index); 
cwRankSumSmallest = sum(find(set(index)==smallest));

ranksum = min(cwRankSumSmallest,ccwRankSumSmallest);

u = ranksum - 0.5*m*(m+1);


% From Mathworks ranksum test:
% I am assuming here that the distribution Matlab uses for the ranksum
% is valid for the Circular ranksum too. Note that Batschelet uses u and
% gives a table for its distribution
w =ranksum;
wmean = m*(c1.n + c2.n + 1)/2;
if ties>0
    tiescor = (ties.^2)./((c1.n+c2.n)*(c1.n + c2.n - 1));
else
    tiescor =0;
end
wvar  = c1.n*c2.n*((c1.n + c2.n + 1) - tiescor)/12;
if m < 10 & (c1.n+c2.n) < 20     
    % Use the sampling distribution of U.
   allpos = nchoosek(1:(c1.n+c2.n),m);
   sumranks = sum(allpos')';
   np = length(sumranks);
   if w < wmean
      p = (2*length(find(sumranks < w)) + 0.5)./(np+1);
   else 
      p = (2*length(find(sumranks > w)) + 0.5)./(np+1);
   end
else    % Use the normal distribution approximation of W.
	z = (w-wmean)/sqrt(wvar);
	p = normcdf(z,0,1);
	p = 2*min(p,1-p);
end
