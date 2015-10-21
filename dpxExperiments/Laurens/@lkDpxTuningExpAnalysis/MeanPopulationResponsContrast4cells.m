function mprc=MeanPopulationResponsContrast
    %Berekent het gemiddelde van de meanDFoFs (van 6 repeats) per contrastwaarde.
    %5contrasten-5snelheden-2richtingen
    TFwaarden=5
    contrastwaarden=5
    celaantal=4
    
    
    load('output cells 8&10&50&54.mat')
    prc=ans.meanDFoF                    %alle meandfofs van alle contrastwaarden, nog per richting
    
    a=TFwaarden*contrastwaarden 
    b=celaantal
    prcmat=reshape(prc,a,b)
    
    dfofsc1_pd=prcmat(1:5,:)     %alle meandfofs bij contrastwaarde 1 (0.0625), nog per richting
    dfofsc2_pd=prcmat(6:10,:)     %alle meandfofs bij contrastwaarde 2 (0.125), nog per richting
    dfofsc3_pd=prcmat(11:15,:)   %alle meandfofs bij contrastwaarde 3 (0.25), nog per richting
    dfofsc4_pd=prcmat(16:20,:)   %alle meandfofs bij contrastwaarde 4 (0.5), nog per richting
    dfofsc5_pd=prcmat(21:25,:)   %alle meandfofs bij contrastwaarde 5 (1.0), nog per richting
    
    dfofsc1=[dfofsc1_pd{1,1:end}]        %alle meandfofs bij contrastwaarde 1 (0.0625)
    dfofsc2=[dfofsc2_pd{1,1:end}]        %alle meandfofs bij contrastwaarde 2 (0.125)
    dfofsc3=[dfofsc3_pd{1,1:end}]        %alle meandfofs bij contrastwaarde 3 (0.25)
    dfofsc4=[dfofsc4_pd{1,1:end}]        %alle meandfofs bij contrastwaarde 4 (0.5)
    dfofsc5=[dfofsc5_pd{1,1:end}]        %alle meandfofs bij contrastwaarde 5 (1.0)
    
    dfofsc1_0=dfofsc1(1:2:end)          %alle meandfofs bij contrastwaarde 1 (0.0625) bij richting 0
    dfofsc2_0=dfofsc2(1:2:end)          %alle meandfofs bij contrastwaarde 2 (0.125) bij richting 0
    dfofsc3_0=dfofsc3(1:2:end)          %alle meandfofs bij contrastwaarde 3 (0.25) bij richting 0
    dfofsc4_0=dfofsc4(1:2:end)          %alle meandfofs bij contrastwaarde 4 (0.5) bij richting 0
    dfofsc5_0=dfofsc5(1:2:end)          %alle meandfofs bij contrastwaarde 5 (1.0) bij richting 0
    
    dfofsc1_180=dfofsc1(2:2:end)        %alle meandfofs bij contrastwaarde 1 (0.0625) bij richting 180
    dfofsc2_180=dfofsc2(2:2:end)        %alle meandfofs bij contrastwaarde 2 (0.125) bij richting 180
    dfofsc3_180=dfofsc3(2:2:end)        %alle meandfofs bij contrastwaarde 3 (0.25) bij richting 180
    dfofsc4_180=dfofsc4(2:2:end)        %alle meandfofs bij contrastwaarde 4 (0.5) bij richting 180
    dfofsc5_180=dfofsc5(2:2:end)        %alle meandfofs bij contrastwaarde 5 (1.0) bij richting 180
    
    mprc1_0=mean(dfofsc1_0)             %gemiddelde meandfofs bij contrastwaarde 1 (0.0625) bij richting 0
    mprc2_0=mean(dfofsc2_0)             %gemiddelde meandfofs bij contrastwaarde 2 (0.125) bij richting 0
    mprc3_0=mean(dfofsc3_0)             %gemiddelde meandfofs bij contrastwaarde 3 (0.25) bij richting 0
    mprc4_0=mean(dfofsc4_0)             %gemiddelde meandfofs bij contrastwaarde 4 (0.5) bij richting 0
    mprc5_0=mean(dfofsc5_0)             %gemiddelde meandfofs bij contrastwaarde 5 (1.0) bij richting 0
    
    mprc1_180=mean(dfofsc1_180)           %gemiddelde meandfofs bij contrastwaarde 1 (0.0625) bij richting 180
    mprc2_180=mean(dfofsc2_180)           %gemiddelde meandfofs bij contrastwaarde 2 (0.125) bij richting 180
    mprc3_180=mean(dfofsc3_180)           %gemiddelde meandfofs bij contrastwaarde 3 (0.25) bij richting 180
    mprc4_180=mean(dfofsc4_180)           %gemiddelde meandfofs bij contrastwaarde 4 (0.5) bij richting 180
    mprc5_180=mean(dfofsc5_180)           %gemiddelde meandfofs bij contrastwaarde 5 (1.0) bij richting 180
    
    mprc_0=[mprc1_0 mprc2_0 mprc3_0 mprc4_0 mprc5_0]                %alle gemiddelden bij richting 0 per contrastwaarde 
    mprc_180=[mprc1_180 mprc2_180 mprc3_180 mprc4_180 mprc5_180]    %alle gemiddelden bij richting 180 per contrastwaarde 
    
    plot(mprc_0)
    hold on
    plot(mprc_180,'r')
end