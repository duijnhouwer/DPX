function [adapexp] = dpxBadaptationRAnalysis(data) 
    clear all; 
    
load('TWBRadaptationexperiment-0-20150304143354.mat')

     adapexp.alternation = []; 
     adapexp.repetition = [];
     adapexp.responsetime = []; 
     adapexp.response = []; 
     adapexp.mixed = []; 

    responseTime = [];  
    l=1; nblocks=1; 
    while nblocks(end)+1< length(data.condition)  
        if mod(nblocks(end),3)==0
        nblocks = [nblocks (3*l)+1];
        l=l+1
        else 
        nblocks = [nblocks (3*l)];  
        end
    end
     
    for k=nblocks
   
    % presses
    datapLeft  = data.resp_keyboardl_keySec{k};
    datapLeft  = datapLeft - data.startSec(k)
    datapRight = data.resp_keyboardr_keySec{k};
    datapRight = datapRight - data.startSec(k)
    
    %releases
    datarLeft  = data.resp_keyboardl_keyReleaseSec{k};
    datarLeft  = datarLeft - data.startSec(k)
    datarRight = data.resp_keyboardr_keyReleaseSec{k};
    datarRight = datarRight - data.startSec(k)
    
    dataR = [datapRight, datarRight];
    sigmaR = ones(1,length(dataR));
    dataL = [datapLeft, datarLeft];
    sigmaL = -1*ones(1,length(dataL));
    dataM = [dataL, dataR];
    sigmaM = zeros(1, length(dataM));
    
    
    
    allData = [dataR, dataL, dataM; sigmaR,sigmaL, sigmaM]';
    allData = sortrows(allData,1)
    plot(allData(:,1), allData(:,2)); 
    
    % duration presses
    deltaLeft  = datarLeft - datapLeft;
    deltaRight = datarRight - datapRight
    
    trialDuration = data.stopSec(k)-data.startSec(k);
    linspace(0,trialDuration); 
    
    sigma = [];  
    responseTime = [];
    responseDuration = []; 
    mixedDuration = []; 

    i=1; j=1; 
    
    if length(datapRight) ~=0 && length(datapLeft) ~=0
    while i<=length(datapRight) && length(datapLeft)>=j
    if datapRight(i)<datapLeft(j)
    sigma=[sigma, 1]; 
    responseTime = [responseTime, datapRight(i) ]; 
    responseDuration = [responseDuration, datarLeft(j) - datapLeft(j)];  
    
    if datarRight(i)<datapLeft(j); 
        mixedDuration = [mixedDuration datapLeft(j)-datarRight(i)]; 
    end
    
     i=i+1;
       
    else if datapRight(i)> datapLeft(j)
    sigma=[sigma, -1 ]; 
    responseTime = [responseTime, datapLeft(j)];  
    responseDuration = [responseDuration, datarLeft(j) - datapLeft(j)];
        end
    
        if datapRight(i)>datarLeft(j); 
        mixedDuration = [mixedDuration datapRight(i)-datarLeft(j)]; 
    end
    
    j=j+1;
    end
    end
    
    labda = sigma(2:end);
    labda = [labda, 0];
    
    discriminator = (sigma-labda)./2; discriminator=round(abs(discriminator(1:end)));
    responseRate = discriminator.*responseTime;
    alternationTime = responseRate(responseRate>0)
    repetitionTime  = responseTime(responseRate==0)
    
    alternationInterval = alternationTime(2:end) - alternationTime(1:end-1);
    
    unifier = 1:length(alternationInterval); 
    even = unifier(mod(unifier,2)==0);
    odd = unifier(mod(unifier,2)~=0);
    
    % data array 
      adapexp.alternation{k}.interval = alternationInterval;
      adapexp.alternation{k}.intervalmono1 = alternationInterval(even);   
      adapexp.alternation{k}.intervalmono2 = alternationInterval(odd); 
      adapexp.repetition{k}.time = repetitionTime
      adapexp.alternation{k}.time = alternationTime; 
      adapexp.responsetime{k} = responseTime; 
      adapexp.response{k} = sigma; 
      adapexp.mixed{k} = mixedDuration; 
    end
    
    end
    
end