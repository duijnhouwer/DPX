function [tuned tunestruct]=istuned(c,varargin)

% Determine whether circular object c exhibits tuning by fitting a scaled
% and offset Von Mises to the data. The curve is considered tuned if the
% confidence intervals of the gain and the concentration parameter kappa do
% not contain zero. In addition, the model needs to be better, in terms of
% a nested F-test at a specified p-value, than just an offset.
%
% INPUT
%   c: circular object containing data to be fit
%   varargin, string/value pairs:
%   'type': type of tuning to test for: default 'scaledvonmises'
%   'sigma' the criterion number of standard deviations for gain and kappa.
%       Default is norminv(0.975) or ~1.96 (ie 95% confidence limit).
%   'ftestpval' p-value for F-test criterion. Default: (1-normcdf(sigma))*2

%
% OUTPUT
%   tuned: true,false, or nan if failed to determine (fit problem)
%   fit: structure that contains output of call to vonmisesfit 
%
% Note, to only base the tuning decision on the F-test, use
% tunestruct.Ftest.p<somethreshold.
%
% Jacob Dec-2011
%
% see also: circular/vonmisesfit


p=inputParser;
p.addParamValue('c',@(x)isa(x,'circular'));
p.addParamValue('type','scaledvonmises',@(x)any(strcmpi(x,{'scaledvonmises'}))); % placeholder
p.addParamValue('sigma',norminv(0.975),@isnumeric); % ~1.96
p.addParamValue('ftestpval',[],@(x)isnumeric(x) || isempty(x));
p.parse(varargin{:});



switch lower(p.Results.type)
    case 'scaledvonmises'
        [tuned tunestruct]=scaledvonmises(c,p);
    otherwise, error(['Unknown tuning type: ' p.Results.type]);
end
    

% Subfunctions ==========================================================

function [tuned tunestruct]=scaledvonmises(c,p)
alpha=(1-normcdf(p.Results.sigma))*2;
if isempty(p.Results.ftestpval), ftestpval=alpha;
else ftestpval=p.Results.ftestpval;
end
try
    [fit.vmf, fit.est, fit.estci, fit.r2, fit.ftest] = ...
        vonmisesfit(c,'alpha',alpha,'allowskew',false);
    % The curve is considered tuned if the confidence intervals of the gain
    % and the concentration parameter do not contain zero and the model is
    % better, in terms of a nested F-test, than just an offset.
    ftest=fit.ftest;
    gainok=all(fit.estci.gain>0) || all(fit.estci.gain<0);%
    kok=all(fit.estci.k>0);
    tuned=gainok && kok && ftest.p<ftestpval;
catch me
    tuned=nan;
    gainok=nan;
    kok=nan;
    ftest=[];
    fit=me;
end
tunestruct.tuned=tuned;
tunestruct.type=p.Results.type;
tunestruct.gainok=gainok;
tunestruct.kok=kok;
tunestruct.Ftest=ftest;
tunestruct.input=p.Results;
tunestruct.fit=fit;
    
