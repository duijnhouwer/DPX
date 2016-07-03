function [dispX,dispY]=rdScat(varargin)
% Scatterplog of all the data in specified folder

whichSet = 'random'; % 'random' or 'blocked'

supdir=uigetdir('D:\Users\Reinder\Documents\School\Masterstage Stereoblind\DATA processing\Scatterplot\baselines','Select baseline folder');
subdir{1}='\scoop'; subdir{2}='\blind';

plotStyles{1} = {...
    'MarkerEdgeColor','k'...
    'MarkerFaceColor','w'};

plotStyles{2} = {...
    'MarkerEdgeColor','k'...
    'MarkerFaceColor','k'};


for s=[1 2];
    pname = [supdir subdir{s}];
    fn = dir(pname);
    fnames = {fn(3:end).name};
        
    fnames=isBaseline(fnames);
    fnames=getBinding(fnames,pname,whichSet);
    data=LoadBoth(fnames,pname,whichSet);
    
    % P = GetPropZData(data.baseData,Xs);
    
    
    [Yfar Ynear disps] = GetBindQuota(data.bindData);
    X = GetFitData(data.baseData,disps);
    
    for y=1:size(Yfar,2)
        Y{y}=Yfar{1,y}-Ynear{y};
    end
    

    figure(1)
    plotScat(X,Y,plotStyles{s}); hold on;
    title(['binding vs depth differentiation, ' whichSet])        
    xlabel('depth perception strength: modelled far - near'); ylabel('binding strength (%): far - near');
    ylim([-0.6 0.6])
    xlim([-1.1 0.3])
    
    keyboard;

        
    % figure(6)
    % plotScat(X,Ynear,'bx')
    % title('near binding')
    % xlabel(lbl{1}); ylabel(lbl{2});
    %
    % figure(7)
    % plotScat(X,Yfar,'gp')
    % title('far binding')
    % xlabel(lbl{1}); ylabel(lbl{2});
        
    % kmeansplot(X,Y,3) %insert k value
    
    clear fnames
    dispX{s}=X;
    dispY{s}=Y;
end
hold off;

keyboard

legend('stereoscopic','stereoblind');

nicePlot;

end

function fnames=isBaseline(fnames)
i=1;
for f=1:numel(fnames)
    if ~strcmp(fnames{f}(1:23),'rdDpxExpBaseLineCylLeft')
        iFaulty(i)=f; %#ok
        i=i+1;
    else
        iFaulty=0;
    end
end
if iFaulty==1
    warning('Data:NonBaseline','Found one non-baseline file: %s',fnames{iFaulty});
    if strcmpi('y',input('Remove this for further analysis? Y/N >> ','s'));
        fnames(iFaulty)=[];
        d=['removed ' fnames{iFaulty} ' from further analysis'];
        disp(d)
    end
elseif iFaulty>=1
    warning('Data:NonBaseline',['Found ' num2str(numel(iFaulty)) ' non-baseline files'])
    ipt=input('Remove all, view files, Keep all? R/C/K >> ','s');
    if strcmpi(ipt,'R')
        for fa=1:numel(iFaulty)
            d=['removed ' fnames{iFaulty(fa)}];
            disp(d)
        end
        fnames(iFaulty)=[];
        d=['removed ' num2str(numel(iFaulty)) ' files from further analysis'];
        disp(d)
    elseif strcmpi(ipt,'C')
        for fa=1:numel(iFaulty)
            d=[fnames{iFaulty(fa)}];
            disp(d)
            keyboard
        end
    elseif strcmpi(ipt,'K')
        disp('Keeping files, this will prolly error')
    end
end
end

function linkfnames=getBinding(fnames,pname,which)
bipname=pname(1:end-15);
bipname=[bipname 'bindings\' which '\'];

files=dir(bipname);
for bif=4:numel(files) %skip . , ... and txtfile
    bifnames(bif-3)={files(bif).name};
end
for c=1:numel(fnames)
    checkList{c}=fnames{c}(17:29);
end
for c=1:numel(bifnames)
    checkBiList{c}=bifnames{c}(16:28);
end

linkableBaselines=ismember(checkList,checkBiList);

if sum(linkableBaselines)==0
    error('no binding experiments for this set of baselines')
end
linkfnames=fnames(linkableBaselines);
for f=1:numel(linkfnames)
    iBi=strfind(bifnames,linkfnames{1,f}(17:29)); %look for specific name part
    iBi=~cellfun(@isempty,iBi);
    linkfnames(2,f)=bifnames(iBi);
    clear iBi
    
end

nonlinkableBaselines=~ismember(checkList,checkBiList);
nonfnames=fnames(nonlinkableBaselines);
disp(nonfnames')

end

function data=LoadBoth(fnames,pname,which);
bipname=pname(1:end-15);
bipname=[bipname 'bindings\' which '\'];
bapname =[pname '\'];

for l=1:size(fnames,2)
    data.baseData{l}=load([bapname fnames{1,l}]); %load base data
    data.bindData{l}=load([bipname fnames{2,l}]); %load bind data
end
end

function [X sigma] = GetFitData(data,Xs)
for d=1:numel(data)
    %loop through each subject
    
    D=data{d}.DPXD;
    exp=whichExp(D);
    if ~isstruct(exp) %check if data fits
        continue
    end
    
    oldN=D.N;
    D=dpxdSubset(D,D.resp_rightHand_keyNr>0);
    
    Sdata=findStereo(D,exp);
    
    [mu sigma{1,d}]=sigfit(Sdata,exp.stereoCue,exp.resp); %#ok
    if sigma{1,d}>0
        calcX = normcdf(Xs{d},mu,sigma{1,d});
        difX = calcX(1)-calcX(2); %far - near
    elseif sigma{1,d}<0
        calcX = normcdf(Xs{d},mu,sigma{1,d}*-1);
        calcX = [1-calcX(1) 1-calcX(2)];
        difX  = calcX(1)-calcX(2);
    elseif sigma{1,d}==0;
        continue;
        difX = NaN;
    end
    
    X{1,d} = difX;
    X{2,d} = Sdata.exp_subjectId{1};
end
end

function exp=whichExp(data)
try
    if strcmpi(data.exp_paradigm(1),'rdDpxExpRotFullCylFeedback') || strcmpi(data.exp_paradigm(1),'rdDpxExpRotFullCylLeftFeedback') || strcmpi(data.exp_paradigm(1),'rdDpxExpRotFullCylRightFeedback');
        warnstr=['warning fullcyl experiment detected in: ' data.exp_paradigm{1} ', sbjct:' data.exp_subjectId{1} '\n deleting from current analysis'];
        error(warnstr)
        
    elseif strcmpi(data.exp_paradigm(1),'rdDpxExpRotHalfCylLeftFeedback')  || strcmpi(data.exp_paradigm(1),'rdDpxExpRotHalfCylRightFeedback');
        warnstr=['warning fullcyl experiment detected in: ' data.exp_paradigm{1} ', sbjct:' data.exp_subjectId{1} '\n deleting from current analysis'];
        error(warnstr)
    elseif strcmpi(data.exp_paradigm(1),'rdDpxExpBaseLineCylLeft') || strcmpi(data.exp_paradigm(1),'rdDpxExpBaseLineCylRight');
        exp.Id='base';
        exp.name=['subject ' data.exp_subjectId{1} ': shape of half cylinder w/o feedback'];
        exp.monoCueFog='halfInducerCyl_fogFrac';
        exp.monoCueDiam='halfInducerCyl_dotDiamScaleFrac';
        exp.stereoCue='halfInducerCyl_disparityFrac';
        exp.lummCor='halfInducerCyl_stereoLumCorr';
        exp.speed='halfInducerCyl_rotSpeedDeg';
        exp.resp='DownArrow';
        exp.corPerc='reported percept, % convex';
        if isfield(data,'halfInducerCyl_monoDispShift')
            if sum(data.halfInducerCyl_monoDispShift)==0
            else
                exp.Shift='halfInducerCyl_monoDispShift';
            end
        end
    elseif strcmpi(data.exp_paradigm(1),'rdDpxExpBindingCylLeft')...
            || strcmpi(data.exp_paradigm(1),'rdDpxExpBindingCylRight')
        exp.Id='bind';
        exp.name=['subject ' data.exp_subjectId{1} ': percept of full cyl (context-driven)'];
        exp.monoCueFog='halfInducerCyl_fogFrac';
        exp.monoCueDiam='halfInducerCyl_dotDiamScaleFrac';
        exp.stereoCue='halfInducerCyl_disparityFrac';
        exp.lummCor='halfInducerCyl_stereoLumCorr';
        exp.speed='halfInducerCyl_rotSpeedDeg';
        exp.resp='DownArrow';
        exp.corPerc='correct perception of target base on phys of inducer';
        if isfield(data,'halfInducerCyl_monoDispShift')
            if sum(data.halfInducerCyl_monoDispShift)==0
            else
                exp.Shift='halfInducerCyl_monoDispShift';
            end
        end
    elseif strcmpi(data.exp_paradigm(1),'rdDpxExpCentreBindCyl')
        warnstr=['warning centrecyl experiment detected in: ' data.exp_paradigm{1} ', sbjct:' data.exp_subjectId{1} '\n deleting from current analysis'];
        error(warnstr)
    end
catch ME
    exp=ME
end
end

function S=findStereo(data,exp)
D=data;
if isfield(exp,'Shift')
    mono=D.(exp.stereoCue)==0 & D.(exp.Shift)==0;
    stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1 & D.(exp.Shift)==0;
    antistereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==-1 & D.(exp.Shift)==0; %#ok ignore for now
    dispShifted=D.(exp.Shift)==1; %#ok ignore for now
else
    mono=D.(exp.stereoCue)==0;
    stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1;
    antistereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==-1; %#ok ignore for now
end
S=dpxdSubset(D,stereo | mono&stereo);

end

function [mu sigma]=sigfit(D,Cue,Key)
X = unique(D.(Cue));
for nX = 1:numel(X)
    xVals(nX) = X(nX);%#ok
    iX =  D.(Cue)==xVals(nX);
    yVals(nX) = sum(strcmpi(D.resp_rightHand_keyName(iX),Key));%#ok
    yMax(nX)  = numel(D.resp_rightHand_keyName(iX));%#ok
end
try
    s = SigFit([xVals' yVals' yMax']);
    s.mu = s.params.est(1);
    s.sigma = s.params.est(2);
    s.Notsig=false;
catch me
    me.identifier
    s.mu=[]; s.sigma=[];
    s.Notsig=true;
end
if s.Notsig
    warning('Data is not sigmoidal')%#ok
    s.mu=0;
    s.sigma=0;
end
mu=s.mu;
sigma=s.sigma;
end

function [Yfar Ynear Xs] = GetBindQuota(data)
for d=1:numel(data)
    try
        D=data{d}.DPXD;
      catch me
        if strcmp(me.identifier,'MATLAB:nonExistentField')
            D=data{d}.D
        else
            error('something wrong with the way data is named')
        end
    end  
        exp=whichExp(D);
        if ~isstruct(exp)
            continue
        end
        
        mindisp = min(D.(exp.stereoCue));
        maxdisp = max(D.(exp.stereoCue));
        Xs{d} = [mindisp maxdisp];
        
    
    
    
    exp=whichExp(D);
    if ~isstruct(exp)
        continue
    end
    
    oldN=D.N;
    D=dpxdSubset(D,D.resp_rightHand_keyNr>0);
    
    Sdata=findStereo(D,exp);
    
    E=dpxdSplit(Sdata,exp.stereoCue);
    i=1;
    for e=1:numel(E)
        if all(roundn(mean(E{e}.(exp.stereoCue)),-1)~=Xs{d});
            %nothing we looking for the outer X'ses
        else
            Dcheck{i}=E{e};
            i=i+1;
        end
    end
    if ~exist('Dcheck','var') || numel(Dcheck)~=2
        warning('disparitys screwed up in binding data, not compatible with base')
        keyboard
    end
    
    %     Y(d)=bindingDiff(Sdata,exp.stereoCue,exp.resp,exp.Id,exp.speed);
    %
    %     function scatY=bindingDiff(Sdata,Cue,resp,Id,speed);
    
    E=dpxdSplit(Sdata,exp.stereoCue);
    i=1;
    for e=1:numel(E)
        if all(roundn(mean(E{e}.(exp.stereoCue)),-1)~=Xs{d});
            %nothing
        else
            DD{i}=E{e};
            i=i+1;
        end
    end
    if ~exist('DD','var') || numel(DD)~=2
        warning('disparity not or too much in dataset. go fix stuff')
        keyboard
    end
    for dd=1:numel(DD)
        for s=1:numel(DD{dd}.(exp.speed))
            if DD{dd}.(exp.stereoCue)(s)>0
                if DD{dd}.(exp.speed)(s)>0
                    corKey(s)=strcmp(DD{dd}.resp_rightHand_keyName(s),'UpArrow');
                else
                    corKey(s)=strcmp(DD{dd}.resp_rightHand_keyName(s),'DownArrow');
                end
            end
            if DD{dd}.(exp.stereoCue)(s)<0
                if DD{dd}.(exp.speed)(s)>0
                    corKey(s)=strcmp(DD{dd}.resp_rightHand_keyName(s),'DownArrow');
                    
                else
                    corKey(s)=strcmp(DD{dd}.resp_rightHand_keyName(s),'UpArrow');
                    
                end
            end
        end
        ana(dd).mean=mean(corKey);
        ana(dd).disp=mean(DD{dd}.(exp.stereoCue));
        clear corKey
    end
    % everything gone right, we got something like mean = xx xx , disp = -1 1
    Yfar{1,d}  = ana(1).mean; % diff between far and near: FAR minus NEAR
    Ynear{1,d} = ana(2).mean;
    Yfar{2,d} = DD{1}.exp_subjectId{1};
    clear ana
end


end

function plotScat(X,Y,varargin)

for i=1:size(X,2)
    xvec(i)=cell2mat(X(1,i));
    yvec(i)=cell2mat(Y(1,i));
end

scatter(xvec,yvec,varargin{1}{:},'jitter','on','jitterAmount',0.025)

end

function kmeansplot(X,Y,k)
for i=1:size(X,2)
    K(1,i)=X{1,i};
end
for i=1:size(Y,2)
    K(2,i)=Y{1,i};
end
K=K';
idx = kmeans(K,3);

figure;
hold on;
for i=1:k
    clust{i}=K(idx==i,:);
    if i==1
        plot(clust{i}(:,1),clust{i}(:,2),'bo')
    elseif i==2
        plot(clust{i}(:,1),clust{i}(:,2),'rx')
    elseif i==3
        plot(clust{i}(:,1),clust{i}(:,2),'gs')
    elseif i==4
        error('make bigger cluster plot')
    end
end
end

function P = GetPropZData(data,disp)
for d = 1:numel(data)
    
    D = data{d}.data;
    
    exp = whichExp(D);
    if ~isstruct(exp) %check if data fits
        continue
    end
    
    oldN = D.N;
    D = dpxdSubset(D,D.resp_rightHand_keyNr>0);
    
    Sdata = findStereo(D,exp);
    
    Xfar = dpxdSubset(Sdata,Sdata.halfInducerCyl_disparityFrac==disp(1));
    if isempty(Xfar); keyboard; end
    Xnear = dpxdSubset(Sdata,Sdata.halfInducerCyl_disparityFrac==disp(2));
    if isempty(Xnear); keyboard; end
    
    Z = PropZ(Xfar,Xnear);
    if sign(Z)==1
        Z=Z*-1;
    end
    P{d} = normcdf(Z,0,1);
    
end
    function Z = PropZ(Xfar,Xnear)
        for i=1:Xfar.N
            if strcmp(Xfar.resp_rightHand_keyName{i},'UpArrow')
                CorKey(i) = 1;
            else
                CorKey(i) = 0;
            end
        end
        P1 = mean(CorKey);
        N1 = numel(CorKey);
        clear CorKey
        
        for i=1:Xnear.N
            if strcmp(Xnear.resp_rightHand_keyName{i},'DownArrow')
                CorKey(i) = 0;
            else
                CorKey(i) = 1;
            end
        end
        P2 = mean(CorKey);
        N2 = numel(CorKey);
        clear CorKey
        
        Pool    = (P1*N1+P2*N2)/(N1+N2);
        SE      = sqrt(Pool*(1-Pool)*((1/N1)+(1/N2)));
        Z       = (P1-P2)/SE;
    end
end
