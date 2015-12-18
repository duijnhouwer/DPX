
function lkDpxTuningExpPopAnalysis(DPXD)
    
    if nargin==0
        DPXD=dpxdLoad('C:\Users\jacob\Downloads\lkDpxTuningExpAnalysis_output 20151012xyt02.mat');
    end
    if ~dpxdIs(DPXD,'verbosity',1)
        error('Input should be a valid DPXD');
    end
    DPXD=alignTuningCurves(DPXD); %%%% WRONG!!! NEEDS TO CO-ALIGN!~!!
    dpxFindFig(mfilename)
    C=dpxdSplit(DPXD,'motType');
    for ci=1:numel(C)
        if strcmpi(C{ci}.motType,'PHI')
            RGB=[0 0 1];cf
        elseif strcmpi(C{ci}.motType,'IHP')
            RGB=[1 0 0];
        else
            error('Unknown mottype!!');
        end
        for i=1:C{ci}.N
            plot(C{ci}.alignedDirDeg{i},C{ci}.alignedDFoF{i},'-','Color',[RGB .1]);
            hold on
        end
        T=reshape([C{ci}.alignedDFoF{:}],C{ci}.N,[]);
        plot(C{ci}.alignedDirDeg{1},mean(T,1),'r-','LineWidth',2);
    end
end

function DPXD=alignTuningCurves(DPXD)
    DPXD.circmean=nan(1,DPXD.N);
    DPXD.rayleighPValue=nan(1,DPXD.N);
    DPXD.alignedDFoF=cell(1,DPXD.N);
    for i=1:DPXD.N
        w=DPXD.allDFoF{i};
        nRepeats=size(w,1);
        w=reshape(w',1,[]);
        alpha=repmat(DPXD.dirDeg{i}/180*pi,1,nRepeats);
        tmpc=circular(alpha,w,'rad');
        %[mPhi,mR,meanC,mConf,mS,p] = mstd(c,alpha)
        
        [DPXD.circmean(i),~,~,~,~,DPXD.rayleighPValue(i)]=mstd(tmpc);
        [DPXD.alignedDirDeg{i},DPXD.alignedDFoF{i}]=jdTuningCurveAlign(DPXD.dirDeg{i},DPXD.meanDFoF{i},[],1,'spline');
    end
    
end
