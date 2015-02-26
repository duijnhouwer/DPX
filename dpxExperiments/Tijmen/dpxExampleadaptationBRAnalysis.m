function [adapexp] = dpxBadaptationRAnalysis(data) 
    clear all; 
    
     load('C:\dpxData\TWBRadaptationexperiment-0-20150226103159.mat')
    
     adapexp.duration=[]; 
     adapexp.alternation=[]; 

    alternationTime = [];  
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
    alternationTime=[];

    i=1; j=1; 
    
    if length(dataRight) ~=0 && length(dataLeft) ~=0
    while i<=length(dataRight) && length(dataLeft)>=j
    if dataRight(i)<dataLeft(j)
    sigma=[sigma 1]; 
    alternationTime = [alternationTime, dataRight(i)]; 
       i=i+1;
    else if dataRight(i)> dataLeft(j)
            sigma=[sigma -1]; 
            alternationTime = [alternationTime, dataLeft(j)]; 
              j=j+1;
        end
    end
    end
    
    labda = sigma(2:end);
    labda = [labda, 0]
    
    alternation = (sigma-labda)./2; alternation=round(abs(alternation(1:end)));
    alternationRate = alternation.*alternationTime;
    alternationRate = alternationRate(alternationRate>0); 
    perceptDuration = alternationRate(2:end) - alternationRate(1:end-1);
    
    unifier = 1:length(perceptDuration); 
    even = unifier(mod(unifier,2)==0);
    odd = unifier(mod(unifier,2)~=0);
    
%     figure(1); 
%     plot(alternationRate); hold on;
%     title('alternation rate'); 
%    
%     figure(2);
%     plot(perceptDuration(even), 'b'); hold on;
%     plot(perceptDuration(odd), 'r'); 
%     title('percept duration'); 
%     else 
%         warning('There are no registrations of key presses for both control keys'); 
%     end
   
      adapexp.duration{k} = perceptDuration;
%     percept.duration{k}.even = perceptDuration(even);
%     percept.duration{k}.odd = perceptDuration(even);
%     percept.alternation{k}.rate = alternationRate; 
%     percept.alternation{k}.time = alternationTime; 
    
    end
    

% 
%     % Now loop over these subsets C, and get the coherences ans
%     % answer-correct percentage value of each C We'll plot these as x and y
%     % values respectively.
%     coherence=nan(size(C));
%     saidRight=nan(size(C));
%     for i=1:numel(C)
%         coherence(i)=mean(C{i}.motionStim_cohereFrac);
%         saidRight(i)=mean(strcmpi(C{i}.resp_keyboard_keyName,'RightArrow'));
%     end
%     
%     % Open a figure window with a specified title, if a window is already
%     % open that has this title, that will be brouhgt to the front and it
%     % will receive subsequent plot calls.
%     dpxFindFig('dpxExampleExperimentAnalysis');
%     cla; % Clear the contents of the figure if any
%     h=plot(coherence*100,saidRight*100,'x-','LineWidth',2); % plot the psychometric curve
%     dpxPlotVert(0,'k--'); % plot a vertical line through x=0
%     dpxPlotHori(50,'k--'); % plot a horizontal line through y=0.5
%     xlabel('Motion coherence (%; negative: left)');
%     ylabel('''Rightward'' (%)');
%     legend(h,['Subject: ' data.exp_subjectId{1}]);
%     
end