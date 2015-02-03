% PSYCH_OPTIONS       options available in the PSIGNIFIT engine
% 
%     The following options can be applied to the input to the psignifit engine. 
%     The format for the preferences is as a batch string. See the documentation 
%     on "batch_strings" for details. Note that if an identifier appears more 
%     than once in the input, only the last occurrence will be interpreted.
% 
% Model options
% =============
% 
% #SHAPE
%     The shape of the underlying psychometric distribution function F.
% 
%     supported values: Weibull, logistic, cumulative Gaussian, Gumbel, linear
%     default: logistic
% 
% #N_INTERVALS
%     The number of intervals in each trial of the experiment, which
%     will determine "chance" performance. Enter any number greater than 1 for
%     n-alternative forced- choice (n-AFC) design. Enter 1 for a subjective design,
%     in which there is only one interval per trial.
% 
%     default: 2
% 
% #ALPHA_LIMITS, #ALPHA_PRIOR
% #BETA_LIMITS, #BETA_PRIOR
% #GAMMA_LIMITS, #GAMMA_PRIOR
% #LAMBDA_LIMITS, #LAMBDA_PRIOR
%     The limits in which each of the parameters is allowed to vary. If 
%     parameters stray outside sensible limits during the search, a Bayesian prior 
%     probability can be applied to the likelihood value on the error surface at that 
%     point, to encourage the parameter to stay within limits. The shape of the 
%     prior is using _LIMITS is flat, effectively a solid barrier through which the
%     variable will not  pass: probability 1 within limits, 0 outside.
%     The syntax
%         #WHATEVER_LIMITS lo, hi
%     is equivalent to
%         #WHATEVER_PRIOR -flat   lo, hi
%     and the two options (_LIMITS and _PRIOR) cannot be applied simultaneously
%     to the same variable.
%
%     Using the _PRIOR syntax, the shape of the prior can be changed. For example,
%         #LAMBDA_PRIOR -cosine  lo, hi
%     implements a raised cosine prior which touches 0 at the values indicated, and
%     remains at 0 outside that range.
%         #LAMBDA_PRIOR -beta  lo, hi, z, w
%     implements a beta probability-density function with parameters {z, w} in the
%     range [lo, hi] (again, 0 outside that range).
%         #LAMBDA_PRIOR -gaussian  mu, std
%     implements a Gaussian prior with the given mean and standard deviation.
% 
%     ALPHA & BETA defaults:
%         by default there are no priors on alpha and beta (it is usually clearer
%         to apply priors to "shift" and "slope" in any case -- see below).
%     GAMMA defaults: 
%         if #N_INTERVALS = 1, the default is a flat prior between 0 and 0.05
%         otherwise, the default is [0, 1] (but GAMMA is usually fixed in the nAFC
%         case, and this is indeed the default behaviour)
%     LAMBDA defaults:
%         flat prior between 0 and 0.05
% 
% #SHIFT_LIMITS, #SHIFT_PRIOR
% #SLOPE_LIMITS, #SLOPE_PRIOR
%     These allow priors to be applied to aspects of the psychometric 
%     function that have the same meaning whatever shape of function you are 
%     using. "Shift" means F_inverse(0.5), as a measure of the curve's
%     displacement along the abscissa. By default, "slope" means dF/dx,
%     evaluated at the "shift" point. However, if #SLOPE_OPT is set to "log x"
%     then the derivative is taken with respect to log10(x) rather than x.
% 
%     As with all priors, take care that the priors are not so restrictive that 
%     the engine cannot make a reasonable guess at the parameters. When fitting
%     simulated data, make sure the generating distribution itself is not
%     precluded by your priors.
% 
%         SHIFT and SLOPE priors are absent by default.
% 
% #LAMBDA_EQUALS_GAMMA
%     Set this boolean flag, and the lower asymptote GAMMA and the upper
%     asymptote offset LAMBDA are constrained always to be equal (for a
%     particular kind of 2AFC-without-feedback design).
% 
% #FIX_ALPHA
% #FIX_BETA
% #FIX_GAMMA
% #FIX_LAMBDA
%     Fix one or more of the four parameters. Unless a parameter is explicitly 
%     fixed, it is assumed to be free. The exception is GAMMA, which is fixed in 
%     n-AFC paradigms. To free GAMMA explicitly, use #FIX_GAMMA NaN
% 
%         #FIX_ALPHA, #FIX_BETA and #FIX_LAMBDA are absent by default
%         #FIX GAMMA is absent by default when #N_INTERVALS = 1, otherwise it 
%             defaults to 1/#N_INTERVALS
% 
% #FIX_SHIFT
% #FIX_SLOPE
%     Shift and slope can also be fixed -- note that these options cannot be
%     used simultaneously with FIX_ALPHA or FIX_BETA. Remember that the units
%     in which SLOPE is expressed depend on SLOPE_OPT.
% 
%         absent by default
% 
% 
% Measures of interest
% ====================
% 
% #CONF
%     Cumulative probability levels at which confidence interval boundaries are
%     calculated: range (0, 1). 
% 
%     default:  [0.023 0.159 0.841 0.977]
%        (equivalent coverage to [-2 -1 +1 +2] std's from the mean of a Normal)
%        
% #CUTS
%     A list of probability levels at which thresholds and slopes are to be
%     evaluated. Values should be in the range (0, 1).  The inverse of F is evaluated
%     at these values.
% 
%     default: [0.2 0.5 0.8]
% 
% #SLOPE_OPT
%     By default, "slope" measurements take the derivative of F with respect
%     to x. If you switch the #SLOPE_OPT option from "linear x" to "log x",
%     derivatives are taken with respect to log10(x).
% 
%     supported values: linear x, log x
%     default:  linear x
% 
% Generation options
% ==================
% 
%     When simulated data are generated, the generating distribution is, by 
%     default, the maximum-likelihood fit to the original data using the 
%     requested fitting model. To change this, in order to examine the effects of 
%     another hypothesized distribution, use one of the following options. Note 
%     that, when the generating distribution is specified separately, initial 
%     statistics returned reflect the goodness-of-fit of the generating 
%     distribution rather than the fit to the initial data.
% 
%     IMPORTANT: when no simulated data are generated (#RUNS = 0), #GEN_...
%     options are ignored entirely: thus any fit statistics returned refer to the
%     fitted distribution. When #RUNS is non-zero and a custom generating
%     distribution is supplied using the following options, fit statistics apply
%     to the generating distribution (as a hypothesis under test).
% 
% #GEN_SHAPE
%     Changes the underlying function F for the purposes of generating simulated
%     data. Legal values are the same as for #SHAPE. Must be used in conjunction
%     with #GEN_PARAMS, since any parameter sets already fitted will be meaningless
%     once the shape has changed.
% 
%         defaults to the current #SHAPE setting.
% 
% #GEN_PARAMS
%     Changes the generating parameter set, specified as a vector of four numbers 
%     in the usual order: alpha, beta, gamma, lambda.
% 
%         defaults to the maximum-likelihood fit to the initial data (i.e. a 
%             parametric bootstrap is performed) provided that different 
%             functional forms have not been specified in #SHAPE and #GEN_SHAPE.
% 
% #GEN_VALUES
%     Sets the generating probabilities for each block of observations directly, 
%     rather than calculating them via a generating function. Thus, GEN_VALUES 
%     should contain one probability value per point in the original data set. 
%     This is useful in cases where predicted performance values come from a much 
%     more complicated model. The use of this option precludes the use of 
%     #GEN_SHAPE and/or #GEN_PARAMS.
% 
%         absent by default.
% 
% 
% Data options
% ============
% 
% #DATA_X
% #DATA_Y
% #DATA_N
% #DATA_RIGHT
% #DATA_WRONG
%     Allows data to be input as separate vectors. All vectors must be of the 
%     same length. X refers to stimulus values, N to number of trials in each 
%     block, Y to proportion correct in each block, and RIGHT and WRONG refer to 
%     the numbers of correct and incorrect responses in each block. Clearly there 
%     is redundancy here: the requirements are only that the data set be 
%     completely specified, and that none of the information conflict. Note also 
%     that only the last occurrence of a unique #-identifier is parsed: so all 
%     but the last specification of #DATA_X, for example, will be ignored.
% 
%     The exception to the requirement for complete specification of the data set 
%     is the case where only a set of simulations is required, with no original 
%     fit. This occurs when #RUNS is non-zero, the generating distribution has 
%     been specified using the #GEN_... options, and no #DATA_Y, #DATA_RIGHT or
%     #DATA_WRONG are supplied. In this case, only #DATA_X and #DATA_N are
%     required.
% 
%     NB: In MATLAB, it is usually more convenient to enter the data as a matrix
%     argument. Data input as a MATLAB matrix or as whitespace-delimited text 
%     will always override the #DATA_... options.
% 
%         absent by default.
% 
% #MATRIX_FORMAT
%     The format in which data sets are interpreted, when they are passed in as 
%     matrices either from MATLAB or as a block of text. Possible values are:
% 
%     xyn:  column 2: proportion correct; column 3: number of trials in block
%     xrn:  column 2: number of correct responses; column 3: number of trials
%     xrw:  column 2: number of correct responses; column 3: number incorrect
%        (in all cases the 1st column contains stimulus values)
% 
%     If #MATRIX_FORMAT is not specified explicitly, the engine makes an 
%     intelligent guess from the numerical content of the input matrix. If no 
%     matrix is supplied, the default output format is xyn.
% 
% Sensitivity analysis
% ====================
% 
% #SENS
%     The number of points at which to sample the alpha-beta surface during
%     sensitivity analysis (a value of 0 naturally disables sensitivity analysis).
% 
%         default:  8
% 
% #SENS_COVERAGE
%     The coverage of the region explored in alpha-beta space.
% 
%         default:  0.5
% 
% Miscellaneous bootstrap options
% ===============================
% 
% #RUNS
%     The number of simulated data sets to generate.
% 
%         default: 0  (i.e. initial fit only)
% 
% #REFIT
%     If #REFIT is set to TRUE, then the statistical measures calculated for each 
%     simulated data set are calculated using the bootstrap maximum-likelihood 
%     parameter set for that data set. Thus the resultant distribution takes into 
%     account the effect of the number of degrees of freedom inherent in one's 
%     fitted model: if we were to trust an asymptotic approximation, then the use 
%     of the #REFIT option would be analogous to adjusting the degrees of freedom 
%     in the chi-squared approximation by -P, where P is related (though not
%     necessarily equal to) the number of free parameters in the model. A #REFIT
%     setting of TRUE is incompatible with a #COMPUTE_PARAMS setting of FALSE.
% 
%     If #REFIT is FALSE, then statistical measures for all simulated data sets 
%     are calculated using their generating distribution, which will usually be 
%     the maximum-likelihood fit to the original data. The analogous asymptotic
%     approximation would have K degrees of freedom (K = number of data points).
%     This option is useful for assessing models that predict performance values
%     for each experimental condition directly, without involving a Weibull,
%     logistic or any other approximation to the shape of each psychometric
%     function. Using the #REFIT TRUE option, it would only be possible to gain
%     statistical measures appropriate to the individual approximations, because
%     the fitting engine is designed to fit sigmoidal forms for individual
%     psychometric functions. The disadvantage of turning #REFIT off is that the
%     resulting distribution consists of over-estimates of the dispersion one 
%     would actually measure for each data set. As a result, the #REFIT FALSE 
%     option should not be used to reject data sets on the basis of under- 
%     dispersion.
% 
%         default: TRUE for bootstraps (where the engine fits parameters to
%                  original data and then uses them to generate simulated data)
%                  FALSE if a generating distribution is supplied using the
%                  #GEN_PARAMS or #GEN_VALUES options.
% 
% #EST_GAMMA
%     Only applies in subjective designs (#N_INTERVALS = 1). A reasonable guess 
%     as to the base probability of a subject giving a positive answer in the 
%     absence of a signal. Used in the preliminary guess procedure, which 
%     initializes the simplex search (see the documentation "engine_technotes" 
%     where available).
% 
%         default: 0.01
% 
% #EST_LAMBDA
%     A reasonable guess as to the subject's miss rate (subjective paradigms) or 
%     stimulus-independent error rate (n-AFC designs). Used in the preliminary 
%     guess procedure, as an initialization parameter for the simplex search (see 
%     the documentation "engine_technotes" where available).
% 
%         default: 0.01
% 
% #MESH_RESOLUTION
%     The sampling resolution of the initial guess procedure. See the 
%     documentation "engine_technotes" where available.
% 
%         default (recommended): 10
% 
% #MESH_ITERATIONS
%     The number of iterations of the initial guess procedure. See the 
%     documentation "engine_technotes" where available.
% 
%         default (recommended): 10
% 
% #RANDOM_SEED
%     The random seed is reported after bootstraps in "verbose" mode. It can also 
%     be extracted using the #WRITE_RANDOM_SEED option. If it is passed in again,
%     as #RANDOM_SEED, then the same bootstrap data sets will be generated again 
%     (provided the input data set and model are identical). This is useful if 
%     you are interested in obtaining fit statistics for the bootstrap data sets 
%     which produced certain fits, or examining particular data sets with
%     #WRITE_SIMULATED_DATA.
% 
%         default: 0
%             (which means the random seed will be taken from the system clock)
% 
% #VERBOSE
%     Print out summary information for the fitting and generating models, unless 
%     set to FALSE.
% 
%         default: TRUE
% 
% #COMPUTE_PARAMS
%     Set this to FALSE to prevent the program from conducting maximum-likelihood 
%     estimation of parameters. This speeds up operation, if all that is required 
%     is a goodness-of-fit test.
% 
%         default: TRUE
% 
% #COMPUTE_STATS
%     Set this to FALSE if statistical measures of goodness-of-fit are not 
%     required. This speeds up the simulation process, although by a very small 
%     amount compared to the time taken for parameter estimation.
% 
%         default: TRUE
% 
% Output options
% ==============
% 
%     The various #WRITE.... options can be used to output intermediate stages of 
%     the fitting and simulation process. Specify a string. The MATLAB version 
%     will treat this string as an array name, to which the desired output will 
%     be assigned, e.g:
%             #WRITE_RANDOM_SEED          rSeed
%     Standalone and UNIX command-line versions will treat the string as a file 
%     name or file path, to which the results will be output as text, e.g:
%             #WRITE_SIMULATED_DATA       ~/bootstrap/sim1.dat
%     The -a switch may be used to ensure that data are appended to the requested
%     array or file instead of overwriting, e.g:
%             #WRITE_PA_EST           ./params.out
%             #WRITE_PA_SIM     -a     ./params.out
% 
%     Note that a "feature" of the parser in the psignifit engine is that the 
%     same output cannot be written more than once per call to the engine, or 
%     appended more than once per call to the engine: this is because only the 
%     last occurrence of each #-identifier in the batch string is parsed.
% 
%     Another "feature" is that arrays are written in the order they are calculated,
%     rather than the order in which the #WRITE_... statements appear in the
%     preferences. The following statements
%             #WRITE_PA_SIM           ./params.out
%             #WRITE_PA_EST     -a     ./params.out
%     would have the undesirable effect of first appending the estimated parameters
%     to any existing file ./params.out, and THEN wiping them out with the simulated
%     parameters.
%     
%     In standalone/command-line versions (i.e. not MATLAB),  output may be directed
%     to  "stdout" or "-" (which also denotes stdout) or to "stderr".  In addition, the
%     -t and -n may be used explicitly to enable or suppress the printing of matrix names
%     in the output stream. Usually -n is set by default (titles not printed), except where
%     a group of related matrices are output using one command (e.g. #WRITE_PA) - see
%     below.
%     
%     All #WRITE_... options are absent by default, but if none are specified at all, standalone
%     and command-line versions of the engine will print some relevant results to stdout.
%     
%     Descriptions of each option follow:
%     
% #WRITE_Y_SIM
%     outputs bootstrap data sets: each row of the output contains a set of simulated
%     performance values,  expressed as proportions of correct/positive responses
%     per block.
%     
% #WRITE_R_SIM
%     similar to #WRITE_Y_SIM, except that each value represents a number of correct
%     responses per block instead of a proportion.
%     
% #WRITE_RANDOM_SEED
%     see #RANDOM_SEED
%     
% #WRITE_PA
% #WRITE_ST
% #WRITE_TH
% #WRITE_SL
%     PA stands for parameters, ST for statistics, TH for thresholds, and SL for slopes.
%     If no ending is supplied (WRITE_PA as opposed to WRITE_PA_EST, for example),
%     then all the relevant information is output as a struct (in MATLAB  -  though this
%     will not work on MATLAB version 4.x) or as a text file (standalone application
%     or command-line utility). The following endings may be used to direct or
%     redirect parts of the structure:
%              _EST:     estimated or initial values
%              _SIM:     simulated values (each row is a different simulation)
%              _CPE:     cumulative probability estimates taken using the estimated and
%                        simulated values.
%              _DERIV:   see "deriv" in the glossary PSYCH_GLOSS.    (does not apply to ST)
%              _LFF:     see "deriv" in the glossary PSYCH_GLOSS.    (does not apply to ST)
%              _BC:      bias-correction terms (used in BCa method) (does not apply to ST)
%              _ACC:     "acceleration" terms (used in BCa method) (does not apply to ST)
%              _LIMS:    see "lims" in the glossary PSYCH_GLOSS.    (does not apply to ST).
%                        (refers to BCa limits only - returns empty if the BCa method is inapplicable)
%              _QUANT:   like "lims", except these limits are non-BCa (bootstrap quantiles).
%     
%     The keywords "null", "false" or "0" suppress output. A common usage is as follows:
%             #WRITE_TH               ./th.out
%             #WRITE_TH_SIM          null
%     This writes out all the information concerning  thresholds, EXCEPT the full array of
%     simulated thresholds.
%     
%     N.B. when writing a set of matrices to a file (using #WRITE_TH, for example), the -t
%     switch is set by defaut, so that matrix names are recorded in the output file, in "batch
%     string" format. This option may be cancelled with the -n switch.
% 
% #WRITE_FISHER
%     writes the expected Fisher information matrix for the initial parameter set (rows
%     and columns corresponding to fixed parameters are replaced by the appropriate
%     rows and columns of the identity matrix).
% 
% #WRITE_COV
%     writes the matrix of parameter covariance at the initial parameter values  (this
%     is the inverse of the Fisher information matrix). Used in the BCa method to calculate
%     LFFs. 
% 
% #WRITE_LDOT
%     writes a matrix containing the derivatives of log-likelihood with respect to each
%     of the parameters (4 columns) evaluated at the initial (MLE) parameter values using
%     each of  the simulated data sets in turn (R rows). Used in the BCa method, in conjuction
%     with the LFF for each measure of interest, to estimate "acceleration".
% 
% #WRITE_SENS_PARAMS
%     writes a matrix containing, on each row, a parameter set to be used in sensitivity
%     analysis (there are SENS_N rows, or fewer if variation in the bootstrap parameter
%     sets does not warrant that many). The points lie on the surface of a like-likelihood-based
%     joint confidence region of coverage SENS_COVERAGE in parameter space, spaced out as
%     much as possible in the alpha-beta plane.
% 
% #WRITE_FORMAT
%     specifies the format for numeric output via the above options. The format 
%     string should be suitable as an argument to the ANSI command printf, for 
%     the purposes of printing a double-precision floating-point number. e.g:
%             #WRITE_FORMAT       % .6lE
%     (N.B: does not apply in MATLAB, where values are assigned to a double-
%     precision array rather than being printed)
%     
%         default: %lg
% 
% 

% Part of the psignifit toolbox version 2.5.6 for MATLAB version 5 and up.
% Copyright (c) J.Hill 1999-2005.
% Please read the LICENSE and NO WARRANTY statement in psych_legal.m
% mailto:psignifit@bootstrap-software.org
% http://bootstrap-software.org/psignifit/
