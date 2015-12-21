
function [cN,cM,cE,binidx]=bin(c,varargin)

% function [cN,cM,cE,binidx]=bin(c,varargin)
% 
% Bin the observations in circular object bins, calculating the number of
% observations per bin, their means, and there error ranges (std, sem).
%
% INPUT 
%   c: circular object containing the observations to bin
%   varargin:
%     'nbins',N; number of bins, evenly spaced, centered on zero
%     'edges',[arr]: alternative to nbins, arr specifies edges of bins, not tested.
%     'errortype','std',or,'sem'. The meaning of the error bars (default sem).
%
% OUTPUT
%   cN: circular object containing the number of observation per bin
%   cM: circular object containing mean of observation per bin
%   cE: circular obhect containing error of observation per bin
%   binidx: a list corresponding to anglevec that
%       indicates in which bin the data point ended up in. Use a=rad(c);
%       a(binidx) to get the angle of the bin that each datapoint ended up in.
%
% NOTES
%   - specify 'nbins', or 'edges', not both 
%   - cM and cE have less than nbins datapoints when 1 or more values cN are zero.
%
% EXAMPLES:
% c=circular('ex3')
% [cN,cM,cE,idx]=hist(c,'nbins',12)
%
% Jacob, Jan-2012

p=inputParser;
p.addRequired('c',@(x)isa(x,'circular'));
p.addParamValue('nbins',[],@jdIsWholeNumber);
p.addParamValue('edges',[],@jdIsWholeNumber);
p.addParamValue('errortype','sem',@(x)any(strcmpi(x,{'std','sem'})));
p.parse(c,varargin{:});
p=p.Results;

if ~isempty(p.nbins) && ~isempty(p.edges)
    error('Define a number of bins, or specify the bin edges, not both.');
elseif ~isempty(p.nbins) && isempty(p.edges)
    binwidrad=2*pi/p.nbins;
    mids=0:binwidrad:2*pi-binwidrad;
    edges=binwidrad/2:binwidrad:2*pi-binwidrad/2;
elseif ~isempty(p.edges) && isempty(p.nbins)
    edges=p.edges;
    error('Not implemented yet');
elseif isempty(p.nbins) && isempty(p.edges)
    p.nbins=8;
    binwidrad=2*pi/p.nbins;
    mids=0:binwidrad:2*pi-binwidrad;
    edges=binwidrad/2:binwidrad:2*pi-binwidrad/2;
else
    error('getting here was deemed impossible!!!!');
end

% internally, calculations are done in radians
a=rad(c);

% Make sure a is a row
a=a(:)';
% limit to 0<=a<2*pi
a=mod(a,2*pi);
% prealloc the bins
binN=zeros(1,p.nbins);
binMean=nan(1,p.nbins);
binSem=nan(1,p.nbins);
binStd=nan(1,p.nbins);
% prealloc the binidx if needed
if nargout>=4, binidx=nan(size(a)); end
% fill the bin on the edge of the cycle
inbin=a<edges(1) | a>=edges(end);
binN(1)=sum(inbin);
binidx(inbin)=1;
% fill the rest of the bins
rho=c.r;
if nargout>1
    binMean(1)=mean(rho(inbin));
    binStd(1)=std(rho(inbin));
    binSem(1)=binStd(1)./realsqrt(binN(1));
    for i=2:p.nbins
        inbin=a>=edges(i-1) & a<edges(i);
        binN(i)=sum(inbin);
        binMean(i)=mean(rho(inbin));
        binStd(i)=std(rho(inbin))./realsqrt(binN(i));
        binSem(i)=std(rho(inbin))./realsqrt(binN(i));
        if nargout>=4, binidx(inbin)=i; end
    end
else
    for i=2:p.nbins
        inbin=a>=edges(i-1) & a<edges(i);
        binN(i)=sum(inbin);
        if nargout>=4, binidx(inbin)=i; end
    end
end

% convert back to degrees if needed
if isdeg(c)
    mids=mids/pi*180;
    edges=edges/pi*180;
end
    
% Make the circular outputs
% Note that cM and cE have less than nbins datapoints when 1 or more values cN are zero
if isdeg(c), unit='deg'; else unit='rad'; end
cN=circular(mids,binN,unit,c.axial);
cM=circular(mids,binMean,unit,c.axial);
if strcmpi(p.errortype,'SEM')
    cE=circular(mids,binSem,unit,c.axial);
elseif strcmpi(p.errortype,'STD')
    cE=circular(mids,binStd,unit,c.axial);
else
    error(['Unknown errortype ''' p.errortype '''.']);
end

 
