function [ output_args ] = rdAnalyseCylinderDepth(varargin)
% rdAnalyseCylinder(varargin)
%   basic analysis function for the adaptation experiments.
%
% INPUT
% input is given in pairwise form, first the identifier for the type of
% input, and next the variable, value or setting. See specific available
% inputs below.
%
% INPUTS
%   Data -- ('data','dataVariable')
%       Optional data input. if not included, will
%       prompt a loading screening in which you can select
%       whichever files you want to load.
%
% OUTPUT
%   not yet
%
% ATM: loop through the subjects.


%% Assess input
P=parsePairs(varargin);
checkField(P,'data',[]);

%% Loading and checking
if isempty(P.data);
    fnames=dpxUIgetFiles;
    for i=1:numel(fnames)
        d = dpxdLoad(fnames{i});
        Data{i}=d;
    end
else
    Data{1} = P.data;
end

%% Check and display relevant information about loaded data
for i=1:numel(Data); subjects(i) = Data{i}.exp_subjectId(1); end
if numel(unique(subjects))>1;
    uSubjects = unique(subjects);
    fprintf('Loading Multiple subjects:')
    for iSubjects = 1:numel(uSubjects);
        fprintf(' %s - ',uSubjects{iSubjects});
    end
    fprintf('\n');
end
for i=1:numel(Data); paradigms(i) = Data{i}.exp_paradigm(1); end
if numel(unique(paradigms))>1;
    error('Two different experimental paradigm''s loaded.')
end

%% Some pre-processing
for d=1:numel(Data)
    if ~dpxdIs(Data{d}) || Data{d}.N<=1;
       warning(['Removing non-dpx file: ' fnames{d}]);
       Data{d}=[];
    end
end 

Data=dpxdMerge(Data);
oldN=Data.N;
Data = dpxdSubset(Data,Data.resp_rightHand_keyNr>0);
fprintf('Discarded %d out of %d trials for lack of response\n',oldN-Data.N,oldN);

% check first trial is removed, the adaptation trial.
% should already be cleared by the Discard lack of response part.
Data = dpxdSubset(Data,Data.halfInducerCyl_rotSpeedDeg~=0);

%% process Data
subjects = unique(Data.exp_subjectId);
Data = dpxdSplit(Data,'exp_subjectId');
x=[];
y=[];
for s = 1:numel(subjects) 
    if strcmp(Data{s}.exp_paradigm,'rdDpxExpAdaptDepth_diep')
        %%% ANALYZE DEPTH PERCEPT DATA
      
        totalDisparities = unique(Data{s}.halfInducerCyl_disparityFrac);
        for iDisp = 1:numel(totalDisparities)
            iData = dpxdSubset(Data{s},Data{s}.halfInducerCyl_disparityFrac==totalDisparities(iDisp));
            x(s,iDisp) = mean(iData.halfInducerCyl_disparityFrac);
            y(s,iDisp) = mean(iData.resp_rightHand_keyNr == 1);
        end

    elseif strcmp(Data{s}.exp_paradigm,'rdDpxExpAdaptDepth_bind')
        %%% ANALYZE BINDING DATA
        
        totalDisparities    = unique(Data{s}.halfInducerCyl_disparityFrac);
        speeds              = unique(Data{s}.halfInducerCyl_rotSpeedDeg);
        % unique sorts lowest to highest.
        
        x(s,:) = [min(totalDisparities) max(totalDisparities)];
       
        for iSpeed = 1:numel(speeds);
            for iDisp = 1:numel(totalDisparities)
                
                if speeds(iSpeed)<0;                 % motion is going down
                    if totalDisparities(iDisp)<0;       % disparity is concave
                        curCor = 2; % down arrow
                    elseif totalDisparities(iDisp)>0;   % disparity is convex
                        curCor = 1; % up arrow
                    end
                elseif speeds(iSpeed)>0;             % motion is going up
                    if totalDisparities(iDisp)<0;       % disparity is concave
                        curCor = 1; % up arrow
                    elseif totalDisparities(iDisp)>0;   % disparity is convex
                        curCor = 2; % down arrow
                    end
                end
                iData = dpxdSubset(Data{s},Data{s}.halfInducerCyl_disparityFrac==totalDisparities(iDisp) & Data{s}.halfInducerCyl_rotSpeedDeg==speeds(iSpeed));
                
                y(s,iDisp) = mean(iData.resp_rightHand_keyNr == curCor);
                
            end
        end
    end
end

x = mean(x,1);
yStd = std(y);
yAvg = mean(y,1);

%% statistics
% paired t-test because simply estimate differences between means of two
% experiments on the same subjects

[H,P] = ttest(y(:,1),y(:,2));

%% display    
if strcmp(Data{s}.exp_paradigm,'rdDpxExpAdaptDepth_diep')
    % some stuff for plotting
    tit         = 'Depth Perception';
    h = LF_makeFig(tit);
    plot(x,y);
else strcmp(Data{s}.exp_paradigm,'rdDpxExpAdaptDepth_bind')
    tit         = 'Visual Binding';        
    h = LF_makeFig(tit);
    barwitherr([yStd]./numel(subjects),x,yAvg,'b');
end

if P<0.05 ;
    hold on
    intervalX=[-1 -1 1 1 ];
    intervalY=[max(yAvg)+max(yStd)+0.1 max(yAvg)+max(yStd)+0.15 max(yAvg)+max(yStd)+0.15 max(yAvg)+max(yStd)+0.1];
    plot(intervalX,intervalY,'k');
    text(0,max(yAvg)+max(yStd)+0.17,'*','FontSize',22);
    rdGraphText(['P = ' num2str(P)],'west');
end

hold on axis

plot(get(gca,'XLim'),[.5 .5],'--','Color',[.5 .5 .5]);
plot([0 0],[0 1],'--','Color',[.5 .5 .5]);
ylim([0 1]);

title(tit);
rdGraphText(['N = ' num2str(numel(unique(subjects)))],'northwest');

hold off;

end

%% Local Functions
function h = LF_makeFig(name)
if isempty(findobj('name',name)); h=figure('Name',name);
else h = findobj('name',name); figure(h);
end
end

