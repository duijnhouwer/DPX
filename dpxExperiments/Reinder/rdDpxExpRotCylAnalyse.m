function D=rdDpxExpRotCylAnalyse(D)
    
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
    D=dpxTblSubset(D,D.resp_rightHand_keyNr>0);
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
    h(1)=plotPsychoCurves(M,'halfCyl_fogFrac','DownArrow','r-','LineWidth',3);
    h(2)=plotPsychoCurves(S,'halfCyl_disparityFrac','DownArrow','Color',[0 .5 0],'LineWidth',2);
    h(3)=plotPsychoCurves(B,'halfCyl_fogFrac','DownArrow','b','LineWidth',1);
    legend(h,labels);
    subplot(1,2,2);
    h(1)=plotPsychoCurves(M,'halfCyl_rotSpeedDeg','DownArrow','r-','LineWidth',3);
    h(2)=plotPsychoCurves(S,'halfCyl_rotSpeedDeg','DownArrow','Color',[0 .5 0],'LineWidth',2);
    h(3)=plotPsychoCurves(B,'halfCyl_rotSpeedDeg','DownArrow','b','LineWidth',1);
    legend(h,labels);
    
end

function  h=plotPsychoCurves(D,fieldstr,keyname,varargin)
    E=dpxTblSplit(D,fieldstr);
    for e=1:numel(E)
        x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
        y(e)=mean(strcmpi(E{e}.resp_rightHand_keyName,keyname));
    end
    h=plot(x,y*100,varargin{:});
    axis([min(x) max(x) 0 100]);
    dpxPlotHori(50,'k--');
    dpxPlotVert(0,'k--');
    xlabel(fieldstr(fieldstr~='_'));
    ylabel(keyname);
    hold on;
end


