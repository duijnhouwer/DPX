function [c,sv]= normcurve(c,varargin)
% function cn = normcurve(c)
% Normalize the curve in circular object c by aligning its vector average
% with zero, its max with 1 and its min with zero, OR, scale by dividing by
% the area.
% 
% INPUT
% c = A circular data object.
% sv = Scaling values struct, optional, scale normalize c as another circObj to preserve relations.
%
% OUTPUT
% c = Normalized circular object
% sv = struct containing scaling values used
%
% EXAMPLE
% c=circular('ex1');
% d=circular('ex2');
% [c sv]=normcurve(c);
% d=normcurve(d,'scalestruct',sv);
%
% JD Jan-2012; Apr-2013: added option to scale by area, changed to varargin
% syntax
%
% see also circular/normalise


p=inputParser;
p.addParamValue('scalestruct',struct([]),@isstruct);
p.addParamValue('ampliscale','peaks',@(x)any(strcmp(x,{'peaks','area'}))); % scale on distance between min and max or on area
p.parse(varargin{:});


if isempty(p.Results.scalestruct)
    sv.mean=mean(c.r);
    sv.area=sum(abs(c.r-mean(c.r)));
    sv.mx=max(c.r);
    sv.mn=min(c.r);
    sv.pdir=mstd(c);
else
    sv=p.Results.scalestruct; % use from a previous run
end
if strcmpi(p.Results.ampliscale,'peaks')
    if sv.mx~=sv.mn
        R=(c.r-sv.mn)/(sv.mx-sv.mn);
    else
        R=ones(size(c.r-sv.mn)); % division by zero problem ...
    end
    if isdeg(c)
        c=circular(deg(c)-sv.pdir,R,'deg',c.axial);
    else
        c=circular(rad(c)-sv.pdir,R,'rad',c.axial);
    end
elseif strcmpi(p.Results.ampliscale,'area')
    if isdeg(c)
        c=circular(deg(c)-sv.pdir,(c.r-sv.mean)/sv.area,'deg',c.axial);
    else
        c=circular(rad(c)-sv.pdir,(c.r-sv.mean)/sv.area,'rad',c.axial);
    end
else
    error(['Unknown ampliscale option: ' p.Results.ampliscale]);
end

    
