function dpxExample2afcAnalysis(data)
    
    %dpxExample2afcAnalysis  Analysis for the dpxExample2afc experiment
    %
    %   USAGE: 
    %   DPXD=dpxLoad(DATAFILENAMEWITHPATH); 
    %   % Tip: to load the file copy/paste the file name fromt the matlab 
    %   % command window (MCW) after running dpxExample2afc, or drag the 
    %   % icon of the datafile onto the MCW. No need to ever type this.
    %   dpxExample2afcAnalysis(DPXD);
    %
    %   See also: dpxExample2afc
    %
    %   Jacob Duijnhouwer, 2014-09-07
    
    % Split the data into as many parts as there are motionStim_cohereFrac
    % values.
    C=dpxdSplit(data,'motionStim_cohereFrac');
    % Now loop over these subsets C, and get the coherences ans
    % answer-correct percentage value of each C We'll plot these as x and y
    % values respectively.
    coherence=nan(size(C));
    saidRight=nan(size(C));
    for i=1:numel(C)
        coherence(i)=mean(C{i}.motionStim_cohereFrac);
        saidRight(i)=mean(strcmpi(C{i}.resp_keyboard_keyName,'RightArrow'));
    end
    
    
    if exist('cpsFindFig','file')
        % Open a figure window with a specified title, if a window is already
        % open that has this title, that will be brouhgt to the front and it
        % will receive subsequent plot calls.
        figHandle=cpsFindFig('dpxExampleExperimentAnalysis');
    else
        disp('<ShamelessPlug>')
        disp('   Check out my plotting-toolbox <a href="https://github.com/duijnhouwer/cpsPlotTools">cpsPlotTools</a> for added functionality.');
        disp('</ShamelessPlug>')
        figHandle=figure;
    end
    cla; % Clear the contents of the figure if any
    h=plot(coherence*100,saidRight*100,'x-','LineWidth',2); % plot the psychometric curve
    dpxPlotVert(0,'k--'); % plot a vertical line through x=0
    dpxPlotHori(50,'k--'); % plot a horizontal line through y=0.5
    xlabel('Motion coherence (%; negative: left)');
    ylabel('''Rightward'' (%)');
    legend(h,['Subject: ' data.exp_subjectId{1}]);
end
