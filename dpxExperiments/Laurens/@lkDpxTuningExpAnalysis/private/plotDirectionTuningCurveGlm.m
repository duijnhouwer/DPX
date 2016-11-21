function plotDirectionTuningCurveGlm(TC,varargin)
    
    p=inputParser;
    p.addParamValue('bayesfit',false,@islogical);
    p.parse(varargin{:});
    %
    colors={[1 0 0],[0 0 1],[0 1 0],[1 0 1],[1 1 0],[0 1 1]};
    %%%
    subplot(2,2,1);
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
            Y=TC{ss}.B{mti};
            E=TC{ss}.Bse{mti};
            if p.Results.bayesfit
                error('not implemented for GLM');
            else
                h(mti)=errorbar(X+xoffset,Y,E,'Marker',marker,'LineStyle',lStyle,'Color',color,'MarkerFaceColor','none','LineWidth',LW); %#ok<AGROW>
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
    ylabel('Beta');
    set(gca,'XTick',X);
    set(gca,'Xlim',[min(X) max(X)]);
    legend(h,TC{ss}.motType);
    
    %%%
    subplot(2,2,2)
    testedDelays=TC{1}.GlmFvaluePerDelay{1}(:,1);
    Fvalues=TC{1}.GlmFvaluePerDelay{1}(:,2);
    plot(testedDelays,Fvalues,'b-');
    cpsRefLine('|',TC{1}.bestDelay{1});
    str={['Optimal delay = ' num2str(TC{1}.bestDelay{1})]};
    str{end+1}=['pFull = ' num2str(TC{1}.GlmFullPvalue{1},'%.4f')];
    str{end+1}=['pOnOff = ' num2str(TC{1}.GlmOnOffPvalue{1},'%.4f')];
    str{end+1}=['pFullVsOnOff = ' num2str(TC{1}.FullVsOnOffPvalue{1},'%.4f')];
    cpsText(str);
    xlabel('Tested delay (s)');
    ylabel('GLM-Fvalue');
    
    %%%
    subplot(2,2,[3 4]);
    time=TC{1}.dFoF{1}(:,1)-TC{1}.dFoF{1}(1,1);
    plot(time,TC{1}.dFoF{1}(:,2),'k');
    hold on
    plot(time,TC{1}.dFoF{1}(:,3),'r');
    axis tight;
    xlabel('Time (s)');
    ylabel('dFoF');
    cpsText(['R2 = ' num2str(TC{1}.rSq{1})],'Color','r');
    [~,fname]=fileparts(TC{1}.file{1}); % drop path, too long
    fname(fname=='_')='-';
    title(fname);

%     titStr=[fname ' c' num2str(TC{1}.cellNumber(1),'%.3d')];
%     title(titStr,'Interpreter','none');
end