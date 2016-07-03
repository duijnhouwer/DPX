function d=rdCylTrainingAna(varargin)
% analyse the training data.
% if input is empty, it just plots data.
%
% input 1 : fit yes or no (1 or 0)?
% input 2 : other functions (opens dialog)
%


if nargin==0 || varargin{1}==0
    fit=false;
elseif varargin{1}==1
    fit=true;
end
if nargin==2
    [c,sr]=GUI;
end

fnames=dpxUIgetfiles;
for f=1:numel(fnames)
    load(fnames{f});
    Data{f}=data; %#ok
end
Data=dpxdMerge(Data);

if exist('c','var')
    if c~=0
        %% %vex --> cave
        if sum(c==1)
            D=VexToCave(Data);
            
            d.X = unique(D.halfInducerCyl_disparityFrac);
            for nX = 1:numel(d.X)
                d.xVals(nX) = d.X(nX);
                iX = D.halfInducerCyl_disparityFrac==d.xVals(nX);
                d.yCave(nX) = sum(strcmpi(D.resp_Concave_keyName(iX),'UpArrow'));
                d.yVex(nX) = sum(strcmpi(D.resp_Convex_keyName(iX),'DownArrow'));
                d.yMax(nX) = d.yCave(nX)+d.yVex(nX);
                d.yVals(nX) = d.yVex(nX)/d.yMax(nX);
            end
            
            if ~fit;
                figure;
                d.VC=PlotData(d);
                ti = ['Training session for subject ' data.exp_subjectId{1} 'Convex to Concave only'];
                title(ti);
            elseif fit
                figure;
                d.VC=PlotFit(d);
                ti = ['SigFit: Training session for subject ' data.exp_subjectId{1} 'Convex to Concave only'];
                title(ti);
            end
            xylbl;
            hold off
        end
        %% %cave --> vex
        if sum(c==2)
            D=CaveToVex(Data);
            
            d.X = unique(D.halfInducerCyl_disparityFrac);
            for nX = 1:numel(d.X)
                d.xVals(nX) = d.X(nX);
                iX = D.halfInducerCyl_disparityFrac==d.xVals(nX);
                d.yCave(nX) = sum(strcmpi(D.resp_Concave_keyName(iX),'UpArrow'));
                d.yVex(nX) = sum(strcmpi(D.resp_Convex_keyName(iX),'DownArrow'));
                d.yMax(nX) = d.yCave(nX)+d.yVex(nX);
                d.yVals(nX) = d.yVex(nX)/d.yMax(nX);
            end
            
            if ~fit;
                figure;
                d.CV=PlotData(d);
                ti = ['Training session for subject ' data.exp_subjectId{1} 'Concave to Convex only'];
                title(ti);
            elseif fit
                figure;
                d.CV=PlotFit(d);
                ti = ['SigFit: Training session for subject ' data.exp_subjectId{1} 'Concave to Convex only'];
                title(ti);
            end
            xylbl;
            hold off
        end
        %% different Sample rates
        if sum(c==3)
            D=DiffSr(Data,sr);%%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%
            for pn=1:numel(D)
                
                d.X = unique(D{pn}.halfInducerCyl_disparityFrac);
                for nX = 1:numel(d.X)
                    d.xVals(nX) = d.X(nX);
                    iX = D{pn}.halfInducerCyl_disparityFrac==d.xVals(nX);
                    d.yCave(nX) = sum(strcmpi(D{pn}.resp_Concave_keyName(iX),'UpArrow'));
                    d.yVex(nX) = sum(strcmpi(D{pn}.resp_Convex_keyName(iX),'DownArrow'));
                    d.yMax(nX) = d.yCave(nX)+d.yVex(nX);
                    d.yVals(nX) = d.yVex(nX)/d.yMax(nX);
                end
                
                subplot(6,ceil(numel(D)/6),pn);
                if ~fit;
                    d.srD{pn}=PlotData(d);
                elseif fit
                    d.srD{pn}=PlotFit(d);
                end
            end
            supxylbl;
            hold off
        end
        
    end
else
    D=Data;
    d.X = unique(D.halfInducerCyl_disparityFrac);
    for nX = 1:numel(d.X)
        d.xVals(nX) = d.X(nX);
        iX = D.halfInducerCyl_disparityFrac==d.xVals(nX);
        d.yCave(nX) = sum(strcmpi(D.resp_Concave_keyName(iX),'UpArrow'));
        d.yVex(nX) = sum(strcmpi(D.resp_Convex_keyName(iX),'DownArrow'));
        d.yMax(nX) = d.yCave(nX)+d.yVex(nX);
        d.yVals(nX) = d.yVex(nX)/d.yMax(nX);
    end
    
    if ~fit;
        figure;
        d=PlotData(d);
        ti = ['Training session for subject ' data.exp_subjectId{1}];
        title(ti);
    elseif fit
        figure;
        d=PlotFit(d);
        ti = ['SigFit: Training session for subject ' data.exp_subjectId{1}];
        title(ti);
    end
    xylbl;
    hold off
end


end

function grid(X)
hold on
line([0 0],[0 1],'Color','k','LineStyle',':')
line([min(X) max(X)],[0.5 0.5],'Color','k','LineStyle',':')
line([min(X) max(X) max(X) max(X) max(X) min(X) min(X) min(X)],[0 0 0 1 1 1 1 0],'Color','k','LineStyle',':');
end

function d=PlotData(d)
plot(d.xVals,d.yVals,'bo-','LineWidth',2);
xlim([min(d.xVals)-.2 max(d.xVals)+.2]);
ylim([-.1 1.1]);
xlabel('Fraction of realistic disparity','FontSize',8);
ylabel('Fraction convex reported','FontSize',8);

grid(d.xVals)
end

function d=PlotFit(d)
try
    s = SigFit([d.xVals' d.yVex' d.yMax']);
    s.mu = s.params.est(1);
    s.sigma = s.params.est(2);
    yFit = normcdf(d.xVals,s.mu,s.sigma);
    line(d.xVals,yFit,'Color','b','LineWidth',2);
    hold on;
    s.Notsig=false;
catch me
    me.identifier
    s.mu=[]; s.sigma=[];
    s.Notsig=true;
end
if s.Notsig
    warning('Data is not sigmoidal, plotting a straight line through the data')%#ok
    coef = pinv([ones(numel(d.xVals),1) d.xVals'])*(d.yVals'./d.yMax');
    yHat = coef(1)+coef(2)*d.xVals;
    line(d.xVals,yHat,'Color','b','LineWidth',2);
end

plot(d.xVals,d.yVals,'Marker','x','LineStyle','none','Color','b','LineWidth',2);
ylim([0 1]);


xlim([min(d.X)-.2 max(d.X)+.2]);
ylim([-.1 1.1]);


grid(d.X)

d.mu    = s.mu;
d.sigma = s.sigma;
end

function [in sr]=GUI
% Create figure
h.f = figure('units','pixels','position',[200,200,150,150],...
    'toolbar','none','menu','none');
% Create checkboxes
h.c(1) = uicontrol('style','checkbox','units','pixels',...
    'position',[10,130,130,15],'string','plot vex -> cave');
h.c(2) = uicontrol('style','checkbox','units','pixels',...
    'position',[10,110,130,15],'string','plot cave -> vex');
t=1;
h.c(3) = uicontrol('style','checkbox','units','pixels',...
    'position',[10,90,130,15],'string','plot dif samplerates',...
    'callback',@c_call);

% The Possible input for samplerat
h.t = uicontrol('style','text','units','pixels',...
    'position',[20,50,110,15],'string','samplerate','visible','off');
h.e = uicontrol('style','edit','units','pixels',...
    'position',[20,30,120,15],'visible','off');
h.q = uicontrol('style','pushbutton','units','pixels',...
    'position',[120,50,20,15],'string','[?]',...
    'callback',@q_call,'visible','off');
% third checkbox callback
    function c_call(varargin)
        if mod(t,2)
            set(h.t,'visible','on');
            set(h.e,'visible','on');
            set(h.q,'visible','on');
        elseif ~mod(t,2)
            set(h.t,'visible','off');
            set(h.e,'visible','off');
            set(h.q,'visible','off');
        end
        t=t+1;
    end
    function q_call(varargin)
        q.f = figure('units','pixels','position',[200,200,220,80],...
            'toolbar','none','menu','none');
        q.t = uicontrol('style','text','units','pixels',...
            'position',[5,5,215,75],'string',...
            'This will let you define the sample rate to plot. One sample in this case is a complete run from fully concave to fully convex. Use this to analyse intra-trial progress of subjects depth perception');
    end


% Create OK pushbutton
h.p = uicontrol('style','pushbutton','units','pixels',...
    'position',[30,5,70,20],'string','done',...
    'callback',@p_call);

% Pushbutton callback
    function p_call(varargin)
        p=inputParser;
        p.addOptional('Samplerate',1,@isnumeric); %%%%%%%%%%%%%%
        
        vals = get(h.c,'Value');
        vals2 = get(h.e,'String');
        in = find([vals{:}]);
        sr = [str2double(vals2)];
        close all
    end

uiwait

end

function VtCData=VexToCave(Data)
Seq=Data.exp_conditionSequence{1};
uSeq=unique(Seq);
VtCseq(1,:)=uSeq(1:0.5*numel(uSeq));
VtCseq(2,:)=uSeq(0.5*numel(uSeq)+1:numel(uSeq));
SeqLength=size(VtCseq,2);
iSeqStart=[strfind(Seq,VtCseq(1,:)),strfind(Seq,VtCseq(2,:))];

iD=zeros(1,numel(Seq));
for s=1:numel(iSeqStart);
    iD(iSeqStart(s):iSeqStart(s)+SeqLength-1)=1;
end
iD=logical(iD);

if Data.N~=numel(iD) %N check
    iD=iD(1:Data.N);
end

names=fieldnames(Data);
names=names(1:end-1); %remove data.N
for n=1:numel(names)
    VtCData.(names{n})=Data.(names{n})(iD);
end
end

function CtVData=CaveToVex(Data)
Seq=Data.exp_conditionSequence{1};
uSeq=unique(Seq);
CtVseq(1,:)=uSeq(0.5*numel(uSeq):-1:1);
CtVseq(2,:)=uSeq(numel(uSeq):-1:0.5*numel(uSeq)+1);
SeqLength=size(CtVseq,2);
iSeqStart=[strfind(Seq,CtVseq(1,:)),strfind(Seq,CtVseq(2,:))];

iD=zeros(1,numel(Seq));
for s=1:numel(iSeqStart);
    iD(iSeqStart(s):iSeqStart(s)+SeqLength-1)=1;
end
iD=logical(iD);

if Data.N~=numel(iD) %N check
    iD=iD(1:Data.N);
end

names=fieldnames(Data);
names=names(1:end-1); %remove data.N
for n=1:numel(names)
    CtVData.(names{n})=Data.(names{n})(iD);
end
end

function D=DiffSr(Data,sr)
% pick a sampling rate to plot in subplots. this to see improvements over
% different trials.
Seq=Data.exp_conditionSequence{1};
TrL=(numel(unique(Seq))/2)*sr; % x/2 because one unique sequence is a trial moving up and a trial moving down for.

names=fieldnames(Data);
names=names(1:end-1); %remove data.N

for nTr=1:numel(Seq)/TrL; %divide in the specific samples
    for n=1:numel(names)
        try
            D{nTr}.(names{n})=Data.(names{n})((1+TrL*(nTr-1)):(TrL*nTr));
        catch ME
            keyboard
        end
    end
end
end

function xylbl()
xlabel('Fraction of realistic disparity','FontSize',8);
ylabel('Fraction convex reported','FontSize',8);
end

function supxylbl()
suplabel('Fraction of realistic disparity');
suplabel('Fraction convex reported','y');
end
