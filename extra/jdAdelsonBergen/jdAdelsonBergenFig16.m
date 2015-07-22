function jdAdelsonBergenFig16
    
    
    load('\\vision\dfs\home\jacob\My Documents\MATLAB\DPX\extra\jdAdelsonBergen\@jdAdelsonBergen\private\AB16.mat');
    findfig('Phi');
    XT=stim;
    plotStage4(XT);
    findfig('Static')
    XT=stim;
    for t=1:4:size(XT,1)-3
        XT(t:t+3,:)=circshift(XT(t:t+3,:),-(t-1),2);
    end
    plotStage4(XT);
    findfig('Reverse-Phi')
    XT=stim;
    for t=1:8:size(XT,1)-3
        XT(t:t+3,:)=mod(XT(t:t+3,:)+1,2);
    end
    plotStage4(XT);
                
end


function plotMEM(XT)
    M=jdAdelsonBergen(XT);
    left=M.dirNrg.leftTotal;
    right=M.dirNrg.rightTotal;
    net=M.netNrg;
    subplot(2,1,1);
    imagesc(XT); colormap gray
    subplot(2,1,2);
    barh([3 2 1],[left right net]);
    set(gca,'YTickLabel',{'Net','Right','Left'})
end

function plotStage4(XT)
    M=jdAdelsonBergen(XT);
    subplot(2,1,1);
    imagesc(XT); colormap gray
    subplot(2,1,2);
    R1=mean(M.filterMatch.right1(:));
    R2=mean(M.filterMatch.right2(:));
    L1=mean(M.filterMatch.left1(:));
    L2=mean(M.filterMatch.left2(:));
    barh([1 2 3 4],[R1 R2 L1 L2]);
    set(gca,'YTickLabel',{'R1','R2','L1','L2'})
end