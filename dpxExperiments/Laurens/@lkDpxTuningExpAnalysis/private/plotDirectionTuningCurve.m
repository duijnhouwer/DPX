function plotDirectionTuningCurve(TC,varargin)
    
    p=inputParser;
    p.addParamValue('bayesfit',false,@islogical);
    p.parse(varargin{:});
    %
    colors={[0 0 1],[1 0 0],[0 1 0],[1 0 1],[1 1 0],[0 1 1]};
    for ss=[2:numel(TC) 1] % SubSets of the data, 1 is always all data, plot that last (--> on top, and legend correct)
        for mti=1:TC{ss}.N  
            color=colors{mod(mti-1,numel(colors))+1};
            if ss==1 && numel(TC)==1
                marker='none';
                lStyle='-';
                color(4)=1;
                LW=1;
                xoffset=0;
            elseif ss==1
                marker='o';
                lStyle='-';
                color(4)=1;
                LW=3;
                xoffset=0;
            else
                marker='s';
                lStyle='-';
                color(4)=0.5/ss;
                LW=1;
                xoffset=(ss-1)*2;
            end
            X=TC{ss}.dirDeg{mti};
            Y=TC{ss}.meanDFoF{mti};
            E=TC{ss}.sdDFoF{mti}./sqrt(TC{ss}.nDFoF{mti}); % standard error of the mean
            if p.Results.bayesfit
                errorbar(X+xoffset,Y,E,'Marker',marker,'LineStyle','none','Color',color,'MarkerFaceColor','none','LineWidth',LW);
                hold on
                curveName=TC{ss}.dpxBayesPhysV1{mti};
                curveName(curveName=='_')=' ';
                if ss==1
                    dpxText(curveName,'Color',color);
                end
                fitx=TC{ss}.dpxBayesPhysV1x{mti};
                fity=TC{ss}.dpxBayesPhysV1y{mti};
                h(mti)=plot(fitx,fity,'-','Color',color,'MarkerFaceColor','none','LineWidth',LW);
                if ss>1 && numel(TC)>1
                    text(fitx(end)+xoffset+3,fity(end),num2str(ss-1),'Color',color);
                end
            else
                h(mti)=errorbar(X+xoffset,Y,E,'Marker',marker,'LineStyle',lStyle,'Color',color,'MarkerFaceColor','none','LineWidth',LW);
                hold on
                if ss==1 % all data, not a subset
                    if numel(X)==2 % a two-dir only experiemnt, do a t-test
                        yy=TC{ss}.allDFoF{mti};
                        [~,pValue,~,stats] = ttest(yy(:,1),yy(:,2));
                        tStr=['T = ' num2str(stats.tstat,'%.2f')];
                        dfStr=['df = ' num2str(stats.df,'%d')];
                        pStr=['p = ' num2str(pValue,'%.2f')];
                        if pValue<0.05
                            pStr=[pStr ' *'];
                        end
                        if mti==1
                            xPos=.25; yPos=.75;
                        elseif mti==2
                            xPos=.75; yPos=.25;
                        else
                            error('mti out of exptected range');
                        end
                        dpxText({tStr,dfStr,pStr},'location','free','xgain',xPos,'ygain',yPos,'Color',color,'FontSize',10);
                    end
                end
                if ss>1 && numel(TC)>1
                    text(X(end)+xoffset+3,Y(end),num2str(ss-1),'Color',color);
                end
            end
            
        end
    end
    xlabel('Direction (deg)');
    ylabel('mean dFoF');
    set(gca,'XTick',X);
    legend(h,TC{ss}.motType);
    [~,fname]=fileparts(TC{1}.file{1}); % drop path, too long
    titStr=[fname ' c' num2str(TC{1}.cellNumber(1),'%.3d')];
    title(titStr,'Interpreter','none');
end