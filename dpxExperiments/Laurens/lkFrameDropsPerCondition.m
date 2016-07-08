function lkFrameDropsPerCondition(DPXD,var)
    
    % EXAMPLE:
    % load('C:\Users\jacob\Downloads\lkDpxTuningSpeedDotDiamRdk0-DUMMYJD-20160708163319.mat')
    % lkFrameDropsPerCondition(DPXD,'test_dotDiamDeg');
    
    dpxFindFig(mfilename);
    subplot(1,2,1,'align');
    hist(DPXD.nrMissedFlips);
    xlabel('nrMissedFlips');
    ylabel('% trials');
    title('Across all cond''s');
    % 
    DPXD.framesPerTrial=(DPXD.stopSec-DPXD.startSec)*DPXD.window_measuredFrameRate(1);
    D=dpxdSplit(DPXD,var);
    meanPctFrameDrops=nan(size(D));
    stdPctFrameDrops=nan(size(D));
    for i=1:numel(D)
        percentmissed = D{i}.nrMissedFlips./D{i}.framesPerTrial*100;
        meanPctFrameDrops(i)=mean(percentmissed);
        stdPctFrameDrops(i)=std(percentmissed);
    end
    subplot(1,2,1,'align');
    hist(DPXD.nrMissedFlips);
    subplot(1,2,2,'align');
    errorbar(meanPctFrameDrops,stdPctFrameDrops,'.-');
    var(var=='_')='.';
    xlabel(sprintf('%s condition #',var));
    ylabel('Percentage missed frames');
end