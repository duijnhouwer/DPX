function varargout = plot(c,options,start,nrSpokes,directionOnly)
% Plot a circular set of data.
% INPUT
% c = Circular data 
% options	1. A struct with handle properties that are appropriate for the arrows (a.colour ='r' , for instance)
% 				2. A mode string: 'MEAN'		Add a vector showing the mean 
%										'MEAONLY'	Show only the mean
%										'MEDIAN'		Add a vector showing the median.
%										'SUM' 		Add a vector showing the sum vector.
% start		For the calculation of the median only: where to start on the circle.
% nrSpokes  The number of spokes on the polar plot.
% OUTPUT
% h	=  A vector of handles of all the vectors that were plotted.
%
% BK - 27.7.2001 - last change $Date: 2006/02/24 18:07:13 $ by  $Author: micah $
% $Revision: 1.10 $

nin =nargin;
fig =gcf;

if (nin<5)
    directionOnly=false;
     if nin <4 
         nrSpokes =4;
         if nin <3 
             start =0;
             if nin <2 
                 options ='BASIC';
             end;end;end;end;
               
         

% Basic compass plot. Show it only if the OPTIONS argument does not conatin the 
% word ONLY.
[x,y] = pol2cart(c.phi,c.r);
if ischar(options) 
    if isempty(findstr(options,'ONLY'))   
        h = compass(x,y,'b');%,max(c.r),nrSpokes); 
        hold on
    else
        h = [];
    end
else
    if isnumeric(options) 
           maxR = options;
    else     
           maxR = max(c.r);
    end
    h = bkpolar(c.phi,c.r,'b.',maxR,nrSpokes); 
    hold on
end

if isstruct(options); 
    set(h,options);
else
    if nin>1
        % Additional plots, depending on options argument
        switch upper(options)            
        case {'MEAN','MEANONLY'}
            [phi,r,cm,d3,d3,p] = mstd(c);
            if (directionOnly); cm = normalise(cm); end;
            if strcmpi(options,'MEANONLY')
                    hm = plot(cm,1);
            else
                hm = plot(cm);
            end
            set(hm,'Color','r','LineWidth',2);
            if isdeg(c)
                phi = phi*pi/180;
            end

            [x,y] = pol2cart(phi,r);
            for i = 1:length(phi) % Multiple groups
                text(1.2*cos(phi),1.2*sin(phi),['p=' num2str(p(i))]);            
            end
            h = [h ; hm];
        case 'MEDIAN'
            cm = median(c,start);
            hm = plot(cm);
            set(hm,'Color','r','LineWidth',2);
            hold on
            if isnumeric(start)
                start = circular(start,1,c.units);
            end
            [x,y] = pol2cart(start.phi,start.r);
            hl = line([0 x],[0 y]);
            set(hl,'Color','r','LineWidth',2,'LineStyle','--');
            h = [h ; hm ; hl];
        case 'SUM'
            startX = 0;
            startY = 0;
            minX =0; minY = 0;maxX = 0;maxY = 0;
            for i =1:c.n;
                [x,y] = pol2cart(c.phi(i),c.r(i));
                line([startX;startX+x],[startY;startY+y]);
                hold on
                startX  = startX+x;
                startY  = startY+y;
                minX = min(minX,startX);
                maxX = max(maxX,startX);
                minY = min(minY,startY);
                maxY = max(maxY,startY);            
            end
            set(gca,'Xlim',[minX maxX],'Ylim',[minY maxY]);
            s =sum(c);
            h=plot(s);
            set(h,'Color','r')
        case {'LINE','LINEONLY'}
            [x,y] = pol2cart(c.phi,c.r);
            x = [x;x(1)]; % Close the loop
            y = [y;y(1)];
            h  = line(x,y);
            
        otherwise
            
        end
    end
end
if nargout ==1
    varargout{1} = h;
end
