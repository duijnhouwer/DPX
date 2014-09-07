function dpxExampleExperimentAnalysis(data)
    
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
    
    % Split the data into as many parts as there are motionStim_cohereFrac
    % values.
    C=dpxTblSplit(data,'motionStim_cohereFrac');
    % Now loop over these subsets C, and get the coherences ans
    % answer-correct percentage value of each C We'll plot these as x and y
    % values respectively.
    coherence=nan(size(C));
    saidRight=nan(size(C));
    for i=1:numel(C)
        coherence(i)=mean(C{i}.motionStim_cohereFrac);
        saidRight(i)=mean(strcmpi(C{i}.resp_keyboard_keyName,'RightArrow'));
    end
    
    % Open a figure window with a specified title, if a window is already
    % open that has this title, that will be brouhgt to the front and it
    % will receive subsequent plot calls.
    dpxFindFig('dpxExampleExperimentAnalysis');
    cla; % Clear the contents of the figure if any
    h=plot(coherence*100,saidRight*100,'x-','LineWidth',2); % plot the psychometric curve
    dpxPlotVert(0,'k--'); % plot a vertical line through x=0
    dpxPlotHori(0.5,'k--'); % plot a horizontal line through y=0.5
    xlabel('Motion coherence (%; negative: left)');
    ylabel('''Right'' (%)');
    legend(h,['Subject: ' data.exp_subjectId{1}]);
    
end