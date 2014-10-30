classdef dpxToolsHalfDomeWarp < hgsetget
    
    properties (Access='public')
        filename;
        winRectPx=[0 0 600 400];
        xListPix=[];
        yListPix=[];
        stepsPerDeg;
        pixelStep;
        LUT;
        nDone; % number of points already measured
        eListDeg=[];
        aListDeg=[];
    end
    properties (GetAccess='public', SetAccess='protected')

    end
    properties (GetAccess='private')
        aGrid=[];
        eGrid=[];
        xGrid=[];
        yGrid=[];
    end
    methods (Access='public')
        function W=dpxToolsHalfDomeWarp
            % W=dpxToolsHalfDomeWarp
            % Part of the DPX toolkit
            % http://tinyurl.com/dpxlink
            % Jacob Duijnhouwer, 2014-10-10
            %
            % This tool can be used to create lookup tables for warping
            % display matrices, for example for use in half-dome projection
            % set-ups.
            %
            % See also: jdDpxExpHalfDomeRdk
            W.filename=fullfile(pwd,'dpxToolsHalfDomeWarp.mat');
            W.winRectPx=[30 30 600 400];
            W.xListPix=0:W.winRectPx(3)/10:W.winRectPx(3);
            W.yListPix=0:W.winRectPx(4)/8:W.winRectPx(4);
            W.LUT=struct('minA',[],'minE',[],'table',[]);
            W.stepsPerDeg=10;
            W.pixelStep=0.2;
            W.nDone=0;
        end
        function calibrate(W)
            if numel(W.xListPix)==0 || numel(W.yListPix)==0
                error('No X and/or Y screen coordinates provided (set xListPix and yListPix)');
            end
            S=dpxCoreWindow;
            set(S,'winRectPx',W.winRectPx);
            S.open;
            nTogo=numel(W.xListPix)*numel(W.yListPix);
            if W.nDone==0
                input('<< Press ENTER to start calibrating >>');
            else
                input('<< Press ENTER to continue calibrating >>');
            end
            [x,y]=meshgrid(W.xListPix,W.yListPix);
            x=x(:);
            y=y(:);
            while W.nDone<numel(x)
                W.nDone=W.nDone+1;
                Screen('DrawDots',S.windowPtr,xy(W.nDone,:),5,[255 255 255]);
                Screen('Flip',S.windowPtr);
                azi=[];
                ele=[];
                while isempty(azi)
                    disp(['Point Nr ' num2str(W.nDone) ' / ' num2str(nTogo) ': [x,y]=[' num2str(x(W.nDone)) ',' num2str(y(W.nDone)) ']']);
                       disp('       Type NaN if the point is invisible, Inf to re-do previous point, CTRL+C to quit.');
                    s=input('   --> AZIMUTH in deg? > ','s');
                    azi=str2num(s); %#ok<*ST2NM>
                end
                if isnan(azi) || isinf(azi)
                    ele=nan;
                else
                    while isempty(ele)
                        s=input('   --> ELEVATION in deg? > ','s');
                        ele=str2num(s);
                    end
                end
                if isinf(azi)
                    W.nDone=max(0,W.nDone-2);
                else
                    W.aListDeg(W.nDone)=azi;
                    W.eListDeg(W.nDone)=ele;
                    save(W.filename,'W');
                    disp(['       Saved: ' W.filename]);
                end
            end
        end
        function plot(W)
            [x,y]=meshgrid(W.xListPix,W.yListPix);
            W.fitSplines;
            dpxFindFig(mfilename)
            subplot 121
            plot3(x(:),y(:),W.aListDeg,'ko','MarkerFaceColor','k');
            hold on;
            box on;
            dpxLabel('x','X (pix)','y','Y (pix)','z','Azi (deg)');
            hold on
            surfl(W.xGrid,W.yGrid,W.aGrid);
            subplot 122
            plot3(x(:),y(:),W.eListDeg,'ko','MarkerFaceColor','k');
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
            W.LUT.table=[];
            W.LUT.minA=min(A(:));
            W.LUT.minE=min(E(:));
            % iterate over all X and T pixels withing the rectangle of the
            % minimum X and Y and the maximum X and Y for which an azi and
            % ele could be measured PLUS a 100 pixel extrapolation margin.
            xx=min(X(:)):W.pixelStep:max(X(:));
            yy=min(Y(:)):W.pixelStep:max(Y(:));
            startSec=-Inf;
            for i=1:numel(xx)
                ei=interp2(X,Y,E,xx(i),yy);
                ai=interp2(X,Y,A,xx(i),yy);
                ei=1+floor(ei-W.LUT.minE);
                ai=1+floor(ai-W.LUT.minA);
                for j=1:numel(yy)
                    % Note: ele in rows, azi in columns!
                    W.LUT.table(ei(j),ai(j),1)=xx(i);
                    W.LUT.table(ei(j),ai(j),2)=yy(j);
                end
                if GetSecs-startSec>10
                    if showplot, W.plotLut; end
                    startSec=GetSecs;
                end
            end
            plotLut(W);
            dpxDispFancy('Inspect the LUTs. If there are any gaps or specs within the central areas, decrease ''pixelStep'''' and re-run ''makeLut''.');
            % Cast LUT to 2 byte integer format (pixels), This reduce
            % filesize (and load time) by a factor 4
            W.LUT.table=uint16(W.LUT.table);
        end
        function plotLut(W)
            if isempty(W.LUT.table)
                disp('Lookup table does not exist. Generate it using ''''makeLut''');
                return;
            end
            dpxFindFig('Lookup table');
            clf; % important, MUST remove Ticks!
            subplot 121
            imagesc(W.LUT.table(:,:,1));
            title('X pixels');
            dpxLabel('x','azi (deg)','y','ele (deg)');
            set(gca,'XTickLabel',round(get(gca,'XTick')+W.LUT.minA)/W.stepsPerDeg);
            set(gca,'YTickLabel',round(get(gca,'YTick')+W.LUT.minE)/W.stepsPerDeg);
            colorbar('NorthOutside');
            subplot 122
            imagesc(W.LUT.table(:,:,2));
            title('Y pixels');
            dpxLabel('x','azi (deg)','y','ele (deg)');
            set(gca,'XTickLabel',round(get(gca,'XTick')+W.LUT.minA)/W.stepsPerDeg);
            set(gca,'YTickLabel',round(get(gca,'YTick')+W.LUT.minE)/W.stepsPerDeg);
            colorbar('NorthOutside');
            drawnow
        end
        function [xy, visibleIdx]=getXYpix(W,aziDeg,eleDeg)
            % XY will be a matrix with nDots-columns, 1st row X, 2nd row Y,
            % regardless of the orientation of the input vector aziDeg and
            % eleDeg;
            visibleIdx=1:numel(aziDeg);
            ai=1+floor(aziDeg*W.stepsPerDeg-W.LUT.minA);
            ei=1+floor(eleDeg*W.stepsPerDeg-W.LUT.minE);
            ai=ai(:);
            ei=ei(:);
            ok=ai>=1 & ai<=size(W.LUT.table,2) & ei>=1 & ei<=size(W.LUT.table,1);% Note: ele in rows, azi in columns!
            ai=ai(ok);
            ei=ei(ok);
            visibleIdx=visibleIdx(ok);
            x=W.LUT.table(sub2ind(size(W.LUT.table),ei,ai,ones(size(ai))*1));% Note: ele in rows, azi in columns!
            y=W.LUT.table(sub2ind(size(W.LUT.table),ei,ai,ones(size(ai))*2));% Note: ele in rows, azi in columns!
            ok=x>0 & y>0;
            x=x(ok);
            y=y(ok);
            visibleIdx=visibleIdx(ok);
            xy=[x(:) y(:)]';
            xy=double(xy); % cast back to double data type
        end
        function createMaskTiff(W,filename)
            if nargin==1, filename=''; end
            wid=W.winRectPx(3)-W.winRectPx(1);
            hei=W.winRectPx(4)-W.winRectPx(2);
            M=zeros(wid,hei);
            tel=0;
            for i=1:numel(W.xListPix)
                for j=1:numel(W.yListPix)
                    tel=tel+1;
                    if ~isnan(W.aListDeg(tel))
                        M(W.xListPix(i),W.yListPix(j))=1;
                    end
                end
            end
            if isempty(filename)
                [fl,pth]=uiputfile('dpxToolsHalfDomeWarp_automask.tif','Save mask as ...');
                filename=fullfile(pth,fl);
            end
            imwrite(M',filename); % note tranpose '
            if IsWin
                system(['mspaint ' filename])
            end
        end
    end
    methods (Access='protected')
        function fitSplines(W)
            % fit a smooth surface to the meaured Azimuth and elevation as
            % a function of x and y pixels. Only fit over the rectangular X
            % and Y area where dots were visible + N pixels extrapolation
            [X,Y]=meshgrid(W.xListPix,W.yListPix);
            visible=~isnan(W.aListDeg);
            X=X(visible);
            Y=Y(visible);
            A=W.aListDeg(visible);
            E=W.eListDeg(visible);
            xNodes=unique(X);
            yNodes=unique(Y);
            [W.aGrid,W.xGrid,W.yGrid] = gridfit(X,Y,A,xNodes,yNodes, ...
                'smooth',5, 'interp','bilinear',  'solver','\', ...
                'regularizer','gradient', 'extend','warning', 'tilesize',inf);
            [W.eGrid] = gridfit(X,Y,E,xNodes,yNodes, ...
                'smooth',5, 'interp','bilinear',  'solver','\', ...
                'regularizer','gradient', 'extend','warning', 'tilesize',inf);
        end
    end
    methods
        function set.filename(W,value)
            if isempty(value)
                defaultSaveName=[mfilename 'Object' datestr(now,'YYYYmmDDHHMMSS') '.mat'];
                [flnm, pth] = uiputfile(defaultSaveName, 'Save dpxToolsHalfDomeWarp object as');
                W.filename=fullfile(pth,flnm);
            elseif ischar(value)
                W.filename=value; % should do some checking of filename validity here ...
            else
                error('Filename should be string (filename) or be empty (i.e., [], to trigger save-as dialog)');
            end
        end
    end
end

