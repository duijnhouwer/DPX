function  rdAnalyseCylinderDepth(varargin)
% rdAnalyseCylinderDepth(varargin)
%   basic analysis function for the cylinder experiments.
%
% INPUT
%   Input is given in pairwise form, first the identifier for the type of
%   input, and next the variable, value or setting. See specific available
%   inputs below. Examples of how to input a certain parameters is given.
%   You can execute this function without any input. This will prompt a
%   window to pick the data, in which you can pick multiple subjects. For
%   other inputs, it will use the default values (see the inputs below).
%
%       Data ('data','dataVariable')
%           Optional data input. if not included, will
%           prompt a loading screening in which you can select
%           whichever files you want to load.
%
%       Average ('average',1)
%           true or false, default is true.
%           Average the data or plot all subjects individually. Just pass a
%           logical true or false.
%
%       Disps ('disps',[-.8 -.4 0 .4 .8])
%           only plotting specific disparities. This is usefull when
%           analyzing datafiles in which datasets have discrepancies
%           between disparities, for instance, some sets have disparities
%           ranging from -1 to 1, some -.8 to .8. By default, this function
%           interpolates such cases, but if you want to have less data
%           manipulation, you can use this input to define the plotted
%           disparities.
%
% OUTPUT
%   N.A., only figures.
%
% FOOTNOTE
%   Last edit by Reinder Dorman, augustus 2016, for Biophysics department
%   Radboud University
%
%   Questions and comments: reind.dorman(at)gmail.com
%


%% Assess input
P=parsePairs(varargin);
checkField(P,'data',[]);
checkField(P,'average',1);
checkField(P,'disps',[]); % INSERT TO PICK A SPECIFIC DISP


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

if ~exist('Data','var') disp('No Data Selected'); return; end

%% Check and display relevant information about loaded data
for i=1:numel(Data); subjects(i) = Data{i}.exp_subjectId(1); end
if numel(unique(subjects))>1;
    uSubjects = unique(subjects);
    fprintf('Loading Multiple subjects:')
    for iSubjects = 1:numel(uSubjects);
        if iSubjects>1 fprintf(' - '); end
        fprintf(' %s ',uSubjects{iSubjects});
    end
    fprintf('\n');
end
for i=1:numel(Data); paradigms(i) = Data{i}.exp_paradigm(1); end
if numel(unique(paradigms))>1;
    error('Two different experimental paradigm''s loaded.')
end

%% Some pre-processing
for d=1:numel(Data)
    % check if files are really DPX data files
    if ~dpxdIs(Data{d}) || Data{d}.N<=1;
        warning(['Removing non-dpx file: ' fnames{d}]);
        Data{d}=[];
    end
end

if ~isempty(P.disps)
    fprintf('Selected disparities : %s\n',num2str([P.disps])');
    for d=1:numel(Data)
        % check for availability of chosen disparities.
        if ~all(ismember(P.disps,Data{d}.halfInducerCyl_disparityFrac))
            warning(['Removing file with non-corresponding disparity values: ' fnames{d}]);
            fprintf('\t Disparities in data: %s\n',num2str(unique(Data{d}.halfInducerCyl_disparityFrac)));
            Data{d}=[];
        end 
    end
end

Data=dpxdMerge(Data);
oldN=Data.N;
Data = dpxdSubset(Data,Data.resp_rightHand_keyNr>0);
fprintf('Discarded %d out of %d trials for lack of response\n',oldN-Data.N,oldN); % only take stereo, no anti-stereo this time

Data = dpxdSubset(Data,Data.halfInducerCyl_stereoLumCorr==1); 

% Check first trial is removed, the adaptation trial.
% Should already be cleared by the Discard lack of response part.
Data = dpxdSubset(Data,Data.halfInducerCyl_rotSpeedDeg~=0);

%% Process Data
subjects = unique(Data.exp_subjectId);
Data = dpxdSplit(Data,'exp_subjectId');
x=[];
y=[];
for s = 1:numel(subjects)
    if strcmp(Data{s}.exp_paradigm{1},'rdDpxExpAdaptDepth_diep') || strcmp(Data{s}.exp_paradigm{1},'rdDpxExpBaseLineCylLeft');
        %%% ANALYZE DEPTH PERCEPT DATA
        
        if ~isempty(P.disps)
            totalDisparities = P.disps;
        else
            totalDisparities = unique(Data{s}.halfInducerCyl_disparityFrac);
        end
        
        for iDisp = 1:numel(totalDisparities)
            iData = dpxdSubset(Data{s},Data{s}.halfInducerCyl_disparityFrac==totalDisparities(iDisp));
            x{s}(iDisp) = mean(iData.halfInducerCyl_disparityFrac);
            y{s}(iDisp) = mean(iData.resp_rightHand_keyNr == 2); % down arrow
        end
        
    elseif strcmp(Data{s}.exp_paradigm{1},'rdDpxExpAdaptDepth_bind') || strcmp(Data{s}.exp_paradigm{1},'rdDpxExpBindingCylLeft')
        %%% ANALYZE BINDING DATA
        
        if ~isempty(P.disps)
            totalDisparities = P.disps;
        else
            totalDisparities = unique(Data{s}.halfInducerCyl_disparityFrac);
        end
        speeds               = unique(Data{s}.halfInducerCyl_rotSpeedDeg);
        % unique sorts lowest to highest.
        
        totalDisparities(totalDisparities==0)=[]; 
        % zero disparity makes no sense in binding, removed.
        
        x(s,:) = [min(totalDisparities) max(totalDisparities)];
        
        for iSpeed = 1:numel(speeds);
            for iDisp = 1:numel(x(s,:))
                
                if speeds(iSpeed)<0;                 % motion is going down
                    if x(s,iDisp)<0;       % disparity is concave
                        curCor = 1; % up arrow
                    elseif x(s,iDisp)>0;   % disparity is convex
                        curCor = 2; % down arrow
                    end
                elseif speeds(iSpeed)>0;             % motion is going up
                    if x(s,iDisp)<0;       % disparity is concave
                        curCor = 2; 
                    elseif x(s,iDisp)>0;   % disparity is convex
                        curCor = 1; 
                    end
                end
                
                iData = dpxdSubset(Data{s},Data{s}.halfInducerCyl_disparityFrac==x(s,iDisp) & Data{s}.halfInducerCyl_rotSpeedDeg==speeds(iSpeed));
                
                y(s,iDisp) = mean(iData.resp_rightHand_keyNr == curCor);
                
            end
        end
    end
end

if iscell(x) && any(diff(cellfun(@numel,x))~=0) && P.average
    warning('Uneven disparities between subjects. Interpolating for averaging');          
    fprintf('To plot only specific disparities, use the ''disps'' input\n\t See ');
    fprintf('<a href="matlab: help rdAnalyseCylinderDepth">help</a> for more info.\n');

    xInt = -1:.2:1;
    for s = 1:numel(subjects)
        yInt(s,:) = interp1(x{s},y{s},xInt);
    end
    x = xInt;
    y = yInt;
    yAvg = nanmean(yInt,1);
    yStd = nanstd(yInt,0,1);
elseif iscell(x) && any(diff(cellfun(@numel,x))~=0)
    warning('Uneven disparities between subjects.')
    maxDisps = unique(max(cellfun(@numel,x)));
elseif iscell(x)
    x = cell2mat(x');
    y = cell2mat(y');
    yStd = std(y,0,1);
    yAvg = mean(y,1);
else
    yStd = std(y,0,1);
    yAvg = mean(y,1);
end



%% STATISTICS
% paired t-test because simply estimate differences between means of two
% experiments on the same subjects

[H,p] = ttest(y(:,1),y(:,2));

%% DISPLAY
if P.average % average or loose plots?
    x = mean(x,1);
    y = yAvg;
    avgStr = ', Averaged /w SEM';
    lgnd=[];
else
    yStd = zeros(size(x));
    avgStr='';
    lgnd = subjects;
    p=1;
end
nSubjects=numel(subjects);

if strcmp(Data{s}.exp_paradigm{1},'rdDpxExpAdaptDepth_diep') || strcmp(Data{s}.exp_paradigm{1},'rdDpxExpBaseLineCylLeft');
    tit         = ['Depth Perception' avgStr];
    h = LF_makeFig(tit);
    if P.average;
        errorbar(x',y',yStd'./nSubjects);
    else
        plot(x',y')
    end
    hold on;
    if ~isempty(lgnd) legend(lgnd); end
    title(tit);
    
    plot(get(gca,'XLim'),[.5 .5],'--','Color',[.5 .5 .5]);
    plot([0 0],[0 1],'--','Color',[.5 .5 .5]);
    ylim([0 1.1]);
    
    xlabel('Disparity fractions');
    ylabel('Percentage Convex');
    
elseif strcmp(Data{s}.exp_paradigm{1},'rdDpxExpAdaptDepth_bind') || strcmp(Data{s}.exp_paradigm{1},'rdDpxExpBindingCylLeft');
    tit         = ['Visual Binding' avgStr];
    h = LF_makeFig(tit);
    if P.average
        barwitherr(yStd./nSubjects,x,y,'b');
        hold on;
        title(tit);
        
        plot(get(gca,'XLim'),[.5 .5],'--','Color',[.5 .5 .5]);
        plot([0 0],[0 1],'--','Color',[.5 .5 .5]);
        set(gca,'XTick',totalDisparities);
        ylim([0 1.1]);
    else
        for s = 1:nSubjects;
            subplot(ceil(nSubjects/4),4,s),
            bar(x(s,:),y(s,:),'b')
            hold on;
            
            plot(get(gca,'XLim'),[.5 .5],'--','Color',[.5 .5 .5]);
            plot([0 0],[0 1],'--','Color',[.5 .5 .5]);
            ylim([0 1]);
            
        end
        
    end
    
    xlabel('Disparity fractions');
    ylabel('Percentage Bound');
    
    if p<0.05 ;
        % if significant P value, make a significance asterisk and bar on
        % the plot.
        hold on
        intervalX=[-1 -1 1 1 ];
        intervalY=[max(yAvg)+max(yStd)+0.1 max(yAvg)+max(yStd)+0.15 max(yAvg)+max(yStd)+0.15 max(yAvg)+max(yStd)+0.1];
        plot(intervalX,intervalY,'k');
        text(0,max(yAvg)+max(yStd)+0.17,'*','FontSize',22);
        rdGraphText(['P = ' num2str(p)],'west');
    end
end

hold on axis

if P.average rdGraphText(['N = ' num2str(numel(unique(subjects)))],'northwest'); end;

hold off;

end

%% Local Functions
function h = LF_makeFig(name)
if isempty(findobj('name',name)); h=figure('Name',name);
else h = findobj('name',name); figure(h);
end
end

