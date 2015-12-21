function H = htable;
% Table H from Batschelet.  For use with pFromP
% NOTE
% 'p' is always in the range [1 0.001]. P-values larger than 0.1 
% are rounded to 1, values smaller than 0.001 are 0.001.
% INPUT
% void = 
% OUTPUT
% H = The table
%
% BK - 3.12.2000 - Last change $Date: 2001/08/23 19:18:05 $ by $Author: bart $
% $Revision: 1.3 $

H = [NaN	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	30	40	50	100	200;
0.02	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
0.04	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
0.06	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
0.08	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
0.1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
0.12	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.056;
0.14	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.02;
0.16	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.077	0.006;
0.18	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.039	0.001;
0.2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.018	0.001;
0.22	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.088	0.008	0.001;
0.24	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.099	0.055	0.003	0.001;
0.26	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.066	0.033	0.001	0.001;
0.28	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.095	0.042	0.019	0.001	0.001;
0.3	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.066	0.026	0.01	0.001	0.001;
0.32	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.094	0.085	0.076	0.045	0.016	0.005	0.001	0.001;
0.34	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0.098	0.087	0.077	0.069	0.061	0.054	0.03	0.009	0.003	0.001	0.001;
0.36	1	1	1	1	1	1	1	1	1	1	1	1	1	0.096	0.084	0.073	0.064	0.056	0.049	0.043	0.038	0.019	0.005	0.001	0.001	0.001;
0.38	1	1	1	1	1	1	1	1	1	1	1	0.098	0.084	0.073	0.063	0.054	0.046	0.04	0.034	0.03	0.025	0.012	0.003	0.001	0.001	0.001;
0.4	1	1	1	1	1	1	1	1	1	1	0.089	0.075	0.064	0.054	0.046	0.039	0.033	0.028	0.023	0.02	0.017	0.007	0.001	0.001	0.001	0.001;
0.42	1	1	1	1	1	1	1	1	0.1	0.083	0.069	0.057	0.048	0.039	0.033	0.027	0.023	0.019	0.016	0.013	0.011	0.004	0.001	0.001	0.001	0.001;
0.44	1	1	1	1	1	1	1	0.096	0.079	0.064	0.052	0.043	0.035	0.028	0.023	0.019	0.015	0.013	0.01	0.008	0.007	0.002	0.001	0.001	0.001	0.001;
0.46	1	1	1	1	1	1	0.096	0.077	0.061	0.049	0.039	0.031	0.025	0.02	0.016	0.013	0.01	0.008	0.006	0.005	0.004	0.001	0.001	0.001	0.001	0.001;
0.48	1	1	1	1	1	0.098	0.077	0.06	0.047	0.037	0.029	0.022	0.018	0.014	0.011	0.008	0.007	0.005	0.004	0.003	0.002	0.001	0.001	0.001	0.001	0.001;
0.5	1	1	1	1	0.104	0.079	0.061	0.046	0.035	0.027	0.021	0.016	0.012	0.009	0.007	0.005	0.005	0.003	0.002	0.002	0.001	0.001	0.001	0.001	0.001	0.001;
0.52	1	1	1	1	0.085	0.063	0.047	0.035	0.026	0.02	0.015	0.011	0.008	0.006	0.005	0.003	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.54	1	1	1	0.095	0.069	0.05	0.037	0.027	0.019	0.014	0.01	0.007	0.005	0.004	0.003	0.002	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.56	1	1	1	0.078	0.055	0.039	0.028	0.02	0.014	0.01	0.007	0.005	0.004	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.58	1	1	0.092	0.064	0.044	0.03	0.021	0.014	0.01	0.007	0.005	0.003	0.002	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.6	1	1	0.076	0.051	0.034	0.023	0.015	0.01	0.007	0.005	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.62	1	0.096	0.063	0.041	0.027	0.017	0.011	0.007	0.005	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.64	1	0.08	0.051	0.032	0.02	0.013	0.008	0.005	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.66	0.109	0.067	0.041	0.025	0.015	0.009	0.006	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.68	0.095	0.055	0.032	0.019	0.011	0.007	0.004	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.7	0.082	0.045	0.025	0.014	0.008	0.005	0.003	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.72	0.07	0.037	0.02	0.011	0.006	0.003	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.74	0.059	0.03	0.015	0.008	0.004	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.76	0.049	0.024	0.012	0.006	0.003	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.78	0.04	0.019	0.009	0.004	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.8	0.033	0.014	0.006	0.003	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.82	0.026	0.01	0.004	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.84	0.02	0.008	0.003	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.86	0.015	0.006	0.002	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001;
0.88	0.011	0.004	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001	0.001];
