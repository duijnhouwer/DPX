function dpxDDQtestAnalysis(data)
    
    % dpxExampleExperimentAnalysis(data)
    % Analysis accompanying the dpxExampleExperiment function
    % Usage:
    % load(DATAFILENAMEWITHPATH); % tip: copy paste this from the command line
    % after running the experiment, or drag the file icon onto the command
    % window, no need for typing it.
    % dpxExampleExperimentAnalysis(data);
    %
    % See also: dpxExampleExperiment
    %
    % Jacob Duijnhouwer, 2014-09-07
    
    % Add a field with vhRatios
    for i=1:data.N
        wid=max(data.dpxStimDynDotQrt_dXsDeg{i})*2;
        hei=max(data.dpxStimDynDotQrt_dYsDeg{i})*2;
        data.vhRatio(i)=hei/wid;
    end
    
    C=dpxdSplit(data,'vhRatio');
    % Now loop over these subsets C, and get the coherences ans
    % answer-correct percentage value of each C We'll plot these as x and y
    % values respectively.
    vhRatio=nan(size(C));
    saidHori=nan(size(C));
    for i=1:numel(C)
        vhRatio(i)=mean(C{i}.vhRatio);
        saidHori(i)=mean(strcmpi(C{i}.resp_keyboard_keyName,'LeftArrow'));
    end
    

    % Open a figure window with a specified title, if a window is already
    % open that has this title, that will be brouhgt to the front and it
    % will receive subsequent plot calls.
    dpxFindFig('dpxDDQtestAnalysis');
    cla; % Clear the contents of the figure if any
    h=plot(vhRatio,saidHori*100,'x-','LineWidth',2); % plot the psychometric curve
    axis([0 max(vhRatio)+1 0 100]);
    dpxPlotVert(1,'k--'); % plot a vertical line through x=0
    xlabel('Aspect ratio (>1 = tall)');
    ylabel('''Vertical motion'' (%)');
    legend(h,['Subject: ' data.exp_subjectId{1}]);
    
end