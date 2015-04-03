function plotDirectionTuningCurve(TC,varargin)
    % TC is a tuningcurve DPXD made by calcDirectionTuningCurve of 1 or
    % more cells. i is the cell-number to be plot.
        
    % Parse 'options' input
    p=inputParser;
    p.addParamValue('bayesfit',true,@islogical);
    p.parse(varargin{:});
    
    keyboard
    
    for ss=[2:numel(TC) 1] % SubSets of the data, 1 is always all data
        if ss==1 && numel(TC)==1
            marker='none';
            lStyle='-';
            color='b';
            LW=1;
            xoffset=0;
        elseif ss==1
            marker='o';
            lStyle='-';
            color='b';
            LW=3;
            xoffset=0;
        else
            marker='s';
            lStyle='-';
            color=[1 1 1]/ss+.25;
            LW=1;
            xoffset=(ss-1)*2;
        end
        X=TC{ss}.dirDeg{1};
        Y=TC{ss}.meanDFoF{1};
        E=TC{ss}.sdDFoF{1}./sqrt(TC{ss}.nDFoF{1}); % standard error of the mean
        if p.Results.bayesfit
            errorbar(X+xoffset,Y,E,'Marker',marker,'LineStyle','none','Color',color,'MarkerFaceColor',color,'LineWidth',LW);
            hold on
            curveName=TC{ss}.dpxBayesPhysV1{1};
            curveName(curveName=='_')=' ';
            if ss==1
                dpxText(curveName,'Color',color);
            end
            fitx=TC{ss}.dpxBayesPhysV1x{1};
            fity=TC{ss}.dpxBayesPhysV1y{1};
            plot(fitx,fity,'-','Color',color,'MarkerFaceColor',color,'LineWidth',LW);
            if ss>1 && numel(TC)>1
                text(fitx(end)+xoffset+3,fity(end),num2str(ss-1),'Color',color);
            end
        else
            errorbar(X+xoffset,Y,E,'Marker',marker,'LineStyle',lStyle,'Color',color,'MarkerFaceColor',color,'LineWidth',LW);
            hold on
            if ss>1 && numel(TC)>1
                text(X(end)+xoffset+3,Y(end),num2str(ss-1),'Color',color);
            end
        end
        
    end
    xlabel('Direction (deg)');
    ylabel('mean dFoF');
    set(gca,'XTick',X);
    [~,fname]=fileparts(TC{1}.file{1}); % drop path, too long
    titStr=[fname ' c' num2str(TC{1}.cellNumber(1),'%.3d')];
    title(titStr,'Interpreter','none');
end