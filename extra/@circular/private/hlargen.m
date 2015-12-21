function H = hlargen;
% Table 4.2.1 from Batschelet, for Rayleigh, For use with pFromCritical.
% test with large N.
% INPUT 
% void = 
% OUTPUT
% H = The table.
%
% BK -  16.8.2001 - last change $Date: 2001/08/23 19:18:05 $ by $Author: bart $
% $Revision: 1.3 $


H=[NaN  0.1	0.05	0.01	0.001;
        30	2.3	2.97	4.5	6.62;
        50	2.3	2.98	4.54	6.74;
        100	2.3	2.99	4.57	6.82;
        200	2.3	2.99	4.59	6.87;
        500	2.3	2.99	4.6	6.89;
        1000	2.3	3	4.61	6.91];
