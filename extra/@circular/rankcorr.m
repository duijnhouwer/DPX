function [r,p,U] = rankcorr(c1,c2);
% Rank correlation coefficients for two sets of circular data or for circular and linear data.
%
% INPUT
% c1     = Circular data
% c2     = Circular data object or linear data in a vector.
%
% OUTPUT
% r  = The correlation coefficient.
% p  = The p-value associated with the signficance of the r.
% R  = The statistic for p
% NOTE
% Circular-Circular uses the methods of Batschelet p.185
% Circular-Linear uses the methods of Batschelet p.195
% These methods cannot be applied to grouped data, and ties are not really dealt with
% in the ranking (i.e. breaking is random in c2, ordered in c1)
%
% BK - 29.7.2001 - last change $Date: 2001/08/21 03:45:57 $ by $Author: bart $
% $Revision: 1.4 $

if isa(c2,'CIRCULAR')
    mode ='CIRCCIRC';
    m = c2.n;
else
    mode = 'CIRCLIN';
    m = length(c2);
    c2 = c2(:);
end


n = c1.n;
if n~=m
    error('These datasets have different numbers of entries');
end


switch (mode)
case 'CIRCCIRC'
    if isgrouped(c1) | isgrouped(c2)
        error('Rank correlation cannot be calculated for grouped data');
    end
    step = 2*pi/n;
    rank1 = (1:n)'.*step;
    phi2 = rad(c2);
    ties = length(phi2) - length(unique(phi2));
    if ties>0
        disp(['Breaking ' num2str(ties) ' ties']);
        phi2 = phi2 + eps.*randn(size(phi2));
    end
    rank2 = bkrank(phi2).*step;
    
    di = circular(rank2-rank1);
    [d1,rPlus] = mstd(di);
    di = circular(rank2+rank1);
    [d1,rMinus] = mstd(di);
    [r,i] = max([rPlus,rMinus]);
    
    U = r^2;
    if n>8
        p = locW(r,n);
    else
        %Look it up in the W table. [n U p]
       W = wtable;
       W = W(W(:,1)==n,:);
       diff = W(:,2)-U;
       diff(diff>0) =NaN;
       if all(isnan(diff))
         % U smaller than all in the table, hence p larger than 0.5
          p = 1;
       else
          [val,index] = min(diff);
           p = W(index,3);
       end       
    end
    
case 'CIRCLIN'
     if isgrouped(c1) 
        error('Rank correlation cannot be calculated for grouped data');
    end
    
    step = 2*pi/n;
    rank1 = (1:n)'.*step;
    rank2 = bkrank(c2); 
    c     = circular(rank1,rank2);
    [d1,r]     = mstd(sum(c));
    if rem(n,2)==0
        a = 1/(1+5* cot(pi/n)^2 + 4*cot(pi/n)^4);
    else
        a = 2*sin(pi/n)^4/(1+cos(pi/n))^3;
    end
    r = a*r^2; %Correction
    U = 24/(a*n^2*(n+1))*r;
    p = pFromCritical(U,n,'xtable');    
end


function p= locW(r,n)

f = inline('r^2+1./(n-1)*log(1-sqrt(1-p))','p','r','n');
[p,val,flag]= fminbnd(f,0,1,optimset,r,n);

if flag==0
    warning('No P value could be found for this rank correlation');
end

