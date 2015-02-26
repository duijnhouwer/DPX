function [adapexp] = dpxBadaptationRAnalysis(data) 
    clear all; 
     
     load('C:\dpxData\TWBRadaptationexperiment-0-20150226103159.mat')

     adapexp.alternation = []; 
     adapexp.repetition = [];
     adapexp.responsetime = []; 
     adapexp.response = []; 

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
   
    dataLeft  = data.resp_keyboardl_keySec{k};
    dataLeft  = dataLeft - data.startSec(k);
    dataRight = data.resp_keyboardr_keySec{k};
    dataRight = dataRight - data.startSec(k);
    
    trialDuration = data.stopSec(k)-data.startSec(k);
    linspace(0,trialDuration); 
    
    sigma=[];  
    responseTime=[];

    i=1; j=1; 
    
    if length(dataRight) ~=0 && length(dataLeft) ~=0
    while i<=length(dataRight) && length(dataLeft)>=j
    if dataRight(i)<dataLeft(j)
    sigma=[sigma 1]; 
    responseTime = [responseTime, dataRight(i)]; 
       i=i+1;
    else if dataRight(i)> dataLeft(j)
            sigma=[sigma -1]; 
            responseTime = [responseTime, dataLeft(j)]; 
              j=j+1;
        end
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
    
      adapexp.alternation{k}.interval = alternationInterval;
      adapexp.alternation{k}.intervalmono1 = alternationInterval(even); 
      adapexp.alternation{k}.intervalmono2 = alternationInterval(odd); 
      adapexp.repetition{k}.time = repetitionTime
      adapexp.alternation{k}.time = alternationTime; 
      adapexp.responsetime{k} = responseTime; 
      adapexp.response{k} = sigma; 
      
    end
         
    end
    
end