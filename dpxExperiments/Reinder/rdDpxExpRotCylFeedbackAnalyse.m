function rdDpxExpRotCylFeedbackAnalyse(D)
    
    if nargin==0 || isempty(D)
        fnames=dpxUIgetfiles;
        for i=1:numel(fnames)
            load(fnames{i});
            D{i}=data;
        end 
    end
    D=dpxTblMerge(D);
    D=dpxTblSplit(D,'halfCyl_stereoLumCorr');
    dpxFindFig('rdDpxExpRotCylFeedbackAnalyse');
    colors={'r',[0 .5 0],'b'};
    labels={'asd','aadada','cvcc'};
    for i=1:numel(D)
        h(i)=plotPsychoCurve(D{i});
        set(h(i),'Color',colors{i});
        hold on;
    end
    legend(h,labels);
end

function h=plotPsychoCurve(D)
    D=dpxTblSplit(D,'halfCyl_disparityFrac');
    for i=1:numel(D)
        disparity(i)=mean(D{i}.halfCyl_disparityFrac); 
        convexFrac(i)=mean(strcmpi(D{i}.trial_resp_keyName,'DownArrow'));
    end
    axis([-1 1 0 1]);
    h=plot(disparity,convexFrac,'o-');
    dpxPlotHori(0.5,'k--');
    dpxPlotVert(0,'k--');
    xlabel('Disparity');
    ylabel('"Convex"');
    hold on;
end
        
    
    
    