function jdDpxExpTmpRecruitAnalysis(DPXD)
    
    if nargin==0
        dataFolder='U:\Project Temporal Recruitment\data';
        files=jdGetFiles(dataFolder);
        for i=1:numel(files)
            fname=fullfile(dataFolder,files(i).name);
            DPXD{i}=simplify(dpxdLoad(fname));
        end
        DPXD=dpxdMerge(DPXD);
    else
        DPXD=simplify(DPXD);
    end
    
    CRVS=getPsychoCurves(DPXD);
    CRVS=addPsigniFits(CRVS);
    plotPsychoCurves(CRVS);
    plotBetaCurves(CRVS);
end

function DPXD=simplify(DPXD)
    % Facilitate analysis by making fields for main treatments
    tag=DPXD.treatment_str;
    tag=[tag{:}];
    DPXD.motionType=tag(1:3:end);
    tag(1:3:end)=[];
    DPXD.motionSteps=str2num(tag); %#ok<ST2NM>
    DPXD.motionCoherence=DPXD.component01_cohereFrac;
    % Remove unneeded fields
    DPXD=rmfield(DPXD,dpxdFilterFieldnames(DPXD,'component'));
    DPXD=rmfield(DPXD,dpxdFilterFieldnames(DPXD,'treatment'));
    DPXD=rmfield(DPXD,dpxdFilterFieldnames(DPXD,'fixcross'));
    % Check still an DPXD
    if ~dpxdIs(DPXD)
        error('not a DPXD anymore');
    end
end

function CRVS=getPsychoCurves(DPXD)
    DPXD=dpxdSplit(DPXD,{'exp_subjectId','motionType','motionCoherence','motionSteps'});
    CRVS.subject=cell(size(DPXD));
    CRVS.motionType=char(size(DPXD));
    CRVS.motionSteps=nan(size(DPXD));
    CRVS.coherence=nan(size(DPXD));
    CRVS.rightward=nan(size(DPXD));
    CRVS.N=numel(DPXD);
    for i=1:numel(DPXD)
        CRVS.subject{i}=unique([DPXD{i}.exp_subjectId{:}]);
        CRVS.motionType(i)=unique(DPXD{i}.motionType);
        CRVS.motionSteps(i)=unique(DPXD{i}.motionSteps);
        CRVS.coherence(i)=unique(DPXD{i}.motionCoherence);
        CRVS.rightward(i)=jdProp(strcmpi(DPXD{i}.resp_kb_keyName,'RightArrow'));
        CRVS.respNum(i)=numel(DPXD{i}.resp_kb_keyName);
    end
    CRVS=toCurves(CRVS);
    function CRVS=toCurves(D)
        tel=0;
        D=dpxdSplit(D,'subject');
        for si=1:numel(D)
            T=dpxdSplit(D{si},'motionType');
            for ti=1:numel(T)
                N=dpxdSplit(T{ti},'motionSteps');
                for ni=1:numel(N)
                    tel=tel+1;
                    CRVS.subject(tel)=N{ni}.subject(1);
                    CRVS.motionType(tel)=N{ni}.motionType(1);
                    CRVS.motionSteps(tel)=N{ni}.motionSteps(1);
                    CRVS.coherence{tel}=N{ni}.coherence;
                    CRVS.rightward{tel}=N{ni}.rightward;
                    CRVS.respNum{tel}=N{ni}.respNum;
                end
            end
        end
        CRVS.N=tel;
    end
end

function CRVS=addPsigniFits(CRVS)
    disp('addPsigniFits');
    for i=1:CRVS.N
        P=dpxPsignifit;
        P.X=CRVS.coherence{i};
        P.Y=CRVS.rightward{i};
        P.N=CRVS.respNum{i};
        P.verbose=false;
        P.nBootstraps=100
        P.doFit;
        CRVS.pFit(i)=P;
        CRVS.beta(i)=P.fit.params.est(2);
        %CRVS.beta95ci(:,i)=P.fit.params.lims([1 4],2);
    end
end
    
function plotPsychoCurves(CRVS)
    disp('plotPsychoCurves')
    cpsFindFig('plotPsychoCurves');
    CRVS=dpxdSplit(CRVS,'subject');
    nRows=numel(CRVS);
    for si=1:nRows
        T=dpxdSplit(CRVS{si},'motionType');
        for ti=1:numel(T)
            subplot(nRows,numel(T),ti);
            N=dpxdSplit(T{ti},'motionSteps');
            for ni=1:numel(N)
                color=jdTern(ti==1,[.1 .1 1],[1 .1 .1]);
                color=brighten(color,1-(ni/numel(N))*.9);
                %(N{ni}.coherence{1},N{ni}.rightward{1},'-','LineWidth',2,'Color',gray);
                N{ni}.pFit.plotdata('Color',color,'LineWidth',1.5); hold on;
                N{ni}.pFit.plotfit('Color',color,'LineWidth',1.5);
                hold on;
                xlabel('Coherence');
                ylabel('"Rightward"');
                title(N{ni}.motionType(1));
            end
        end
    end
end

function plotBetaCurves(CRVS)
    disp('plotBetaCurves')
    cpsFindFig('plotBetaCurves');
    CRVS=dpxdSplit(CRVS,'motionType');
    cols='br';
    for i=1:numel(CRVS)
        S=dpxdSplit(CRVS{i},'subject');
        betas=CRVS{i}.beta;
        nSteps=CRVS{i}.motionSteps;
        for si=2:numel(S)
            betas=[betas; CRVS{si}.beta];
            nSteps=[nSteps; CRVS{si}.motionSteps];
        end
        err=std(betas,[],1)./sqrt(size(betas,1));
        h(i)=errorbar(mean(nSteps,1),mean(betas,1),err,err);
        set(h(i),'Color',cols(i),'LineWidth',1.5);
        hTag{i}=CRVS{i}.motionType(1);
        hold on
    end
    legend(h,hTag);
    xlabel('# Motion steps');
    ylabel('Steepness');
    
end
    
   
