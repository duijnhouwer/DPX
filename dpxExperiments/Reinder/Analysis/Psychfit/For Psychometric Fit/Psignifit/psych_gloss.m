% PSYCH_GLOSS    glossary of terms, struct fieldnames and common variable names 
% 
% 
% 2AFC          an 2-alternative forced-choice experimental paradigm, in which
%               the observer selects one of 2 stimuli per trial. Similarly 4AFC,
%               8AFC, nAFC.
% 
% alpha         parameter of the underlying psychometric function F. Together,
%               alpha and beta determine the horizontal displacement of the
%               curve, and its slope. alpha is the first element of the parameter
%               vector theta.
% 
% beta          parameter of the underlying psychometric function F. Together,
%               alpha and beta determine the horizontal displacement of the 
%               curve, and its slope. beta is the second element of the parameter
%               vector theta.
% 
% BCa           the bias-corrected accelerated method of obtaining bootstrap 
%               confidence intervals. For most problems, the coverage of BCa 
%               intervals can be shown to exhibit better convergence than that of
%               unadjusted bootstrap percentile intervals. See Davison, AC & Hinkley,
%               DV (1997): Bootstrap methods and their application; Cambridge: CUP,
%               and Efron, B & Tibshirani, RJ (1993): An Introduction to the Bootstrap;
%               New York: Chapman & Hall.
% 
% bootstrap     a Monte Carlo method for estimating variability. A large number
%               of simulated data sets are generated from a distribution that is 
%               assumed to approximate the true distribution underlying the data 
%               (in our implementation, we use the maximum-likelihood fitted 
%               function of form psi in order to generate data). Whatever process 
%               was carried out on the data to obtain an estimate (e.g. fitting a 
%               function and obtaining a threshold) is carried out on each of the 
%               simulated data sets, to obtain an expected distribution of 
%               estimates. 
% 
% bootstrap     the inaccuracy of a bootstrap variability estimate that arises
% error         because of a discrepancy between the estimated or assumed 
%               bootstrap generating function and the true distribution.
% 
% conf          short for "confidence levels" which is our imprecise shorthand
%               for "the cumulative probability value corresponding to a 
%               confidence interval boundary". Our default values for conf are
%               [0.023, 0.159, 0.841, 0.977] because they provide confidence
%               intervals whose coverage is familiar: if the variable in question
%               were Gaussian, they would give us [-2, -1, +1, +2] standard
%               deviations from the mean.
% 
% confLimMethod should read 'BCa', indicating that confidence limits in the 'lims'
%               fields were obtained by the BCa method
% 
% corr          linear correlation coefficient
% 
% cpe           cumulative probability estimate: for any measure z, this is an
%               estimate of the integral from -infinity to z of the probability
%               density function for Z. For a right-tailed test, significance is
%               equal to cpe. For a left-tailed test, significance = 1-cpe.
% 
% cuts          the probability levels at which thresholds or slopes are
%               calculated, given in the (0, 1) range of F.
% 
% d             a vector of length K giving deviance residuals for each block.
% 
% D             deviance summary statistic ( = sum(d.^2)). This is the first
%               statistical measure returned by the PSIGNIFIT engine.
% 
% dat           data set: each row is an observation. May be expressed as
%               [x y n], [x r n] or [x r w].
% 
% deriv         derivative of  the attributes of interest (parameters, thresholds
%               or slopes) with respect to each of the parameters (our convention is
%               for columns to denote different attributes, for example thresholds at
%               different cut levels, and for rows to denote different parameters). 
%               Derivatives are evaluated at the maximum-likelihood estimated
%               or initial parameter values. Used to calculate "lff" (see below) in the
%               BCa method.
% 
% deviance      each residual is equal to the square root of the deviance
% residuals     calculated for one of the data points in isolation, signed
%               according to the direction of the difference between observed
%               performance and model prediction. The sum of squared deviance
%               residuals equals overall deviance, D.
% 
% est           initial estimate of something (parameters, thresholds, slopes).
%               Usually this is the maximum-likelihood estimate from a fit, but
%               sometimes the user supplies a hypothesis explicity - in which
%               case est refers to the values derived from the hypothesized
%               distribution.
% 
% F             underlying psychometric function. Relates stimulus intensity x to
%               the probability that the psychological mechanism of interest can
%               detect the stimulus, in the absence of stimulus-independent
%               errors or lucky guesses. See the MATLAB function PSYCHF.
% 
% gamma         parameter of the psychometric performance function psi,
%               determining the lower bound of predicted performance: psi(x) >=
%               gamma for all x. Its value corresponds to predicted performance
%               in the absence of a stimulus. In nAFC paradigms, gamma is usually
%               fixed at the reciprocal of the number of intervals per trial. In
%               yes/no paradigms, it is usually small (< 0.5). gamma is the third
%               element of the parameter vector theta.
% 
% k             a vector of length K denoting the chronological index for each
%               block in the data set
% 
% K             number of blocks in the data set (= length(n))
% 
% lambda        parameter of the psychometric performance function psi,
%               determining the upper bound of predicted performance: psi(x) <=
%               1-lambda for all x. 1-lambda is the predicted performance level
%               for an arbitrarily large stimulus. lambda is typically small 
%               (<0.05) because it is generally assumed that observers do not
%               make stimulus-independent errors at high rates. lambda is the
%               fourth element in the parameter vector theta.
% 
% ldot:         the derivative of log-likelihood, with respect to each of the 
%               parameters, evaluated at the MLE, for each of the bootstrap data 
%               sets. Thus ldot has R rows and four columns (one for each 
%               parameter). It is used to obtain BCa confidence interval limits, 
%               and is output by the PSIGNIFIT engine. 
% 
% lims          a matrix whose columns refer to different estimates and whose 
%               rows correspond to different elements of conf. Each element is 
%               the estimate whose cpe in the bootstrap distribution is equal to 
%               the appropriate element of conf. The method used to obtain
%               the confidence limits is indicated by the field
%               'confLimMethod' - usually it will be the BCa method.
% 
% lff:          the least-favourable direction(s) in parameter space for 
%               inference about a variable or variables. It is used to obtain BCa 
%               confidence interval limits. In our format, it is a matrix with 
%               one column for each variable, and four rows indicating the 
%               components of the least-favourable direction in the dimensions of 
%               the four parameters. A least-favourable direction vector should 
%               be calculated for each parameter, threshold or slope estimate - 
%               see Davison, AC & Hinkley, DV (1997): Bootstrap methods and their 
%               application; Cambridge: CUP, pp206-7 and p249. 
% 
% "log slope"   gradient of the psychometric function with respect to log10(x).
%               This can be calculated as threshold * slope * log(10), or by
%               passing the option 'log' into FINDSLOPE. See the entries for
%               "threshold" and "slope".
%               
% m             number of points in parameter space at which simulations are
%               repeated during sensitivity analysis
% 
% n             a vector of length K denoting the number of trials in each block
%               of the data set
% 
% N             total number of observations in data set (= sum(n))
% 
% nAFC          see 2AFC
% 
% p             a vector of length K denoting a model's prediction for the 
%               expected values of y
% 
% PA            denotes parameters
% 
% parameters    alpha, beta, gamma and lambda.
% 
% psi           psychometric performance function, relating stimulus intensity x
%               to the probability of a correct or positive response. A common 
%               form for predicting performance in a single psychophysical
%               experiment is
%                   p = psi(x; {alpha, beta, gamma, lambda}) =
%                          gamma + (1 - gamma -lambda) F(x; {alpha, beta})
%               See the MATLAB function PSI.
% 
% r             a vector of length K denoting the number of correct (or positive)
%               responses in each block of the data set (= y ./ n).
% 
% R             number of simulations performed
% 
% r_pd          correlation coefficient between p and d (model predictions and
%               signed deviance residuals). Used as a statistical check on the
%               functional form of one's model, (usually psi). This is the second
%               statistical measure returned by the PSIGNIFIT engine.
% 
% r_kd          correlation coefficient between k and d (chronological indices
%               and signed deviance residuals) excluding those points for which
%               y == 0 or y == 1. Used as a statistical check on any change in 
%               the observer's performance over time (between blocks). This is 
%               the third statistical measure returned by the PSIGNIFIT engine.
% 
% sensitivity   a way of examining the severity of bootstrap error. Our technique
% analysis      is to re-run the bootstrap m times, with different parameter sets
%               for the generating function. The m new parameter set lie on the 
% (sens)        boundary of a region in alpha-beta space. The default is to take 8
%               points that lie on the boundary of a joint confidence region of 
%               a given coverage  in parameter space. The shape of the region
%               is likelihood-based  (all points on the skin have the same deviance value 
%               with respect to the original data set). The points' precise locations are
%               chosen by an algorithm that uses the original bootstrap distribution of
%               parameters, and aims to spread out the points' directions in the alpha/beta
%               plane while exploring the extremes of variation in alpha and beta within the
%               region (gamma and lambda, if they are free parameters, may be varied in
%               order to accomplish this aim). At  the end of sensitivity analysis we report
%               the "worst-case"  variability estimate (see "worst" below).
% 
% shape         the functional form of F: in the current implementation, this can 
%               be Weibull, logistic, cumulative Gaussian, Gumbel or linear.
%               
% sim           matrix of simulated values: each row is a different simulation,
%               and each column is a different variable.
% 
% SL            denotes slopes
% 
% slope         gradient of the psychometric function with respect to x, 
%               evaluated at a particular threshold value for x. The "slope at 
%               0.5" would therefore usually refer to the value of dF/dx 
%               evaluated at the point at which F(x) = 0.5. Slopes can also be 
%               calculated in the context of psi (so the "75% slope" would be 
%               d(psi)/dx evaluated where psi(x) = 0.75). See the entry for 
%               "threshold" below.
% 
% TH            denotes thresholds
% 
% theta         [alpha beta gamma lambda].
% 
% threshold     inverse of the psychometric function with respect to x.
%               The "threshold at 0.5" would usually refer to F^-1(0.5). This is 
%               a threshold in the context of the underlying psychometric 
%               function F, which is the default measurement in FINDTHRESHOLD and
%               FINDSLOPE. By passing the option 'performance' into these two
%               functions, thresholds can instead be calculated in the context of
%               the psychometric performance function psi. So the "75% 
%               performance threshold" would be psi^-1(0.75) and the "75%
%               performance slope" would be the derivative of psi at that point.
%               Note, however, that the PSIGNIFIT engine can only calculate BCa
%               confidence limits for "underlying" thresholds and slopes (inverse of F).
% 
% w             a vector of length K denoting the number of incorrect (or
%               negative) responses in each block of the data set (= n - r).
% 
% worst-case    a matrix with the same format as "lims": for each column (i.e.
% bootstrap     each variable) confidence limits are listed. For a certain 
% limit         variable t (a threshold, for example), let us use t_0 to denote
%               the value of t in the bootstrap generating function, and u_0 to 
% (worst)       denote, say, the upper limit of a confidence interval obtained by 
%               the bootstrap method. In sensitivity analysis, we perform m 
%               additional bootstraps: each one has a different generating 
%               function, so each one has a different initial value for t: 
%               t_1.....t_m. The m bootstraps yield m estimates for the upper 
%               confidence interval limit, u_1....u_m. Now, finally, we can 
%               define the "worst case" bootstrap limit u_worst:
%                   u_worst = t_0 + max([u_0-t_0, u_1-t_1, ......u_m-t_m])
%               So, the difference between u_worst and t_0 is the same as the
%               largest difference between u and t encountered during sensitivity 
%               analysis.
% 
% x             a vector of length K denoting the stimulus value for each block
%               in the data set.
% 
% y             a vector of length K denoting the proportion of correct responses
%               for each block in the data set (= r ./ n).
% 
% yes/no        any single-interval experimental paradigm, in which the
%               observer sees one stimulus per trial.
% 

% Part of the psignifit toolbox version 2.5.6 for MATLAB version 5 and up.
% Copyright (c) J.Hill 1999-2005.
% Please read the LICENSE and NO WARRANTY statement in psych_legal.m
% mailto:psignifit@bootstrap-software.org
% http://bootstrap-software.org/psignifit/
