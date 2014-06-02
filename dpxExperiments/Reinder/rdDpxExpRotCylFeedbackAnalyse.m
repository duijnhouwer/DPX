function rdDpxExpRotCylFeedbackAnalyse(D)
    
    if nargin==0 || isempty(D)
        fnames=dpxUIgetfiles;
        for f=1:numel(fnames)
            load(fnames{f});
            D{f}=data;
        end 
    end
    D=dpxTblMerge(D);
    oldN=D.N;
    D=dpxTblSubset(D,D.trial_resp_keyNr>0);
    disp(['Discarded ' num2str(oldN-D.N) ' out of ' num2str(oldN) ' trials for lack of response.']);
    D=dpxTblSplit(D,'halfCyl_stereoLumCorr');
    dpxFindFig('rdDpxExpRotCylFeedbackAnalyse');
    clf;
    labels={'asd','aadada'};
    subplot(1,2,1);
    plotPsychoCurves(D,'halfCyl_disparityFrac','DownArrow',labels);
    subplot(1,2,2);
    plotPsychoCurves(D,'halfCyl_rotSpeedDeg','DownArrow',labels);
    
end

function  h=plotPsychoCurves(D,fieldstr,keyname,labels)
    colors={'r',[0 .5 0],'b','c','m','y','k'};
    for d=1:numel(D)
        E=dpxTblSplit(D{d},fieldstr);
        for e=1:numel(E)
            x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
            y(e)=mean(strcmpi(E{e}.trial_resp_keyName,keyname));
        end
        h(d)=plot(x,y*100,'o-');
        axis([min(x) max(x) 0 100]);
        dpxPlotHori(50,'k--');
        dpxPlotVert(0,'k--');
        xlabel(fieldstr(fieldstr~='_'));
        ylabel('DownArrow');
        set(h(d),'Color',colors{d});
        hold on;
    end
    legend(h,labels);
end
    
    
    