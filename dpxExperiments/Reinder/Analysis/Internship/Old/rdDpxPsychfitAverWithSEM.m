function [D me]=rdDpxPsychfitAverWithSEM()
% plot a psychometrc function on DPX data, in this case, made for rotating
% cylinders baseline. see the nested function "plotSigFit" for more details about
% why this is currently only for baseline cylinder experiment.

% if nargin>0
%     nargin=[] % no input yet, delete input
% end

fn=rdDpxFileInput;
for f = 1:numel(fn)
    load(fn{f});
    D{f} = data; %#ok
end
D = Merge(D);
D = DiscardNull(D);
E = whichExp(D);

if ~strcmpi(E.Id,'base')
    error('Psychfitting is only for the baseline exp')
end

D=dpxdSubset(D,data.halfInducerCyl_disparityFrac==-1 | data.halfInducerCyl_disparityFrac==-.8 | data.halfInducerCyl_disparityFrac==-.4 | data.halfInducerCyl_disparityFrac==0 | data.halfInducerCyl_disparityFrac==.4 | data.halfInducerCyl_disparityFrac==.8 | data.halfInducerCyl_disparityFrac==1);
numX=numel(unique(data.halfInducerCyl_disparityFrac));
SubsD=dpxdSplit(D,'exp_subjectId');

x(1:numel(SubsD),1:numX)=NaN;
y(1:numel(SubsD),1:numX)=NaN;
for s=1:numel(SubsD)
    [~,~,~,S,label] = Divide(SubsD{s},E);\
    tunique(S.(E.stereoCue))
    for sub=1:(numel(unique(S.(E.stereoCue))));
        Sdisp{sub}=dpxdSubset(S,S.(E.stereoCue)==unique(S.(E.stereoCue)){sub});
    end
    for iS=1:numel(Sdisp);
        x(s,iS)=mean(Sdisp{iS}.(E.stereoCue));
        y(s,iS)=mean(strcmpi(Sdisp{iS}.resp_rightHand_keyName,E.resp{1}));
    end
end
% concatenate data of all subjects
X=reshape(x,1,numel(x));
X=X(~isnan(X));
Y=reshape(y,1,numel(y));
Y=Y(~isnan(Y));
[X Xi]=sort(X);
Y=Y(Xi);

X=(round(X*100))/100;
Xses=unique(X); %because for some reason the same number deviate with like 1E-16 >.>
for u=1:numel(Xses)
    avX(u)=Xses(u);
    iY = find(X==Xses(u));
    avY(u)=mean(Y(iY));
    nY(u)=numel(Y(iY));
    stdY(u) = std(Y(iY));
    N(u) = numel(X(find(X==Xses(u))));
end

F = dpxPsignifit;
F.X = avX;
F.Y = avY;
F.N = N;
F.doFit;
F.plotdata; hold on
F.plotfit('xlim',[-1 1],'ylim',[0 1]);
hold on


for c = 1:numel(avY)
    SEM(c) = stdY(c)/sqrt(N(c));
    CIposY(c) = avY(c)+(SEM(c)*1.96);
    CInegY(c) = avY(c)-(SEM(c)*1.96);
end
 %%%%%%%%%%%%%%%%%%%%% bezig mooi confidence interval plaatje te
 %%%%%%%%%%%%%%%%%%%%% maken!@#@#4
% F = dpxPsignifit;
% F.X = avX;
% F.Y = CIposY;
% F.N = N;
% F.doFit;
% F.plotfit;
% hold on;
% 
% F = dpxPsignifit;
% F.X = avX;
% F.Y = CInegY;
% F.N = N;
% F.doFit;
% F.plotfit;



keyboard

if strcmpi(plotTypes,'A')
    %% one plot with an average fit for all selected data
    if max(strcmpi(E.Id,{'base','bind'}))
        [M,S,~,xtra,label] = Divide(D,E); %can be made better inside the Divide function. also, not necessary in this script.
        xCue = E.stereoCue;
    elseif max(strcmpi(E.Id,{'fullFb','halfFb'}))
        [M,S,xtra,~,label] = Divide(D,E);
        xCue = E.monoCueFog;
    end
    labels = {'Mono','Stereo',label.varLbl};
    
    aType = input('Shift Mu to each other? Y/N\n>>> :','s');
    
    figure;
    
    if strcmpi(aType,'N')
        %         [h(0) s(1)] =  plotSigFit(M,E.monoCueFog,E.resp,'Color','r','LineWidth',2);% make the plotSig function with SigFit built in. see post it.
        [h(2) s(2)] =  plotSigFit(S,E.stereoCue,E.resp,'Color','b','LineWidth',2);
        %         if xtra.N~= 0
        %             [h(3) s(3)] =  plotSigFit(xtra,xCue,E.resp,'Color','g','LineWidth',2);
        %         end
        title(['Average Psychometric fits. N = ' num2str(numel(unique(D.exp_subjectId)))])
        
    elseif strcmpi(aType,'Y');
        [h(1) s(1)] =  plotMuShiftFit(M,E.monoCueFog,E.resp,'Color','r','LineWidth',2);% make the plotSig function with SigFit built in. see post it.
        [h(2) s(2)] =  plotMuShiftFit(S,E.stereoCue,E.resp,'Color','b','LineWidth',2);
        if xtra.N~= 0
            [h(3) s(3)] =  plotMuShiftFit(xtra,xCue,E.resp,'Color','g','LineWidth',2);
        end
        title(['Mu shifted Average Psychometric fits. N = ' num2str(numel(unique(D.exp_subjectId)))])
    end
    legend(h,labels)
    xlabel('Fraction of realistic depth cue')
    ylabel('Percentage convex')
    
    txtCol = {'r','b','g'};
    for t = 1:3
        if ~isempty(s(t)) || s.sig<0
            text(0.2, .4-.05*t,['Mu = ' num2str(s(t).mu) ', sigma = ' num2str(s(t).sigma)],'Color',txtCol{t})
        else
            text(0.2, .4-.05*t,'No Psychometric fit possible','Color',txtCol{t})
        end
    end
end
if ~exist('me','var'); me = 'no errors'; end
end

function D = DiscardNull(D)
oldN = D.N;
D = dpxdSubset(D,D.resp_rightHand_keyNr>0);
disp(['Discarded ' num2str(oldN-D.N) ' out of ' num2str(oldN) ' trials for lack of response.\n\n']);
end

function exp = whichExp(data)
if strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylFeedback') || strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylLeftFeedback') || strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylRightFeedback');
    exp.Id = 'fullFb';
    exp.name = ['subject ' data.exp_subjectId{1} ': one full cylinder w/ feedback'];
    exp.monoCueFog = 'fullCyl_fogFrac';
    exp.monoCueDiam = 'fullCyl_dotDiamScaleFrac';
    exp.stereoCue = 'fullCyl_disparityFrac';
    exp.lummCor = 'fullCyl_stereoLumCorr';
    exp.speed = 'fullCyl_rotSpeedDeg';
    exp.resp = {'DownArrow' 'UpArrow'};
    exp.corPerc = 'reported correct percept of front plane';
elseif strcmpi(data.exp_expName(1),'rdDpxExpRotHalfCylLeftFeedback')  || strcmpi(data.exp_expName(1),'rdDpxExpRotHalfCylRightFeedback');
    exp.Id = 'halfFb';
    exp.name = ['subject ' data.exp_subjectId{1} ': half cylinder w/ feedback'];
    exp.monoCueFog = 'halfCyl_fogFrac';
    exp.monoCueDiam = 'halfCyl_dotDiamScaleFrac';
    exp.stereoCue = 'halfCyl_disparityFrac';
    exp.lummCor = 'halfCyl_stereoLumCorr';
    exp.speed = 'halfCyl_rotSpeedDeg';
    exp.resp = {'DownArrow' 'UpArrow'};
    exp.corPerc = 'reported convex';
elseif strcmpi(data.exp_expName(1),'rdDpxExpBaseLineCylLeft') || strcmpi(data.exp_expName(1),'rdDpxExpBaseLineCylRight');
    exp.Id = 'base';
    exp.name = ['subject ' data.exp_subjectId{1} ': shape of half cylinder w/o feedback'];
    exp.monoCueFog = 'halfInducerCyl_fogFrac';
    exp.monoCueDiam = 'halfInducerCyl_dotDiamScaleFrac';
    exp.stereoCue = 'halfInducerCyl_disparityFrac';
    exp.lummCor = 'halfInducerCyl_stereoLumCorr';
    exp.speed = 'halfInducerCyl_rotSpeedDeg';
    exp.resp = {'DownArrow' 'UpArrow'};
    exp.corPerc = 'reported percept, % convex';
    if isfield(data,'halfInducerCyl_monoDispShift')
        if sum(data.halfInducerCyl_monoDispShift)==0
        else
            exp.Shift = 'halfInducerCyl_monoDispShift';
        end
    end
elseif strcmpi(data.exp_expName(1),'rdDpxExpBindingCylLeft')...
        || strcmpi(data.exp_expName(1),'rdDpxExpBindingCylRight')
    exp.Id = 'bind';
    exp.name = ['subject ' data.exp_subjectId{1} ': percept of full cyl (context-driven)'];
    exp.monoCueFog = 'halfInducerCyl_fogFrac';
    exp.monoCueDiam = 'halfInducerCyl_dotDiamScaleFrac';
    exp.stereoCue = 'halfInducerCyl_disparityFrac';
    exp.lummCor = 'halfInducerCyl_stereoLumCorr';
    exp.speed = 'halfInducerCyl_rotSpeedDeg';
    exp.resp = {'DownArrow' 'UpArrow'};
    exp.corPerc = 'correct perception of target base on phys of inducer';
    if isfield(data,'halfInducerCyl_monoDispShift')
        if sum(data.halfInducerCyl_monoDispShift)==0
        else
            exp.Shift = 'halfInducerCyl_monoDispShift';
        end
    end
    % not functional yet.
    % elseif strcmpi(data.exp_expName(1),'rdDpxExpCentreBindCyl')
    %     exp.Id = 'bind';
    %     exp.name = ['subject ' data.exp_subjectId{1} ': percept of full cyl (context-driven)'];
    %     exp.monoCueFog = 'leftHalfInducerCyl_fogFrac';
    %     exp.monoCueDiam = 'leftHalfInducerCyl_dotDiamScaleFrac';
    %     exp.stereoCue = 'leftHalfInducerCyl_disparityFrac';
    %     exp.lummCor = 'leftHalfInducerCyl_stereoLumCorr';
    %     exp.speed = 'leftHalfInducerCyl_rotSpeedDeg';
    %     exp.resp = 'DownArrow';
    %     exp.corPerc = 'correct perception of target base on phys of inducer';
end
end

function [M S B AS lbl] = Divide(D,exp)
if isfield(exp,'Shift')
    mono=D.(exp.stereoCue)==0 & D.(exp.Shift)==0;
    stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1 & D.(exp.Shift)==0;
    antistereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==-1 & D.(exp.Shift)==0;
    dispShifted=D.(exp.Shift)==1;
else
    mono=D.(exp.stereoCue)==0;
    stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1;
    antistereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==-1;
end
M=dpxdSubset(D,mono | mono&stereo);
S=dpxdSubset(D,stereo | mono&stereo);
if strcmp(exp.Id,'fullFb') || strcmp(exp.Id,'halfFb');
    B=dpxdSubset(D,~mono&~stereo | mono&stereo);
    lbl.varLbl='both';
    AS=0;
else
    AS=dpxdSubset(D,antistereo | mono&antistereo);
    lbl.varLbl='anti-stereo';
    B=0;
end
end

function [h s]=plotSigFit(Data,Cue,Key,varargin)
% make a psychometric function from the data. if no psychometric fit is
% possible, it plots the dots for said data.
% Data is Data, Cue, is the cue which should be dealt with as x-axis, Key
% is a cell with the certain keys for a certain response (e.g. if x-axis is disparity
% from -1 to 1, MATLAB starts with -1, so Key should be the correct key for
% said disparity, for instance Key{1} = UpArrow etc.).
%
% 21-1-15
% For Rotating Cylinders experiment. Correct key in this case is #1:
% Downarrow. This because the plot reached -1:1 on the x-axis, i.e.
% concave:convex, so to make a normcdf fittable sigmoid minus has to be
% 0%, plusses have to be 100%.

D = Data; %shorthand

X = unique(D.(Cue));
for nX = 1:numel(X)
    xVals(nX) = X(nX);%#ok
    iX =  D.(Cue)==xVals(nX);
    yVals(nX) = sum(strcmpi(D.resp_rightHand_keyName(iX),Key{1}));%#ok
    yMax(nX)  = numel(D.resp_rightHand_keyName(iX));%#ok
end
try
    s = SigFit([xVals' yVals' yMax']);
    s.mu = s.params.est(1);
    s.sigma = s.params.est(2);
    yFit = normcdf(xVals,s.mu,s.sigma);
    line(xVals,yFit,varargin{:});
    hold on;
    s.Notsig=false;
catch me
    me.identifier
    s.mu=[]; s.sigma=[];
    s.Notsig=true;
end
if s.Notsig
    warning('Data is not sigmoidal, plotting a straight line through the data')%#ok
    coef = pinv([ones(numel(xVals),1) xVals'])*(yVals'./yMax');
    yHat = coef(1)+coef(2)*xVals;
    line(xVals,yHat,varargin{:});
end
h = plot(xVals,yVals./yMax,'Marker','x','LineStyle','none',varargin{:});
ylim([0 1]);
hold on;
end

function [h s]=plotMuShiftFit(Data,Cue,Key,varargin)
% make a psychometric function from the data. if no psychometric fit is
% possible, it plots the dots for said data.
% Data is Data, Cue, is the cue which should be dealt with as x-axis, Key
% is a cell with the certain keys for a certain response (e.g. if x-axis is disparity
% from -1 to 1, MATLAB starts with -1, so Key should be the correct key for
% said disparity, for instance Key{1} = UpArrow etc.).
%
% 21-1-15
% For Rotating Cylinders experiment. Correct key in this case is #1:
% Downarrow. This because the plot reached -1:1 on the x-axis, i.e.
% concave:convex, so to make a normcdf fittable sigmoid minus has to be
% 0%, plusses have to be 100%.

D = Data; %shorthand

X = unique(D.(Cue));
for nX = 1:numel(X)
    xVals(nX) = X(nX);%#ok
    iX =  D.(Cue)==xVals(nX);
    yVals(nX) = sum(strcmpi(D.resp_rightHand_keyName(iX),Key{1}));%#ok
    yMax(nX)  = numel(D.resp_rightHand_keyName(iX));%#ok
end
try
    s = SigFit([xVals' yVals' yMax']);
    s.mu = 0; %hardcoded zero mu to plot around the zero axis. shift every average plot over each other
    s.sigma = s.params.est(2);
    yFit = normcdf(xVals,s.mu,s.sigma);
    h = line(xVals,yFit,varargin{:});
    hold on;
catch me
    me.identifier
    keyboard
    warning('Data is not sigmoidal')%#ok
    s.mu=[]; s.sigma=[];
end
% h = plot(xVals,yVals./yMax,'Marker','x','LineStyle','none',varargin{:});
% the actual data would make very good sense. maybe a way to also shift it
% with the sigfit plot?
% reind 23-1-'15
ylim([0 1]);
hold on;
end

function D = Merge(D)
% a sort of last resort to pick out the monoshiftdisp thing


for idx=1:numel(D)
    if myIsField(D{idx},'halfInducerCyl_monoDispShift') %find if monoDispShift exists then remove all its data.
        iMDS=D{idx}.halfInducerCyl_monoDispShift;
        fi=fieldnames(D{idx});
        for r=1:numel(fi)-1 %skip the D.N
            D{idx}.(fi{r})(iMDS)=[];
        end
        D{idx}=rmfield(D{idx},'halfInducerCyl_monoDispShift');
        D{idx}.N=D{idx}.N-sum(iMDS);
    end
end


D=dpxdMerge(D);

    function isFieldResult = myIsField (inStruct, fieldName)
        % inStruct is the name of the structure or an array of structures to search
        % fieldName is the name of the field for which the function searches
        isFieldResult = 0;
        f = fieldnames(inStruct(1));
        for i=1:length(f)
            if(strcmp(f{i},strtrim(fieldName)))
                isFieldResult = 1;
                return;
            elseif isstruct(inStruct(1).(f{i}))
                isFieldResult = myIsField(inStruct(1).(f{i}), fieldName);
                if isFieldResult
                    return;
                end
            end
        end
    end
end

