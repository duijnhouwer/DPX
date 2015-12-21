function c= circular(x,y,units,axial)
% Constructor for the circular class. This class encapsulates the properties of
% circular data. It provides methods of descriptive statistics as well as methods
% for hypothesis testing. See @circular/docs/usage.pdf for a brief introduction or
% @circular/docs/reference.pdf for a list of functions and their calling sequences.
%
% INPUT
% x =   A list of polar angles. (in radians or degrees depending on 'units' argument)
% y  =  A corresponding list of radii.  
% units  = 'RAD' or 'DEG'. RAD is assumed by default. Note that all internal calculations are done
%           with RADIANS, only what is passed to the outside is affected by this.
% axial  = 1 or 0. Specifying whether these data should be treated as axial data.
% OUTPUT
% c = A @Circular object
%
% Contact: bart@salk.edu for more information.
%
% BK - 27.7.2001 
% $Revision: 1.7 $
%% PLEASE NOTE THAT THIS CODE IS DEPRECATED and NOT MAINTAINED. 
%% USE THE CIRCSTATS Toolbox instead
%% 

c.phi   = [];   % The angles of the data
c.r     = [];   % The counts or the length of the vectors.
c.units = 'RAD';
c.n     = 0;    % Number of elements
c.k     = Inf;  % Number of groups. 
c.groups = 0;   % Both 0 and inf are interpreted as 'No Groups'. Used to correct for the bias in mean length
c.axial = 0;

nin =nargin;
if nin>0
    out = isnan(x);
    if nin>1
        out =out | isnan(y);
        y(out) =[];
    end
    x(out)=[];
    if any(out) 
        disp('Removing NaN for Circular object');
    end
end


if nin >0
    if isa(x,'CIRCULAR')  
        % Copy constructor
        c = x;
        return;
    elseif isnumeric(x) 
        % Single argument: unit vectors with given phi.
        % if x is a vector, make it a column
        if numel(x)==length(x)
            XX =  x(:);
        else
            XX = x;   
        end
        c.phi = XX;
        c.r   = ones(size(XX));
    elseif ischar(x) % example circulars for testing and debugging
        switch lower(x)
            case 'ex1'
                [c.phi c.r]=vonMisesExample(12,0,5);
            case 'ex2'
                [c.phi c.r]=vonMisesExample(18,-pi/2,4,2,3);
            case 'ex3'
                [c.phi c.r]=vonMisesExample(18,pi,10,10,10);
            otherwise, error(['Unknown string command: ''' x '']);
        end     
    else
        error('No such constructor for circular objects.')
    end
    if nin >1        
        if isnumeric(y)  && all(size(x)==size(y))
            if numel(x)==length(x)
                % if y is a vector, make it a column
                y =  y(:);
            end
            c.r   = y;
        elseif ischar(y)
            units =y;
            c.r = ones(size(c.phi));
            nin =3;
        elseif numel(y) == 1
            c.r = ones(size(c.phi));
        else
            error('Phi and R must be the same size');
        end
        if nin >2   
            c.units = units;
            if strcmpi(units,'DEG')
                c.phi = c.phi *pi/180;
            end
            if nin>3
                c.axial =axial;
            end
        end
    end
end
[c.n,c.k] = size(c.phi);
% Warp to [0,2pi]
c.phi = mod(c.phi,2*pi);
c = class(c,'CIRCULAR');




function [phi r]=vonMisesExample(nsteps,theta,kappa,baseline,gain)
phi=-pi:pi/nsteps:pi-pi/nsteps;
r=exp(kappa*cos(phi-theta)) ./ (2*pi*besseli(0,kappa));
if nargin>3, % do scale and shift
    if nargin<5, gain=1; end
    % shift and scale to span range 0 to 1
    globmin=exp(-kappa) ./ (2*pi*besseli(0,kappa)); % global min (found at theta=phi+0)
    globmax=exp(kappa) ./ (2*pi*besseli(0,kappa)); % global max (found at theta=phi+pi)
    r=r-globmin;
    r=r/(globmax-globmin);
    r=r*gain+baseline;
    fprintf('Created a circular object with a scaled Von Mises distribtion with theta=%.3f, kappa=%.3f, miny=%.3f, gain=%.3f\n',theta,kappa,baseline,gain);
else
    fprintf('Created a circular object with an unscaled Von Mises distribtion with theta=%.3f, kappa=%.3f.\n',theta,kappa);
end
phi=phi(:); % make ...
r=r(:); % ... columnar



