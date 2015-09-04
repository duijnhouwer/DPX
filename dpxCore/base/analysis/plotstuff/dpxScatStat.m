function [out,h]=dpxScatStat(x,y,varargin)
    
    % function [out,h]=dpxScatStat(x,y,varargin)
    %
    % Perform signtest, signrank (default), or ttest on x,y and makes an
    % annotated scatter plot.
    % Optionally tests of the validity of the statistical method is
    % provided (notably Kolmogorov-Smirnov test for normality)
    % 
    % JD Jan-2012
    %
    % EXAMPLE 1:
    %   x=rand(1,20);
    %   y=rand(1,20)+1/3;
    %   dpxScatStat(x,y);
    %
    % EXAMPLE 2:
    %   xMo=randn(1,60);
    %   yMo=randn(1,60)+1/2;
    %   xYo=randn(1,40);
    %   yYo=randn(1,40)+1/3;
    %   monkey=[ones(size(xMo)) ones(size(xYo))*2]; 
    %   dpxScatStat([xMo xYo],[yMo yYo],'test','ttest','class',monkey,'classLabels',{'mo','yo'});
    %  
    
    p=inputParser;
    p.addParamValue('x',@isnumeric);
    p.addParamValue('y',@isnumeric);
    p.addParamValue('test','signrank',@(x)any(strcmp(x,{'signtest','signrank','ttest'}))); % note, Wilcoxon 'ranksum' test (aka Mann-Whitney U) is for independent, not paired, samples.
    p.addParamValue('plotopts',{'o','MarkerFaceColor','b','MarkerEdgeColor','w'},@iscell); % piped to 'plot' function for graphical options
    p.addParamValue('trick3d',false,@islogical); % if true, plot as a 3D cloud with Z dimension the index. View set to parallel the Z-axis. Useful to identify individual datum with the 'data cursor' tool
    p.addParamValue('axis',[],@(k)isempty(k)||isnumeric(k)&&numel(k)==4);
    p.addParamValue('class',ones(size(x)),@(k)isnumeric(k) && numel(k)==numel(x));
    p.addParamValue('classColors',{'b','r','g','c','m','k','y'},@iscell); % e.g. {'r','g'} or {[.5 .5 .5],[1 .5 0]}
    p.addParamValue('classSymbols','osdv^<>',@ischar); % e.g. 'os'
    p.addParamValue('classLabels',{'nolabel'},@iscell); % labels for in legend
    p.addParamValue('plotdiagnostics','',@ischar); % if a figure name is provided, tests for normality is performed. could use some work...
    p.addParamValue('annotate',true,@islogical);
    p.addParamValue('uglyforillustrator',false,@islogical);
    p.parse(varargin{:});
    
    
    if numel(x)~=numel(y)
        error(['['  mfilename '] Unequal number of x and y values']);
    elseif numel(x)==1
        warning(['['  mfilename '] only a single data pair provided, returning without doing anything']);
        return;
    end
    if numel(unique(p.Results.class))==1
        if p.Results.trick3d
            z=1:numel(x);
            h=plot3(x,y,z,p.Results.plotopts{:});
            view(0,90);
        else
            h=plot(x,y,p.Results.plotopts{:});
        end
        if ~isempty(p.Results.axis)
            axis(p.Results.axis);
        end
        dpxPlotUnityLine;
    else
        uClass=unique(p.Results.class);
        h=zeros(size(uClass));
        annot=cell(size(uClass));
        for i=1:numel(uClass)
            idx=p.Results.class==uClass(i);
            sym=p.Results.classSymbols(mod(i-1,numel(p.Results.classSymbols))+1);
            col=p.Results.classColors{mod(i-1,numel(p.Results.classColors))+1};
            if p.Results.trick3d
                z=1:numel(x);
                if p.Results.uglyforillustrator
                    h(i)=plot3(x(idx),y(idx),z(idx),'LineStyle','none','Marker',sym,'MarkerFaceColor','none','MarkerEdgeColor','c');
                    view(0,90);
                else
                    h(i)=plot3(x(idx),y(idx),z(idx),'LineStyle','none','Marker',sym,'MarkerFaceColor',col,'MarkerEdgeColor','w');
                    view(0,90);
                end
            else
                if p.Results.uglyforillustrator
                    h(i)=plot(x(idx),y(idx),'LineStyle','none','Marker',sym,'MarkerFaceColor','none','MarkerEdgeColor','c');
                else
                    h(i)=plot(x(idx),y(idx),'LineStyle','none','Marker',sym,'MarkerFaceColor',col,'MarkerEdgeColor','w');
                end
            end
            hold on
            % Do the test
            switch p.Results.test
                case 'signtest'
                    [out.pval(i),~,tmpstats]=signtest(x(idx),y(idx));
                    if ~isfield(tmpstats,'zval'), tmpstats.zval=nan; end
                    out.test='signtest';
                    out.stats(i)=orderfields(tmpstats);
                    out.n(i)=sum(idx);
                    out.class{i}=p.Results.classLabels{min(i,end)};
                    if isnan(out.stats(i).zval) % only returned for large n
                        annot{i}=sprintf('%s: n=%d; sign=%d; p=%.4f',out.class{i},out.n(i),out.stats(i).sign,out.pval(i));
                    else
                        annot{i}=sprintf('%s: n=%d; sign=%d; z=%.4f; p=%.4f',out.class{i},out.n(i),out.stats(i).sign,out.stats(i).zval,out.pval(i));
                    end
                case 'signrank'
                    [out.pval(i),~,tmpstats]=signrank(x(idx),y(idx));
                    if ~isfield(tmpstats,'zval'), tmpstats.zval=nan; end
                    out.test='signrank';
                    out.stats(i)=orderfields(tmpstats);
                    out.n(i)=sum(idx);
                    out.class{i}=p.Results.classLabels{min(i,end)};
                    if isnan(out.stats(i).zval) % only returned for large n
                        annot{i}=sprintf('%s: n=%d; signedrank=%d; p=%.4f',out.class{i},out.n(i),out.stats(i).signedrank,out.pval(i));
                    else
                        annot{i}=sprintf('%s: n=%d; signedrank=%d; z=%.4f; p=%.4f',out.class{i},out.n(i),out.stats(i).signedrank,out.stats(i).zval,out.pval(i));
                    end
                case 'ttest'
                    [~,out.pval(i),~,tmpstats]=ttest(x(idx),y(idx));
                    out.test='ttest';
                    out.stats(i)=orderfields(tmpstats);
                    out.n(i)=sum(idx);
                    out.class{i}=p.Results.classLabels{min(i,end)};
                    mnx=nanmean(x(idx));
                    mny=nanmean(y(idx));
                    sdx=nanstd(x(idx));
                    sdy=nanstd(y(idx));
                    annot{i}=sprintf('n=%d; means=[%.3f,%.3f]; sds=[%.3f,%.3f]; tstat=%.3f; df=%d, p=%.4f',out.n(i),mnx,mny,sdx,sdy,out.stats(i).tstat,out.stats(i).df,out.pval(i));
                otherwise
                    error(['['  mfilename '] Unknown test: ' p.Results.test]);
            end
            
        end
        if ~isempty(p.Results.axis)
            axis(p.Results.axis);
        end
        dpxPlotUnityLine;
        if p.Results.annotate
            legend(h,annot,'Location','Best');
        end
    end
    %
    % Statistic on all data (ignoring classes), always performed
    switch p.Results.test
        case 'signtest'
            [all.pval,~,all.stats]=signtest(x,y);
            all.n=numel(x);
            if p.Results.annotate
                if ~isfield(all.stats,'zval') % only returned for large n
                    dpxText(sprintf('n=%d; sign=%d; p=%.4f',all.n,all.stats.sign,all.pval));
                else
                    dpxText(sprintf('n=%d; sign=%d; z=%.4f; p=%.4f',all.n,all.stats.sign,all.stats.zval,all.pval));
                end
            end
            out.all=all;
        case 'signrank'
            [all.pval,~,all.stats]=signrank(x,y);
            all.n=numel(x);
            if p.Results.annotate
                if ~isfield(all.stats,'zval') % only returned for large n
                    dpxText(sprintf('n=%d; signrank=%d; p=%.4f',all.n,all.stats.signedrank,all.pval));
                else
                    dpxText(sprintf('n=%d; signrank=%d; z=%.4f; p=%.4f',all.n,all.stats.signedrank,all.stats.zval,all.pval));
                end
            end
            out.all=all;
        case 'ttest'
            [~,all.pval,~,all.stats]=ttest(x,y);
            all.n=numel(x);
            if p.Results.annotate
                mnx=nanmean(x);
                mny=nanmean(y);
                sdx=nanstd(x);
                sdy=nanstd(y);
                dpxText(sprintf('n=%d; mns=[%.3f %.3f]; sds=[%.3f %.3f];tstat=%.3f; df=%d, p=%.4f',all.n,mnx,mny,sdx,sdy,all.stats.tstat,all.stats.df,all.pval));
            end
        otherwise
            error(['['  mfilename '] Unknown test: ' p.Results.test]);
    end
    if numel(unique(p.Results.class))==1
        % use the 'all' level only if there are fields for the separate
        % classes too
        out=all;
    end
    
    %
    if ~isempty(p.Results.plotdiagnostics)
        % make a separate figure to help decide which test is most suitable
        currentfigwintit=get(gcf,'Name');
        % switch to diagnostics window
        dpxFindFig(p.Results.plotdiagnostics)
        %
        subplot 121
        ranks=sort(x-y-median(x-y));
        plot(abs(ranks));
        dpxXaxis(1,numel(x));
        dpxPlotVert((numel(x)+1)/2,'r');
        %
        %[pVal,H]=signtest(sort(abs(ranks(ranks<0))),sort(ranks(ranks>0)));
        means=nans(1,1000);
        medians=nans(1,1000);
        for bs=1:1000
            bsranks=ranks(randi(numel(ranks),1,numel(ranks)));
            means(bs)=mean(bsranks);
            medians(bs)=median(bsranks);
        end
        [pVal,H]=signtest(means,medians);
        if H==0
            dpxText(['H=0, p=' num2str(pVal) ': Symmetric']);
        else
            dpxText(['H=1, p=' num2str(pVal) ': NOT Symmetric']);
        end
        title('signrank requires symmetry around median');
        %
        subplot 122
        hist(x-y,floor(numel(x)/10))
        
        [H,pVal]=kstest(x-y-nanmean(x-y)); % jacob: kstest ignores nan values
        % [H,pVal]=vartest2(x,y);
        % if H==0
        %     dpxText(['Variances are equal. p=' num2str(pVal)]);
        % else
        %     dpxText(['Variances are NOT equal. p=' num2str(pVal)]);[
        % end
        
        if H==0
            dpxText(['KS test  p=' num2str(pVal) '--> NORMAL.']);
        else
            dpxText(['KS test  p=' num2str(pVal) '--> NOT-NORMAL.' ]);
        end
        
        title('paired t-test requires normality, and equal variance');
        % switch back to main window
        dpxFindFig(currentfigwintit);
    end
    
end
