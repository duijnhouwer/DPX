function [k,theta,vm] = vonmises(c,domain)
% Fit the circular data to a von Mises distribution. Use maximum likelihood estimators with
% minimal bias. 
% Von Mises PDF: f(phi) = 1/(2pi Io(k) exp(k*(cos(phi-theta))]
%   This is symmetric around the maximum obtained at phi = theta and k is a measure of
%   concentration: the larger k, the narrower the peak around the mean.
% INPUT
% c = Circular data
% domain = Optional vector of angles over which the values of the vonmises
%   is returned. Domain should be in degrees if c is, radians otherwise.
%
% OUTPUT
% k = The concentration parameter
% theta = The mean angle.
% vm = a circular object with the vonmises at the values at the values of domain, 
%   Without the domain argument the vector c.phi is used. vm can be used to
%   compare the fit to the data.
%
% BK - 28.7.2001 - last Change $DAte: $ by $Author: bart $
% vm output added Dec-2011, JD
% $Revision: 1.3 $
%
% See also: circular/vonmisesfit


% The Theta is simply the mean angle.
[theta,r] = mstd(c);
% k is found by solving a Bessel equation:
k = vonmisestable(c.n,r);

% create a circular object of the fit if requested
if nargout>2
    if nargin==1, 
        domain=c.phi;
    end
    if isdeg(c)
        vals = exp(k*cosd(domain-theta)) ./ (2*pi*besseli(0,k));
        vm=circular(domain,vals,'DEG');
    else
        vals = exp(k*cos(domain-theta)) ./ (2*pi*besseli(0,k));
        vm=circular(domain,vals,'RAD');
    end
end




