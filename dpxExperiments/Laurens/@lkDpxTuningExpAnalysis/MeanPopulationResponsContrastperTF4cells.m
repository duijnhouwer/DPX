function mprc=MeanPopulationResponsContrast
    %Berekent het gemiddelde van de meanDFoFs (van 6 repeats) per contrastwaarde.
    %5contrasten-5snelheden-2richtingen
    TFwaarden=5
    contrastwaarden=5
    celaantal=4
    richtingsaantal=2
    
    load('output cells 8&10&50&54.mat')
    prc=ans.meanDFoF                    %alle meandfofs van alle contrastwaarden, nog per richting
    
    a=TFwaarden*contrastwaarden 
    b=celaantal
    c=richtingsaantal
    prcmat=reshape(prc,a,b)
    
    dfofsc1_pd=prcmat(1:5,:)     %alle meandfofs bij contrastwaarde 1 (0.0625), nog per richting
    dfofsc2_pd=prcmat(6:10,:)     %alle meandfofs bij contrastwaarde 2 (0.125), nog per richting
    dfofsc3_pd=prcmat(11:15,:)   %alle meandfofs bij contrastwaarde 3 (0.25), nog per richting
    dfofsc4_pd=prcmat(16:20,:)   %alle meandfofs bij contrastwaarde 4 (0.5), nog per richting
    dfofsc5_pd=prcmat(21:25,:)   %alle meandfofs bij contrastwaarde 5 (1.0), nog per richting
    
    dfofsc1_TF1=[dfofsc1_pd{1,1:end}]       %alle meandfofs bij contrastwaarde 1 (0.0625), 2richtingen * 4cellen (1e waarde(0 deg) 2e bij 180 beide voor cel1, 3e (0deg) 4e (180 deg) cel2 etc)
    dfofsc1_TF2=[dfofsc1_pd{2,1:end}]       %alle meandfofs bij contrastwaarde 1 (0.0625) bij TF2
    dfofsc1_TF3=[dfofsc1_pd{3,1:end}]       %alle meandfofs bij contrastwaarde 1 (0.0625) bij TF3
    dfofsc1_TF4=[dfofsc1_pd{4,1:end}]       %alle meandfofs bij contrastwaarde 1 (0.0625) bij TF4
    dfofsc1_TF5=[dfofsc1_pd{5,1:end}]       %alle meandfofs bij contrastwaarde 1 (0.0625) bij TF5
    
    dfofsc2_TF1=[dfofsc2_pd{1,1:end}]       %alle meandfofs bij contrastwaarde 2 (0.125) bij TF1
    dfofsc2_TF2=[dfofsc2_pd{2,1:end}]       %alle meandfofs bij contrastwaarde 2 (0.125) bij TF2
    dfofsc2_TF3=[dfofsc2_pd{3,1:end}]       %alle meandfofs bij contrastwaarde 2 (0.125) bij TF3
    dfofsc2_TF4=[dfofsc2_pd{4,1:end}]       %alle meandfofs bij contrastwaarde 2 (0.125) bij TF4
    dfofsc2_TF5=[dfofsc2_pd{5,1:end}]       %alle meandfofs bij contrastwaarde 2 (0.125) bij TF5
    
    dfofsc3_TF1=[dfofsc3_pd{1,1:end}]       %alle meandfofs bij contrastwaarde 3 (0.25) bij TF1
    dfofsc3_TF2=[dfofsc3_pd{2,1:end}]       %alle meandfofs bij contrastwaarde 3 (0.25) bij TF2
    dfofsc3_TF3=[dfofsc3_pd{3,1:end}]       %alle meandfofs bij contrastwaarde 3 (0.25) bij TF3
    dfofsc3_TF4=[dfofsc3_pd{4,1:end}]       %alle meandfofs bij contrastwaarde 3 (0.25) bij TF4
    dfofsc3_TF5=[dfofsc3_pd{5,1:end}]       %alle meandfofs bij contrastwaarde 3 (0.25) bij TF5
            
    dfofsc4_TF1=[dfofsc4_pd{1,1:end}]       %alle meandfofs bij contrastwaarde 4 (0.5) bij TF1
    dfofsc4_TF2=[dfofsc4_pd{2,1:end}]       %alle meandfofs bij contrastwaarde 4 (0.5) bij TF2
    dfofsc4_TF3=[dfofsc4_pd{3,1:end}]       %alle meandfofs bij contrastwaarde 4 (0.5) bij TF3
    dfofsc4_TF4=[dfofsc4_pd{4,1:end}]       %alle meandfofs bij contrastwaarde 4 (0.5) bij TF4
    dfofsc4_TF5=[dfofsc4_pd{5,1:end}]       %alle meandfofs bij contrastwaarde 4 (0.5) bij TF5
    
    dfofsc5_TF1=[dfofsc5_pd{1,1:end}]       %alle meandfofs bij contrastwaarde 5 (1.0) bij TF1
    dfofsc5_TF2=[dfofsc5_pd{2,1:end}]       %alle meandfofs bij contrastwaarde 5 (1.0) bij TF2
    dfofsc5_TF3=[dfofsc5_pd{3,1:end}]       %alle meandfofs bij contrastwaarde 5 (1.0) bij TF3
    dfofsc5_TF4=[dfofsc5_pd{4,1:end}]       %alle meandfofs bij contrastwaarde 5 (1.0) bij TF4
    dfofsc5_TF5=[dfofsc5_pd{5,1:end}]       %alle meandfofs bij contrastwaarde 5 (1.0) bij TF5

    mprc1_TF1=mean(dfofsc1_TF1)             %gemiddelde meandfofs bij contrastwaarde 1 (0.0625) bij TF1
    mprc1_TF2=mean(dfofsc1_TF2)
    mprc1_TF3=mean(dfofsc1_TF3)
    mprc1_TF4=mean(dfofsc1_TF4)
    mprc1_TF5=mean(dfofsc1_TF5)
    
    mprc2_TF1=mean(dfofsc2_TF1)             %gemiddelde meandfofs bij contrastwaarde 2 (0.125) bij TF2
    mprc2_TF2=mean(dfofsc2_TF2)
    mprc2_TF3=mean(dfofsc2_TF3)
    mprc2_TF4=mean(dfofsc2_TF4)
    mprc2_TF5=mean(dfofsc2_TF5)
    
    mprc3_TF1=mean(dfofsc3_TF1)             %gemiddelde meandfofs bij contrastwaarde 3 (0.25) bij TF3
    mprc3_TF2=mean(dfofsc3_TF2)
    mprc3_TF3=mean(dfofsc3_TF3)
    mprc3_TF4=mean(dfofsc3_TF4)
    mprc3_TF5=mean(dfofsc3_TF5)
    
    mprc4_TF1=mean(dfofsc4_TF1)             %gemiddelde meandfofs bij contrastwaarde 4 (0.5) bij TF4
    mprc4_TF2=mean(dfofsc4_TF2)
    mprc4_TF3=mean(dfofsc4_TF3)
    mprc4_TF4=mean(dfofsc4_TF4)
    mprc4_TF5=mean(dfofsc4_TF5)
    
    mprc5_TF1=mean(dfofsc5_TF1)             %gemiddelde meandfofs bij contrastwaarde 5 (1.0) bij TF5
    mprc5_TF2=mean(dfofsc5_TF2)
    mprc5_TF3=mean(dfofsc5_TF3)
    mprc5_TF4=mean(dfofsc5_TF4)
    mprc5_TF5=mean(dfofsc5_TF5)
    
    mprc_TF1=[mprc1_TF1 mprc2_TF1 mprc3_TF1 mprc4_TF1 mprc5_TF1]                %alle gemiddelden bij TF1 per contrastwaarde 
    mprc_TF2=[mprc1_TF2 mprc2_TF2 mprc3_TF2 mprc4_TF2 mprc5_TF2]                %alle gemiddelden bij TF2 per contrastwaarde 
    mprc_TF3=[mprc1_TF3 mprc2_TF3 mprc3_TF3 mprc4_TF3 mprc5_TF3]                %alle gemiddelden bij TF3 per contrastwaarde 
    mprc_TF4=[mprc1_TF4 mprc2_TF4 mprc3_TF4 mprc4_TF4 mprc5_TF4]                %alle gemiddelden bij TF4 per contrastwaarde 
    mprc_TF5=[mprc1_TF5 mprc2_TF5 mprc3_TF5 mprc4_TF5 mprc5_TF5]                %alle gemiddelden bij TF5 per contrastwaarde 
    
    mprc1_TF=[mprc1_TF1 mprc1_TF2 mprc1_TF3 mprc1_TF4 mprc1_TF5]                %alle gemiddelden bij contrastwaarde1 per TF
    mprc2_TF=[mprc2_TF1 mprc2_TF2 mprc2_TF3 mprc2_TF4 mprc2_TF5]                %alle gemiddelden bij contrastwaarde2 per TF
    mprc3_TF=[mprc3_TF1 mprc3_TF2 mprc3_TF3 mprc3_TF4 mprc3_TF5]                %alle gemiddelden bij contrastwaarde3 per TF 
    mprc4_TF=[mprc4_TF1 mprc4_TF2 mprc4_TF3 mprc4_TF4 mprc4_TF5]                %alle gemiddelden bij contrastwaarde4 per TF
    mprc5_TF=[mprc5_TF1 mprc5_TF2 mprc5_TF3 mprc5_TF4 mprc5_TF5]                %alle gemiddelden bij contrastwaarde5 per TF
    
%%%%%%%%% plot Contrasts %%%%%%%%%    
%     x= [0.25 0.5 1 2 4]
%     semilogx(x,mprc1_TF,'m')
% %     hold on
% %     semilogx(x,mprc2_TF,'b')
% %     hold on
% %     semilogx(x,mprc3_TF,'g')
% %     hold on
% %     semilogx(x,mprc4_TF,'y')
% %     hold on
% %     semilogx(x,mprc5_TF,'r')
    


%     x=[0.25, 0.5, 1, 2, 4]
%     y1=mprc1_TF
%     y2=mprc2_TF
%     y3=mprc3_TF
%     y4=mprc4_TF
%     y5=mprc5_TF
    plot(mprc1_TF,'m')
    hold on
    plot(mprc2_TF,'b')
    hold on
    plot(mprc3_TF,'g')
    hold on
    plot(mprc4_TF,'y')
    hold on
    plot(mprc5_TF,'r')
    ax = gca;
    set(ax,'XTick',[1:5])
    set(ax,'XTickLabel', {0.25, 0.5, 1, 2, 4})
    xlim([1 5])
    
    legend('C 0.0625','C 0.125','C 0.25','C 0.5', 'C 1.0')
    
%%%%%%%%% plot TFs %%%%%%%%%    
%     plot(mprc_TF1,'m')
%     hold on
%     plot(mprc_TF2,'b')
%     hold on
%     plot(mprc_TF3,'g')
%     hold on
%     plot(mprc_TF4,'y')
%     hold on
%     plot(mprc_TF5,'r')
%     legend('0.25 c/deg','0.5 c/deg','1 c/deg','2 c/deg', '4 c/deg')
    
end