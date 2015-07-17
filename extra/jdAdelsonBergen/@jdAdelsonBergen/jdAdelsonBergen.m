classdef jdAdelsonBergen  < hgsetget
    
    % jdAdelsonBergen
    %
    % Object-oriented implementation of the Adelson-Bergen motion energy model
    % Based on George Mather's implementation from http://www.georgemather.com/Model.html
    %
    % public properties:
    %    stimulus   A matrix with cols=space, rows=time; 0=black, 1=white 
    %               Or the name of a MAT file containing such a matrix in 
    %               a variable named 'stim'
    %
    % public methods:
    %    run        Runs the model on the stimulus
    %
    % See also: jdAdelsonBergen2DTuning
    %
    % Jacob Duijnhouwer, 2015-07-16
    
    properties (Access=public)
        stimulus; 
    end
    properties (GetAccess=public,SetAccess=protected)
        filters;
        filterMatch;
        totalNrg;
        normFiltResps;
        dirNrg;
        netNrg;
    end
    methods (Access=public)
        function M=jdAdelsonBergen(stim)
            if nargin==0
                M.stimulus=[];
            else
                M.stimulus=stim;
                M.run;
            end 
        end
        function M=run(M)
            if isempty(M.stimulus)
                warning('stimulus is empty, loading Figure 16 from AB1986 as an example');
                load('AB16.mat');
                M.stimulus=stim;
            end
            M.filters=M.makeSpatTempFilters;
            M.filterMatch=M.calcSquaredFilterMatch(M.stimulus,M.filters);
            M.totalNrg=M.calcTotalEnergy(M.filterMatch);
            M.normFiltResps=M.calcNormalizedFilterResp(M.filterMatch,M.totalNrg);
            M.dirNrg=M.calcTotalDirectionalEnergy(M.normFiltResps);
            M.netNrg=M.calcNetMotionEnergy(M.dirNrg);
        end
    end
    methods (Static)
        function filters=makeSpatTempFilters
            % Step 1a ---------------------------------------------------------------
            %Define the space axis of the filters
            nx=80;              %Number of spatial samples in the filter
            max_x =2.0;         %Half-width of filter (deg)
            dx = (max_x*2)/nx;  %Spatial sampling interval of filter (deg)
            % A row vector holding spatial sampling intervals
            x_filt=linspace(-max_x,max_x,nx);
            % Spatial filter parameters
            sx=0.5;   %standard deviation of Gaussian, in deg.
            sf=1.1;  %spatial frequency of carrier, in cpd
            % Spatial filter response
            gauss=exp(-x_filt.^2/sx.^2);          %Gaussian envelope
            even_x=cos(2*pi*sf*x_filt).*gauss;   %Even Gabor
            odd_x=sin(2*pi*sf*x_filt).*gauss;    %Odd Gabor
            % Step 1b ----------------------------------------------------------------
            % Define the time axis of the filters
            nt=100;         % Number of temporal samples in the filter
            max_t=0.5;      % Duration of impulse response (sec)
            dt = max_t/nt;  % Temporal sampling interval (sec)
            % A column vector holding temporal sampling intervals
            t_filt=linspace(0,max_t,nt)';
            % Temporal filter parameters
            k = 100; % Scales the response into time units
            slow_n = 9; % Width of the slow temporal filter
            fast_n = 6; % Width of the fast temporal filter
            beta =0.9; % Weighting of the -ve phase of the temporal resp relative to the +ve phase.
            % Temporal filter response
            slow_t=(k*t_filt).^slow_n .* exp(-k*t_filt).*(1/factorial(slow_n)-beta.*((k*t_filt).^2)/factorial(slow_n+2));
            fast_t=(k*t_filt).^fast_n .* exp(-k*t_filt).*(1/factorial(fast_n)-beta.*((k*t_filt).^2)/factorial(fast_n+2));
            % Step 1c --------------------------------------------------------
            e_slow= slow_t * even_x; %SE/TS
            e_fast= fast_t * even_x ; %SE/TF
            o_slow = slow_t * odd_x ; %SO/TS
            o_fast = fast_t * odd_x ; % SO/TF
            % Step 2 ---------------------------------------------------------
            filters.left1=o_fast+e_slow; % L1
            filters.left2=-o_slow+e_fast; % L2
            filters.right1=-o_fast+e_slow; % R1
            filters.right2=o_slow+e_fast; % R2
        end
        function filterMatch=calcSquaredFilterMatch(stim,filters)
            % Step 3, convolve filters and stim
            % Rightward responses
            filterMatch.right1=conv2(stim,filters.right1,'same').^2;
            filterMatch.right2=conv2(stim,filters.right2,'same').^2;
            % Leftward responses
            filterMatch.left1=conv2(stim,filters.left1,'same').^2;
            filterMatch.left2=conv2(stim,filters.left2,'same').^2;
        end
        function totalEnergy=calcTotalEnergy(sfr)
            right=sfr.right1+sfr.right2;
            left=sfr.left1+sfr.left2;
            totalEnergy=sum(right(:))+sum(left(:));
        end
        function normFiltResps=calcNormalizedFilterResp(sfr,totalEnergy)
            % Step 5 - Normalisation --------------------------------------------
            normFiltResps.RR1=sum(sfr.right1(:))/totalEnergy;
            normFiltResps.RR2=sum(sfr.right2(:))/totalEnergy;
            normFiltResps.LR1=sum(sfr.left1(:))/totalEnergy;
            normFiltResps.LR2=sum(sfr.left2(:))/totalEnergy;
        end
        function dirNrg=calcTotalDirectionalEnergy(nfr)
            % Step 6 - Directional energy ---------------------------------------
            dirNrg.rightTotal=nfr.RR1+nfr.RR2;
            dirNrg.leftTotal=nfr.LR1+nfr.LR2;
        end
        function netNrg=calcNetMotionEnergy(dirNrg)
            % Step 7 - Net motion energy -----------------------------------------
            netNrg=dirNrg.rightTotal - dirNrg.leftTotal;
        end
    end
    methods
        function set.stimulus(M,value)
            if ischar(value)
                if ~exist(value,'file')
                    error(['Stimulus file ' value ' does not exist']);
                else % test the file
                    load(value); % brings variable 'stim' into scope
                    if ~exist('stim','var')
                        error(['Stimulus file ' value ' does not contain a variable called stim like it should']);
                    else
                        value=stim;
                    end
                end
            end
            if ~isnumeric(value) || any(value(:)>1) || any(value(:)<0)
                error('stimulus should be numeric values between 0 and 1 inclusive');
            end
            M.stimulus=value;
        end
    end
end