function  test(in)
% This script tests most of the methods of the @Cricular class with examples
% given in Batschelet1981. 
% The name of the test is given, followed by two columns of numbers. On the left
% is what the Circular Toolbox calculated, on the right is the value given in 
% Batschelet.  Note that sometimes the p-values are different because I did not 
% type in the complete tables (i.e. every p-value above 0.1 will be 1, but also
% sometimes Batschelet states that the effect is significant at the level x, which
% just means that p<x. In the test report you will see x.
%
% Do not put this test function in @circular: it will call the wrong functions for corrcoef.
%
% To  have a look at some of the properties of the correlation coefficients, call test('cc')
%
% BK  - August 2001, last chagne $Date: 2001/08/21 03:42:45 $ by $Author: bart $
% $Revision: 1.2 $

if nargin ==1
    locCorrelationTest(0.35,'veccorr')
    locCorrelationTest(0.35,'rankcorr')
else 


% B, p12
locdisp(' Mean Phi and R 1.')
phi = [250 275 285 285 290 290 295 300 305 310 315 320 330 330 5];
c =circular(phi,ones(size(phi)),'DEG');
[phim,rm] = mstd(c);
compare(phim,302.7,rm,0.9001);

%B. p14
locdisp(' Mean Phi and R 2.')
phi = [0 0 0 0 0 0 0 180 180 180];
c =circular(phi,ones(size(phi)),'DEG');
[phim,rm] = mstd(c);
compare(phim,0,rm,0.4);

% B p148
locdisp('Hotelling One Sample ')
x = [0 2 8 11 12 14 18 23];
y = [3 8 5 11 4 16 9 8];
phi =mod(atan2(y,x),2*pi);
r = sqrt(x.^2 + y.^2);
c =circular(phi,r);
[p,F] = hotelling(c);
compare(p,0.01,F,33.1);


locdisp('Rayleigh Moore Test')
x = -1*[-0.064 0.124 0.372 0.479 0.495 0.419 0.326 0.121 0.007 -0.106];
y = -1*[-0.210 -0.306 0.079 0.102 0.550 0.646 0.807 0.862 0.380 0.601];
phi =mod(atan2(y,x),2*pi);
r = sqrt(x.^2 + y.^2);
c =circular(phi,r);
[d1,d2,d3,d4,d5,p]= mstd(c);
compare(p,0)
   
%B  p153
locdisp('Hotelling Two Sample')
x1 = [0.866 0.710 0.704 0.597 0.409 0.505 0.540 0.586 0.645];
y1 = -1*[0.312 0.452 0.460 0.441 0.473 0.672 0.774 0.667 0.726];
x2 = [-0.022 0.027 0.016 0.108];
y2 = -1*[0.048 0.328 0.242 0.204];
phi1 =mod(atan2(y1,x1),2*pi);
r1 = sqrt(x1.^2 + y1.^2);
phi2 =mod(atan2(y2,x2),2*pi);
r2 = sqrt(x2.^2 + y2.^2);
c1 =circular(phi1,r1);
c2 =circular(phi2,r2);
[p,T]= hotelling(c1,c2);
compare(T,135.4,p,0.001);

%B p155
locdisp('Mardia Two Sample')
x1 = [0.866 0.710 0.704 0.597 0.409 0.505 0.540 0.586 0.645];
y1 = -1*[0.312 0.452 0.460 0.441 0.473 0.672 0.774 0.667 0.726];
x2 = [-0.022 0.027 0.016 0.108];
y2 = -1*[0.048 0.328 0.242 0.204];
phi1 =mod(atan2(y1,x1),2*pi);
r1 = sqrt(x1.^2 + y1.^2);
phi2 =mod(atan2(y2,x2),2*pi);
r2 = sqrt(x2.^2 + y2.^2);
c1 =circular(phi1,r1);
c2 =circular(phi2,r2);
[p,U]= mardia(c1,c2);
compare(U,0,p,0.018);

% B p78
locdisp(' Kuipers One-Sample')
phi = [20 135 145 165 170 200 300 325 335 350 350 350 355];
c =circular(phi,'DEG');
c.axial =1;
[p,K] = kuipers(c);
compare(p,1,K,1.413)

% B p60
locdisp('V Test')
phi = [0 175 195 225 240 240 260 295 330 340 345];
c =circular(phi,'DEG');
[p,U] = vtest(c,274);
compare(p,0.01,U,2.38);


% B. p188
locdisp('Rank Order Correlation Circ-Circ');
phi = [61.5 86.6 29.7 44.5 60.1 172.5];
theta = [82.6 239.9 92.4 37.0 248.3 352.2];
c1 = circular(phi,'DEG');
c2 = circular(theta,'DEG');
[r,p,R] = rankcorr(c1,c2);
compare(r,0.441,p,0.5,R,0.1945);

locdisp('Rank Order Correlation Circ-Lin');
phi = [30 100 120 170 240 260 300 330];
y = [1.5 1.6 1.7 2.0 2.1 1.8 1.4 1.2];
c = circular(phi,'DEG');
[r,p,X] = rankcorr(c,y);
compare(p,0.01,X,6.148);

%B p68
locdisp('Rao Test')
phi = [20 135 145 165 170 200 300 325 335 350 350 350 355];
c =circular(phi,'DEG');
[p,U] = rao(c);
compare(p,1,U,162)

locdisp('Rao Test- Axial Assumption')
c.axial =1;
[p,U] = rao(c);
compare(p,0.01);


%B p190
locdisp('Vector Correlation')
phi =   [60 90 135 150 210 240 255 300];
theta = [120 135 210 150 195 240 300 315];
c1 = circular(phi,'DEG');
c2 = circular(theta,'DEG');
[r,p,X] = veccorr(c1,c2);
compare(r^2,1.48,p,0.019,X,11.84)


if 0
    %Waiting on implementation
locdisp('Vector Correlation Circ-Lin');
phi = [30 100 120 170 240 260 300 330];
y = [1.5 1.6 1.7 2.0 2.1 1.8 1.4 1.2];
c = circular(phi,'DEG');
[r,p,X] = veccorr(c,y);
compare(r^2,0.74,p,0.053,X,5.92);
end

% B  p81
locdisp('Watson Test')
phi = [20 135 145 165 170 200 300 325 335 350 350 350 355];
c =circular(phi,'DEG');
[p,U] = watson(c);
compare(p,0.184,U,0.1361)

%B p100 - B does some serious rounding here. The function is correct
locdisp('Watson Williams')
phi= [-20 -10 0 10 20];
n1 = [1 7 2 0 0];
n2 = [0 3 3 3 1];
c1 = circular(phi,n1,'DEG');
c2 = circular(phi,n2,'DEG');
[p, F] =watsonwilliams(c1,c2);
compare(p,0.01,F,8.6);


%B  p 123
locdisp('F Test')
phi1 = [25 50 45 45 70 40];
phi2 = [350 40 285 320 320 15 290];
c1 = circular(phi1,'DEG');
c2 = circular(phi2,'DEG');
[p,F,df1,df2] = ftest(c1,c2);
compare(p, 0.05, F, 8.08);
end


function locdisp(string)
disp('*********************************');
disp(['**  ' string ' **']);
disp('*********************************');
disp(' BK               BA');

function locCorrelationTest(level,method)
nin = nargin;
if nin<2
    method = 'veccorr'
    if nin < 1
        level = 0.1;
end;end

degs = 1:3:360;
sigmas = 1:360;
a =circular(degs,'deg');
cntr =1;
for sigma =sigmas
    b =circular( degs + sigma*randn(size(degs)),'deg');
    eval(['[r(cntr),p(cntr)] = ' method '(a,b);']);
    cntr = cntr+1;
end

index= min(find(cumsum(r<level) >3))
sigmaLevel  = sigmas(index);
findfig(['RankCorr Test -' method])
subplot(2,1,1)
    plotyy(sigmas,r,sigmas,p);
    xlabel 'Sigma'
    title (['Correlation Coefficient. Method: ' method ]);
subplot(2,1,2)
    b =circular( degs + sigmaLevel*randn(size(degs)),'deg');
    plot(deg(a),deg(b),'.')
    xlabel 'Deg'
    ylabel 'Deg'
    title (['Representative Dataset for R =' num2str(level) ' (sigma = ' num2str(sigmaLevel) ')']);




function compare(varargin)
for i=1:2:nargin
    disp([ num2str(varargin{i}) '           ' num2str(varargin{i+1})]);
end