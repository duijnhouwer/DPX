function bayesphys=dpxBayesPhysV1(varargin)
    % First check if bayesphys_V1 is on the path;
    if ~exist('tc_sample','file') || ~exist('compute_bf.m','file')
        error('errortag:bla',strcat('dpxBayesPhysV1 requires the bayesphys_v1 toolkit\n',...
            'You can download it from this page:\n',...
            'http://klab.smpp.northwestern.edu/wiki/index.php5/Code   (Look for the file ''Bayesphys v1.zip'').\n',...
            'Unzip the files somewhere on your system and add them to your Matlab path.\n', ...
            'In case the link died, try mailing me at j.duijnhouwer@gmail.com, I''ll send you my copies.'));
    end
    
    % Parse input
    p=inputParser;
    p.addParamValue('deg',[],@isnumeric);
    p.addParamValue('resp',[],@isnumeric);
    p.addParamValue('curvenames',{'constant','circular_gaussian_180','circular_gaussian_360','direction_selective_circular_gaussian','positivecosine'},@iscell)
    p.addParamValue('unit','spikerate',@(x)any(strcmpi(x,{'dfof','spikerate'})));
    p.parse(varargin{:});
    % Shorthand variables
    deg=p.Results.deg;
    resp=p.Results.resp;
    curvenames=p.Results.curvenames;
    x1 = 1:360;
    % what prob_model_name to use
    if strcmpi(p.Results.unit,'dfof')
        prob_model_name='add_normal';
    elseif strcmpi(p.Results.unit,'spikerate')
        prob_model_name='poisson';
    else
        error('unknown unit');
    end
    % Do the tests
    opts.TOOLBOX_HOME=fileparts(which('tc_sample'));
    opts.burnin_samples=1000;
    opts.num_samples=2000;
    opts.sample_period=50;
    S=cell(numel(curvenames),1);
    for zz=1:numel(curvenames);
        if strcmpi(curvenames{zz},'constant')
            S{zz}=tc_sample(deg,resp,curvenames{zz},prob_model_name,opts);
        elseif strcmpi(curvenames{zz},'circular_gaussian_180')
            S{zz}=tc_sample(deg,resp,curvenames{zz},prob_model_name,opts);
        elseif strcmpi(curvenames{zz},'circular_gaussian_360')
            S{zz}=tc_sample(deg,resp,curvenames{zz},prob_model_name,opts);
        elseif strcmpi(curvenames{zz},'direction_selective_circular_gaussian')
            S{zz}=tc_sample(deg,resp,curvenames{zz},prob_model_name,opts);
        elseif strcmpi(curvenames{zz},'positivecosine')
            % CRAZY!!! EVERTHING IN BAYESPHYS IS IN DEGREES EXCEPT THE COSINE FUNCTIONS!!!
            S{zz}=tc_sample(deg/180*pi,resp,curvenames{zz},prob_model_name,opts);
        else
            error(['Unknown tuning: ' curvenames{zz}]);
        end
    end
    % Make Bayes-Factor matrix for testing which model is best
    BF=zeros(numel(curvenames));
    for i=1:numel(curvenames)
        for j=1:numel(curvenames)
            BF(i,j)=compute_bf(S{i},S{j});
        end
    end
    % find out which model won
    winidx=0;
    for i=1:numel(curvenames)
        thisidx=1:size(BF,2)~=i;
        if all(BF(i,thisidx)>1)
            winidx=i;
            break;
        end
    end
    if winidx==0
        winstr='UNCLEAR';
    else
        winstr=curvenames{winidx};
    end
    bayesphys.BF=BF;
    bayesphys.S=S;
    bayesphys.curvenames=curvenames;
    bayesphys.winnerstr=winstr;
    bayesphys.bestCurveX{1}=x1;
    bayesphys.bestCurveY{1}=getBestCurvesForPlotting(S{winidx},winstr,x1);
end

%--- HELP FUNCTIONS -------------------------------------------------------


function [y]=getBestCurvesForPlotting(T,curvename,x1)
    if strcmpi(curvename,'UNCLEAR')
        y=nan(size(x1));
        return;
    end
    if isfield(T,'P5')
        y=jdMakeRow(getTCval(x1,curvename,[T.P1_median T.P2_median T.P3_median T.P4_median T.P5_median]));
    elseif ~isempty(strfind(curvename,'cosine'))
        % CRAZY!!! EVERTHING IN BAYESPHYS IS IN DEGREES EXCEPT THE COSINE FUNCTIONS!!!
        y=jdMakeRow(getTCval(x1/180*pi,curvename,[T.P1_median T.P2_median T.P3_median T.P4_median]));
    else
        y=jdMakeRow(getTCval(x1,curvename,[T.P1_median T.P2_median T.P3_median T.P4_median]));
    end
end
