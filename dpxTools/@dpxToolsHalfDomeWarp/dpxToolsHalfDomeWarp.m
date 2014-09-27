classdef dpxToolsHalfDomeWarp < hgsetget
    
    properties (Access='public')
        xListPix=[];
        yListPix=[];
        stepsPerDeg;
        pixelStep;
        LUT=struct('minA',[],'minE',[],'table',[]);
    end
    properties (GetAccess='public', SetAccess='protected')
        eListDeg=[];
        aListDeg=[];
    end
    properties (GetAccess='private')
        aGrid=[];
        eGrid=[];
        xGrid=[];
        yGrid=[];
    end
    methods (Access='public')
        function W=dpxToolsHalfDomeWarp
            load('calib.mat');
            ok=~isnan(A)&~isnan(E);
            W.aListDeg=A(ok);
            W.eListDeg=E(ok);
            W.xListPix=X(ok);
            W.yListPix=Y(ok);
            W.stepsPerDeg=10;
            W.pixelStep=0.2;
        end
        function plot(W)
            W.fitSplines;
            dpxFindFig(mfilename)
            subplot 121
            plot3(W.xListPix,W.yListPix,W.aListDeg,'ko','MarkerFaceColor','k');
            hold on;
            box on;
            dpxLabel('x','X (pix)','y','Y (pix)','z','Azi (deg)');
            hold on
            surfl(W.xGrid,W.yGrid,W.aGrid);
            subplot 122
            plot3(W.xListPix,W.yListPix,W.eListDeg,'ko','MarkerFaceColor','k');
            hold on;
            box on;
            dpxLabel('x','X (pix)','y','Y (pix)','z','Ele (deg)');
            hold on
            surfl(W.xGrid,W.yGrid,W.eGrid);
        end
        function makeLut(W,showplot)
            if nargin==1, showplot=true; end
            W.fitSplines;
            A=W.aGrid*W.stepsPerDeg;
            E=W.eGrid*W.stepsPerDeg;
            X=W.xGrid;
            Y=W.yGrid;
            W.LUT.minA=min(A(:));
            W.LUT.minE=min(E(:));
            xx=min(X(:)):W.pixelStep:max(X(:));
            yy=min(Y(:)):W.pixelStep:max(Y(:));
            startSec=-Inf;
            for i=1:numel(xx)
                ei=interp2(X,Y,E,xx(i),yy);
                ai=interp2(X,Y,A,xx(i),yy);
                ei=1+round(ei-W.LUT.minE);
                ai=1+round(ai-W.LUT.minA);
                for j=1:numel(yy)
                    W.LUT.table(ai(j),ei(j),1)=xx(i);
                    W.LUT.table(ai(j),ei(j),2)=yy(j);
                end
                if GetSecs-startSec>2
                    if showplot, W.plotLut; end
                    startSec=GetSecs;
                end
            end
            plotLut(W);
            dpxDispFancy('Inspect the LUTs. If there are any gaps or specs within the central areas, decrease ''pixelStep'''' and re-run ''makeLut''.');
        end
        function plotLut(W)
            if isempty(W.LUT.table)
                disp('Lookup table does not exist. Generate it using ''''makeLut''');
                return;
            end
            dpxFindFig('Lookup table');
            clf;
            subplot 121
            imagesc(W.LUT.table(:,:,1));
            title('X pixels');
            dpxLabel('x','azi (deg)','y','ele (deg)');
            set(gca,'XTickLabel',round((get(gca,'XTick')+W.LUT.minA)/W.stepsPerDeg));
            set(gca,'YTickLabel',round((get(gca,'YTick')+W.LUT.minE)/W.stepsPerDeg));
            colorbar('NorthOutside');
            subplot 122
            imagesc(W.LUT.table(:,:,2));
            title('Y pixels');
            dpxLabel('x','azi (deg)','y','ele (deg)');
            set(gca,'XTickLabel',round((get(gca,'XTick')+W.LUT.minA)/W.stepsPerDeg));
            set(gca,'YTickLabel',round((get(gca,'YTick')+W.LUT.minE)/W.stepsPerDeg));
            colorbar('NorthOutside'); 
            drawnow
        end
        function [xy, visibleIdx]=getXYpix(W,aziDeg,eleDeg)
            % XY will be a matrix with nDots-columns, 1st row X, 2nd row Y,
            % regardless of the orientation of the input vector aziDeg and
            % eleDeg;
            visibleIdx=1:numel(aziDeg);
            ai=1+round(aziDeg*W.stepsPerDeg-W.LUT.minA);
            ei=1+round(eleDeg*W.stepsPerDeg-W.LUT.minE);
            ai=ai(:);
            ei=ei(:);
            ok=ai>=1 & ai<=size(W.LUT.table,1) & ei>=1 & ei<=size(W.LUT.table,2);
            ai=ai(ok);
            ei=ei(ok);
            visibleIdx=visibleIdx(ok);
            x=W.LUT.table(sub2ind(size(W.LUT.table),ai,ei,ones(size(ai))*1));
            y=W.LUT.table(sub2ind(size(W.LUT.table),ai,ei,ones(size(ai))*2));
            ok=x>0 & y>0;
            x=x(ok);
            y=y(ok);
            visibleIdx=visibleIdx(ok);
            xy=[x(:) y(:)]';
        end
    end
    methods (Access='protected')
        function fitSplines(W)
            % fit a smooth surface to the meaured Azimuth and elevation as
            % a function of x and y pixels
            xnodes=unique(W.xListPix);
            ynodes=unique(W.yListPix);
            [W.aGrid,W.xGrid,W.yGrid] = gridfit(W.xListPix,W.yListPix,W.aListDeg,xnodes,ynodes, ...
                'smooth',5, 'interp','bilinear',  'solver','\', ...
                'regularizer','gradient', 'extend','warning', 'tilesize',inf);
            [W.eGrid] = gridfit(W.xListPix,W.yListPix,W.eListDeg,xnodes,ynodes, ...
                'smooth',5, 'interp','bilinear',  'solver','\', ...
                'regularizer','gradient', 'extend','warning', 'tilesize',inf);
        end
    end
end
