function [p,U] = vtest(c,theta)
% Do a one-sample V test on these circular data. I.e. test whether this sample is concentrated around
% the angle theta. This tests the null hypothesis that this sample
% is drawn from a random/uniform distribution, but it uses prior (!) information that the concentration
% would be around theta if it existed. This makes it somewhat more powerful than the Rayleigh test, but you
% cannot choose the theta on the basis of the data!
%
% Corrects for grouping/binning if c.groups is set to the number of bins, and deals appropriately
% with axial data if c.axial =1.
% 
% INPUT
% c = Circular data
% theta = The expected direction (in the units of c!)
% OUTPUT
% p = The p-value to reject the null hypothesis.
% U = The  statistic.
% 
% TESTED
% B
% BK - 27.7.2001 - last change $Date: 2001/08/21 03:44:44 $ by $Author: bart $
% $Revision: 1.4 $


[phi,r]= mstd(c);
if isdeg(c)
    diff = pi/180*(phi-theta);
else
    diff = phi-theta;
end
U = sqrt(2*c.n)*r*cos(diff);
p = pFromCritical(U,c.n,'itable');




