
function DPXD=lkDpxTuningExpPopAnalysis(DPXD,varargin)
    
    % The DXPD input to this function is created by lkDpxTuningExpAnalysis
    % Looks like this (2016-03-14)
    % DPXD
    %      motType: {1x1306 cell}
    %       dirDeg: {1x1306 cell}
    %      allDFoF: {1x1306 cell}
    %     meanDFoF: {1x1306 cell}
    %       sdDFoF: {1x1306 cell}
    %        nDFoF: {1x1306 cell}
    %            N: 1306
    %         file: {1x1306 cell}
    %   cellNumber: [1x1306 double]
    %   fileCellId: [1x1306 double]
    
    p=inputParser;
    p.addRequired('DPXD',@(x)dpxdIs(x,'verbosity',1) || isempty(x));
    p.addParamValue('figName',mfilename,@(x)ischar(x) || isempty(x));
    p.addParamValue('plot','meancurves',@(x)ischar(x) && ~isempty(strfind('rayleighp meancurves allcurves dirscat dirhist',lower(x))));
    p.addParamValue('rayleighPmax',.5,@isnumeric);
    p.addParamValue('shuffle',false,@(x)logical(x) || x==1 || x==0);
    p.addParamValue('alignTo','PHI',@(x)any(strcmpi(x,{'phi','ihp'})));
    p.parse(DPXD,varargin{:});
    
    if ~isempty(p.Results.figName)
        dpxFindFig(p.Results.figName);
        clf;
    end
    
    hack=true;
    if all(strcmpi('grating',unique(DPXD.motType)))
        dpxDispFancy('Grating experiment detected. Applying hack (double data, call half PHI other half IHP)',' !HACKALERT! ');
    elseif all(strcmpi(unique(DPXD.motType),'phi'))
        dpxDispFancy('Phi-only RDK experiment detected. Applying hack (double data, call half PHI other half IHP)',' !HACKALERT! ');
    else
        hack=false;
    end
    if hack
        DPXDphi=DPXD;
        DPXDphi.motType=repmat({'phi'},1,DPXDphi.N);
        DPXDihp=DPXD;
        DPXDihp.motType=repmat({'ihp'},1,DPXDihp.N);
        DPXD=dpxdMerge([DPXDphi DPXDihp]);
    end
    
    DPXD=calcRayleighPValues(DPXD);
    if strfind(lower(p.Results.plot),'rayleighp');
        plotRayleighP(DPXD,p.Results.rayleighPmax);
        return; % can plot EITHER rayleigh p values histogram OR curves
    end
    DPXD=selectTunedCells(DPXD,p.Results.rayleighPmax);
    if DPXD.N==0
       	 disp(sprintf('No cells have Rayleigh-P below %.2f for *both* PHI and IHP. Can''t continue',p.Results.rayleighPmax));
         return;
    end
    DPXD=alignTuningCurves(DPXD,p);
    M=dpxdSplit(DPXD,'motType');
    if strfind(lower(p.Results.plot),'dirhist')
        dx=cos(M{1}.prefDeg)-cos(M{2}.prefDeg);
        dy=sin(M{1}.prefDeg)-sin(M{2}.prefDeg);
        dAngles=atan2d(dy,dx);
        hist(dAngles,50);
        dpxLabel('x','Angle between PHIpref and IHPpref (deg)','y','# Cells');
        return;
    elseif strfind(lower(p.Results.plot),'curves')
        for mi=1:numel(M)
            if strcmpi(M{mi}.motType,'PHI')
                RGB=[0 0 1];
            elseif strcmpi(M{mi}.motType,'IHP')
                RGB=[1 0 0];
            else
                error('Unknown mottype!!');
            end
            
            if strfind(lower(p.Results.plot),'allcurves')
                for i=1:M{mi}.N
                    plot(M{mi}.alignedDirDeg{i},M{mi}.alignedDFoF{i},'-','Color',[RGB .1]);
                    hold on
                end
            end
            if strfind(lower(p.Results.plot),'meancurves')
                T=reshape([M{mi}.alignedDFoF{:}],numel(M{1}.alignedDFoF{1}),[])';
                h(mi)=plot(M{mi}.alignedDirDeg{1},mean(T,1),'-','Color',RGB,'LineWidth',2); %#ok<AGROW>
                lineLabels{mi}=upper(M{mi}.motType{1}); %#ok<AGROW>
                hold on
            end
        end
        if strfind(lower(p.Results.plot),'meancurves')
            legend(h,lineLabels);
            xlabel('Motion direction (deg)');
            ylabel('dF/F');
        end
    end
end

function DPXD=alignTuningCurves(DPXD,p)
    C=dpxdSplit(DPXD,{'cellNumber','file'});
    for ci=1:numel(C)
        [PHI,IHP]=dpxdSubset(C{ci},strcmpi('PHI',C{ci}.motType));
        degs=PHI.dirDeg{1}; % same for phi and ihp
        phiResp=PHI.meanDFoF{1};
        ihpResp=IHP.meanDFoF{1};
        if p.Results.shuffle
            phiResp=phiResp(randperm(numel(phiResp)));
            ihpResp=ihpResp(randperm(numel(ihpResp)));
        end
        if strcmpi(p.Results.alignTo,'PHI')
            [PHI.alignedDirDeg{1},PHI.alignedDFoF{1},PHI.prefDeg]=dpxTuningCurveAlign(degs,phiResp,[],1,'spline'); % align PHI
            [IHP.alignedDirDeg{1},IHP.alignedDFoF{1}]=dpxTuningCurveAlign(degs,ihpResp,PHI.prefDeg,1,'spline'); % align IHP as PHI
            [~,~,IHP.prefDeg]=dpxTuningCurveAlign(degs,ihpResp,[],1,'spline');
        else
            [IHP.alignedDirDeg{1},IHP.alignedDFoF{1},IHP.prefDeg]=dpxTuningCurveAlign(degs,ihpResp,[],1,'spline'); % align IHP
            [PHI.alignedDirDeg{1},PHI.alignedDFoF{1}]=dpxTuningCurveAlign(degs,phiResp,IHP.prefDeg,1,'spline'); % align PHI as IHP 
            [~,~,PHI.prefDeg]=dpxTuningCurveAlign(degs,phiResp,[],1,'spline');
        end  
        C{ci}=dpxdMerge({PHI,IHP});
    end
    DPXD=dpxdMerge(C);
end

function DPXD=calcRayleighPValues(DPXD)
    DPXD.circmean=nan(1,DPXD.N);
    DPXD.rayleighPValue=nan(1,DPXD.N);
    DPXD.alignedDFoF=cell(1,DPXD.N);
    for i=1:DPXD.N
        w=DPXD.allDFoF{i};
        nRepeats=size(w,1);
        w=reshape(w',1,[]);
        alpha=repmat(DPXD.dirDeg{i}/180*pi,1,nRepeats);
        tmpc=circular(alpha,w,'rad');
        [DPXD.circmean(i),~,~,~,~,DPXD.rayleighPValue(i)]=mstd(tmpc);
    end
end

function DPXD=selectTunedCells(DPXD,pMax)
    C=dpxdSplit(DPXD,{'cellNumber','file'});
    ok=false(size(C));
    for ci=1:numel(C)
        ok(ci)=all(C{ci}.rayleighPValue<=pMax);
    end
    C(~ok)=[];
    if numel(C)>0
        DPXD=dpxdMerge(C); 
    else
        DPXD=dpxdNull;
    end
end

function plotRayleighP(DPXD,pMax)
    M=dpxdSplit(DPXD,'motType');
    for mi=1:numel(M)
        if strcmpi(M{mi}.motType,'PHI')
            RGB=[0 0 1];
            barOffset=-.01;
        elseif strcmpi(M{mi}.motType,'IHP')
            RGB=[1 0 0];
            barOffset=.01;            
        else
            error('Unknown mottype!!');
        end
        nBins=10;
        edges=0:1/nBins:1;
        N=histc(M{mi}.rayleighPValue,edges);
        bar(edges+.5/nBins+barOffset,N,1/3,'FaceColor',RGB);
        hold on;
        dpxXaxis(0,1);
        dpxPlotVert(pMax,'g--','LineWidth',3);
    end
end
