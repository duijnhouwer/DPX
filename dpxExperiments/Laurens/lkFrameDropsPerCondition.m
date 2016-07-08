function lkFrameDropsPerCondition(DPXD,var)
    
    % EXAMPLE:
    % load('C:\Users\jacob\Downloads\lkDpxTuningSpeedDotDiamRdk0-DUMMYJD-20160708163319.mat')
    % lkFrameDropsPerCondition(DPXD,'test_dotDiamDeg');
    
    DPXD.framesPerTrial=(DPXD.stopSec-DPXD.startSec)*DPXD.window_measuredFrameRate(1);
    D=dpxdSplit(DPXD,var);
    meanPctFrameDrops=nan(size(D));
    stdPctFrameDrops=nan(size(D));
    for i=1:numel(D)
        percentmissed = D{i}.nrMissedFlips./D{i}.framesPerTrial*100;
        meanPctFrameDrops(i)=mean(percentmissed);
        stdPctFrameDrops(i)=std(percentmissed);
    end
    errorbar(meanPctFrameDrops,stdPctFrameDrops,'.-');
    var(var=='_')='.';
    xlabel(sprintf('%s condition #',var));
    ylabel('Percentage missed frames');
end