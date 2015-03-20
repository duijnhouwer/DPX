function jvDpxExpDDQaspectRatioAnalysis(data)
    
    % jvDpxExpDDQaspectRatioAnalysis(data)
    % Analysis accompanying the dpxExampleExperiment function
    % Usage:
    % load(DATAFILENAMEWITHPATH); % tip: copy paste this from the command line
    % after running the experiment, or drag the file icon onto the command
    % window, no need for typing it.
    % dpxExampleExperimentAnalysis(data);
    %
    % See also: agDpxExpDDQaspectRatio
    %
    % Jacob & Ahmed, 2014-09-30
    
    % Add an aspect ratio field
    data.ddq_aspectRatio=data.ddq_hDeg./data.ddq_wDeg;
    % Split the data into as many parts as there are aspect ratios
    % values.
    C=dpxdSplit(data,'ddq_aspectRatio');
    % Now loop over these subsets C, and get the coherences ans
    % answer-correct percentage value of each C We'll plot these as x and y
    % values respectively.
    aspectratio=nan(size(C));
    saidHori=nan(size(C));
    N=nan(size(C));
    for i=1:numel(C)
        aspectratio(i)=mean(C{i}.ddq_aspectRatio);
        saidHori(i)=mean(strcmpi(C{i}.resp_kb_keyName,'LeftArrow'));
        N(i)=C{i}.N;
    end
    
    % Open a figure window with a specified title, if a window is already
    % open that has this title, that will be brouhgt to the front and it
    % will receive subsequent plot calls.
    dpxFindFig(mfilename);
    cla; % Clear the contents of the figure if any
    F=dpxPsignifit;
    set(F,'X',aspectratio,'Y',saidHori,'N',N);
    hMarkers=F.plotdata;
    hold on;
    [hLine hEbar]=F.plotfit;
  %  h=plot(aspectratio,saidHori*100,'x-','LineWidth',2); % plot the psychometric curve
    dpxPlotVert(1,'k--'); % plot a vertical line through x=0
    dpxPlotHori(50,'k--'); % plot a horizontal line through y=0.5
    xlabel('height/width');
    ylabel('''Horizontal'' (%)');
    legend(hMarkers(1),['Subject: ' data.exp_subjectId{1}]);
    
end