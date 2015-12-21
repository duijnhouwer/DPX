function display(c)
% Display a circular object.
%
% BK - 27.7.2001 - last change $Date: 2001/08/23 19:23:53 $ by $Author: bart $
% $Revision: 1.5 $

% JG - 29.7.2010 - expanding to handle array of circular objects 
if length(c)>1
    disp([num2str(size(c,1)) 'x' num2str(size(c,2))  ' array of circular objects'])
else


if strcmpi(c.units,'DEG')
    phi = c.phi*180/pi;
else
    phi = c.phi;
end
if (c.axial)
    axialStr = 'with axial data';
else
    axialStr = '';
end
disp(['A circular object ' axialStr '(' c.units ')']);
if isgrouped(c)
    disp(['Binsize : ' num2str(360/c.groups)  ' (Corrections will be applied for mean length)']); 
end
if c.n*c.k <25 %Dont show if there are too many data
if c.k>1
    disp(['Phi: ' num2str(phi(:)',3)]);
    disp(['R: ' num2str(c.r(:)',3)]);
else
disp(['Phi: ' num2str(phi',3)]);
disp(['R: ' num2str(c.r',3)]);
end
end

disp(['N: ' num2str(c.n)]);
disp(['K: ' num2str(c.k)]);
end