
function DPXD=lkDpxTuningExpPopAnalysis(DPXD,varargin)
    
    p=inputParser;
    p.addRequired('DPXD',@(x)dpxdIs(x,'verbosity',1) || isempty(x));
    p.addParamValue('figName',mfilename,@(x)ischar(x) || isempty(x));
    p.addParamValue('plotCurves',false,@(x)logical(x) || x==1 || x==0);
    p.addParamValue('plotMean',true,@(x)logical(x) || x==1 || x==0);
    p.addParamValue('plotRayleighP',false,@(x)logical(x) || x==1 || x==0);
    p.addParamValue('rayleighPmax',1,@isnumeric);
    p.addParamValue('randomize',false,@(x)logical(x) || x==1 || x==0);
    p.addParamValue('alignTo','PHI',@(x)any(strcmpi(x,{'phi','ihp'})));
    p.parse(DPXD,varargin{:});
    
    if ~isempty(p.Results.figName)
        dpxFindFig(p.Results.figName);
        clf;
    end
    
    DPXD=calcRayleighPValues(DPXD);
    if p.Results.plotRayleighP
        plotRayleighP(DPXD,p.Results.rayleighPmax);
        return; % can plot EITHER rayleigh p values histogram OR curves
    end
    DPXD=selectTunedCells(DPXD,p.Results.rayleighPmax);
    DPXD=alignTuningCurves(DPXD,p);
    M=dpxdSplit(DPXD,'motType');
    for mi=1:numel(M)
        if strcmpi(M{mi}.motType,'PHI')
            RGB=[0 0 1];
        elseif strcmpi(M{mi}.motType,'IHP')
            RGB=[1 0 0];
        else
            error('Unknown mottype!!');
        end
        if p.Results.plotCurves
            for i=1:M{mi}.N
                plot(M{mi}.alignedDirDeg{i},M{mi}.alignedDFoF{i},'-','Color',[RGB .1]);
                hold on
            end
        end
        if p.Results.plotMean
            T=reshape([M{mi}.alignedDFoF{:}],numel(M{1}.alignedDFoF{1}),[])';
            h(mi)=plot(M{mi}.alignedDirDeg{1},mean(T,1),'-','Color',RGB,'LineWidth',2);
            lineLabels{mi}=upper(M{mi}.motType{1});
            hold on
        end
    end
    if p.Results.plotMean
        legend(h,lineLabels);
        xlabel('Motion direction (deg)');
        ylabel('dF/F');
    end
end

function DPXD=alignTuningCurves(DPXD,p)
    C=dpxdSplit(DPXD,'cellNumber');
    for ci=1:numel(C)
        PHI=dpxdSubset(C{ci},strcmpi('PHI',C{ci}.motType));
        IHP=dpxdSubset(C{ci},strcmpi('IHP',C{ci}.motType));
        degs=PHI.dirDeg{1}; % same for phi and ihp
        phiResp=PHI.meanDFoF{1};
        ihpResp=IHP.meanDFoF{1};
        if p.Results.randomize
            phiResp=phiResp(randperm(numel(phiResp)));
            ihpResp=ihpResp(randperm(numel(ihpResp)));
        end
        if strcmpi(p.Results.alignTo,'PHI')
            [PHI.alignedDirDeg{1},PHI.alignedDFoF{1},angle]=dpxTuningCurveAlign(degs,phiResp,[],1,'spline');
            [IHP.alignedDirDeg{1},IHP.alignedDFoF{1}]=dpxTuningCurveAlign(degs,ihpResp,angle,1,'spline');
        else
            [IHP.alignedDirDeg{1},IHP.alignedDFoF{1},angle]=dpxTuningCurveAlign(degs,ihpResp,[],1,'spline');
            [PHI.alignedDirDeg{1},PHI.alignedDFoF{1}]=dpxTuningCurveAlign(degs,phiResp,angle,1,'spline');
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
    C=dpxdSplit(DPXD,'cellNumber');
    ok=false(size(C));
    for ci=1:numel(C)
        ok(ci)=all(C{ci}.rayleighPValue<=pMax);
    end
    C(~ok)=[];
    DPXD=dpxdMerge(C);
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
