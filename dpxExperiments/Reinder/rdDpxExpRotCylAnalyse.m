function rdDpxExpRotCylAnalyse(D)
    
    if nargin==0 || isempty(D)
        fnames=dpxUIgetfiles;
        for f=1:numel(fnames)
            load(fnames{f});
            D{f}=data;
        end
    end
    D=dpxTblMerge(D);
    oldN=D.N;
    % Remove all trials in which no response was given
    D=dpxTblSubset(D,D.trial_resp_keyNr>0);
    disp(['Discarded ' num2str(oldN-D.N) ' out of ' num2str(oldN) ' trials for lack of response.']);
    %
    mono=D.halfCyl_disparityFrac==0;
    stereo=D.halfCyl_fogFrac==0 & D.halfCyl_dotDiamScaleFrac==0;
    M=dpxTblSubset(D,mono | mono&stereo);
    S=dpxTblSubset(D,stereo | mono&stereo);
    B=dpxTblSubset(D,~mono&~stereo | mono&stereo);
    %
    dpxFindFig('rdDpxExpRotCylAnalyse');
    clf;
    
    labels={'mono','stereo','both'};
    subplot(1,2,1);
    h(1)=plotPsychoCurves(M,'halfCyl_fogFrac','DownArrow','r');
    h(2)=plotPsychoCurves(S,'halfCyl_disparityFrac','DownArrow',[0 .5 0]);
    h(3)=plotPsychoCurves(B,'halfCyl_fogFrac','DownArrow','b');
    legend(h,labels);
    subplot(1,2,2);
    h(1)=plotPsychoCurves(M,'halfCyl_rotSpeedDeg','DownArrow','r');
    h(2)=plotPsychoCurves(S,'halfCyl_rotSpeedDeg','DownArrow',[0 .5 0]);
    h(3)=plotPsychoCurves(B,'halfCyl_rotSpeedDeg','DownArrow','b');
    legend(h,labels);
    
end

function  h=plotPsychoCurves(D,fieldstr,keyname,col)
    E=dpxTblSplit(D,fieldstr);
    for e=1:numel(E)
        x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
        y(e)=mean(strcmpi(E{e}.trial_resp_keyName,keyname));
    end
    h=plot(x,y*100,'o-');
    axis([min(x) max(x) 0 100]);
    dpxPlotHori(50,'k--');
    dpxPlotVert(0,'k--');
    xlabel(fieldstr(fieldstr~='_'));
    ylabel(keyname);
    set(h,'Color',col);
    hold on;
end


