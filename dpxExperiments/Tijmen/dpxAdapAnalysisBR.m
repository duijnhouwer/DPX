function [adapexp] = dpxAdapAnalysisBR(data) 
    % Tijmen Wartenberg, 09-04-15
    % Analysis file for TWBRadapatationexperiment0

   clear all;  clf; 
   load('C:\DPX\dpxExperiments\Tijmen\TWBRadaptationexperiment-JM-20150326104544.mat')   % use any (latest) data from dpxData to analyze 
   
     % to-be-filled array 
     adapexp.alternation    = []; 
     adapexp.repetition     = [];
     adapexp.responsetime   = []; 
     adapexp.response       = []; 
     adapexp.mixed          = []; 
     
    % select only the trials with responses
    l=1; nblocks=1;
    while nblocks(end)+1< length(data.condition)  
        if mod(nblocks(end),3)==0
        nblocks = [nblocks (3*l)+1];
        l=l+1;
        else 
        nblocks = [nblocks (3*l)];  
        end
    end
    
% extract information only from   
for k=nblocks
    trialDuration = data.stopSec(k) - data.startSec(k);
        
    % key presses
    datapLeft  = data.resp_keyboardl_keySec{k};
    datapLeft  = datapLeft - data.startSec(k);
    datapRight = data.resp_keyboardr_keySec{k};
    datapRight = datapRight - data.startSec(k);
    
    % key releases
    datarLeft  = data.resp_keyboardl_keyReleaseSec{k};
    datarLeft  = datarLeft - data.startSec(k);
    datarRight = data.resp_keyboardr_keyReleaseSec{k};
    datarRight = datarRight - data.startSec(k);
    
    % all data
    dataR = [datapRight, datarRight];
    sigmaR = ones(1,length(dataR));
    dataL = [datapLeft, datarLeft];
    sigmaL = -1*ones(1,length(dataL));
    dataM = [dataL, dataR];
    sigmaM = zeros(1, length(dataM));
    
    allData = [dataR, dataL, dataM; sigmaR,sigmaL, sigmaM]';
    allData = sortrows(allData,1);
    
    % order all the data to make a plot for the adaptation trials (with
    % report)
    
    m=1; 
    while (m+1)<length(allData)
        allData([m,m+1],:) = allData([m+1,m],:);
        m=m+4;
    end
    allData(isnan(allData))=trialDuration;
    
    % plot, looks nice for short and clean trials, but is messy and chaotic for long trials
    figure(1)
    plot(allData(:,1), allData(:,2), 'LineWidth', 2, 'Color', [0 0 0]);  hold on; 
    line([min(allData(:,1)) trialDuration] , [0 0], 'Color', [0 0 0], 'LineStyle', '--'); 
    legend('0=M, 1 = R, -1 = L', 'Location', 'northoutside'); 
    axis([min(allData(:,1))-0.5 trialDuration -1.1 1.1]);
    xlabel('time(s)');
    ylabel('perceptual recordings (binary scale)'); 
    title(['perceptual recordings - trial:' num2str(k)]); 

    % duration presses
    % deltaLeft  = datarLeft - datapLeft;
    % deltaRight = datarRight - datapRight;

    sigma = [];  
    responseTime = [];
    responseStopTime = []; 
    responseDuration = []; 
    mixedDuration = []; 

    % measure all the perceptual durations and alternations
    i=1; j=1; 
    if isempty(datapRight) ==0 && isempty(datapLeft) ==0
       
       while i<=length(datapRight) && length(datapLeft)>=j
        
        if datapRight(i)<datapLeft(j)
        sigma=[sigma, 1];
        responseTime = [responseTime, datapRight(i) ]; 
        responseStopTime = [responseStopTime, datarRight(i)]; 
        responseDuration = responseStopTime - responseTime;  
    
            if datarRight(i)<datapLeft(j); 
            mixedDuration = [mixedDuration datapLeft(j)-datarRight(i)]; 
            else 
                mixedDuration = [mixedDuration 0]; 
            end
    
        i=i+1;
       
        else if datapRight(i)> datapLeft(j)
        sigma=[sigma, -1 ]; 
        responseTime = [responseTime, datapLeft(j)];
        responseStopTime = [responseStopTime, datarLeft(j)];
        responseDuration = responseStopTime - responseTime; 
        
        end
    
            if datapRight(i)> datarLeft(j); 
            mixedDuration = [mixedDuration datapRight(i)-datarLeft(j)]; 
            else 
                mixedDuration = [mixedDuration 0]; 
            end
            
        j=j+1;
        end
       end
    
    labda = sigma(2:end);
    labda = [labda, 0];

    % divide the responses in alternations and repetitions
    discriminator = (sigma-labda)./2; discriminator=round(abs(discriminator(1:end)));
    responseRate = discriminator.*responseTime;
    alternationTime = responseRate(responseRate>0);
    repetitionTime  = responseTime(responseRate==0);   
    alternationInterval = alternationTime(2:end) - alternationTime(1:end-1);
  
    unifier = 1:length(alternationInterval); 
    even = unifier(mod(unifier,2)==0);
    odd = unifier(mod(unifier,2)~=0);

    hold off; 
    figure(2); 
    plot(responseStopTime, mixedDuration, 'Color', [0 0 0]); hold on;
    line([min(responseStopTime) max(responseStopTime)], [mean(mixedDuration) mean(mixedDuration)],'Color', [0 0 0], 'LineStyle', '--'); 
    title(['duration of mixed percept - trial:' num2str(k)]); 
    xlabel('time (s)'); ylabel('duration (s)'); 
    hold off; 

    % output
    adapexp.alternation{k}.interval = alternationInterval;
    adapexp.alternation{k}.intervalmono1 = alternationInterval(even);   
    adapexp.alternation{k}.intervalmono2 = alternationInterval(odd); 
    adapexp.repetition{k}.time = repetitionTime;
    adapexp.alternation{k}.time = alternationTime; 
    adapexp.responsetime{k} = responseTime; 
    adapexp.response{k} = sigma; 
    adapexp.mixed{k} = mixedDuration; 
    
    end
   
end

% mixed percepts for continous adaptation trials
select1 = adapexp.mixed{1}(adapexp.mixed{1}>.5); 
select2 = adapexp.mixed{4}(adapexp.mixed{4}>.5);
select3 = adapexp.mixed{7}(adapexp.mixed{7}>.5);

figure(3);
boxplot([select1, select2, select3], [ones(1, length(select1)), 2* ones(1, length(select2)), 3*ones(1, length(select3))]); 
title('duration mixed percepts for the adaptation trials'); 

% alternation probability in the 
rate1 = 1./(adapexp.alternation{3}.time(end)-adapexp.alternation{3}.time(1));
rate2 = 1./(adapexp.alternation{6}.time(end)-adapexp.alternation{6}.time(1));
rate3 = 1./(adapexp.alternation{9}.time(end)-adapexp.alternation{9}.time(1));
rate = [rate1, rate2,rate3];

end