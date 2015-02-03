function ZAna = rdDpxAvgBar(disps,D)
% average and t-test for 2 value's: near and far.
% makes a barplot with error bars (std) and a nice asterix if significant
% :)
% only for stereo
% D input is optional data. If not given will be asked to select manually.

if nargin==1 || isempty(D)
    fnames=dpxUIgetfiles;
    for f=1:numel(fnames)
        load(fnames{f});
        D{f}=data;    
    end
end
D=dpxTblMerge(D);
if isequal(D.exp_expName{1:D.N})
    exp=whichExp(D);
else
    error('you have selected to average different experiments. you suck')
end

D=dpxTblSplit(D,'exp_subjectId');

for d=1:numel(D)

mono=D{d}.(exp.stereoCue)==0;
stereo=D{d}.(exp.monoCueFog)==0 & D{d}.(exp.monoCueDiam)==0 & D{d}.(exp.lummCor)==1; %D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1;
EE=dpxTblSubset(D{d},stereo | mono&stereo);
EE=dpxTblSplit(EE,exp.stereoCue);



i=1;
for ee=1:numel(EE) 
    if all(roundn(mean(EE{ee}.(exp.stereoCue)),-1)~=disps)
        %nothing
    else
        E{i}=EE{ee}; %#ok
        i=i+1;
    end
end
if ~exist('E','var')
    error('your selected disparities are not in the data set. please check this')
end
Dt{d}.ZAna=cell(1,numel(E));
for e=1:numel(E)
    corKey=zeros(1,numel(E{e}.(exp.speed)));
    for s=1:numel(E{e}.(exp.speed))
        if E{e}.(exp.stereoCue)(s)>0 %comment out if motion only
            if E{e}.(exp.speed)(s)>0
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'UpArrow');
            else
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'DownArrow');
            end
%             % comment out if motion only >>>>>>>>>>>>
        end
        if E{e}.(exp.stereoCue)(s)<0
            if E{e}.(exp.speed)(s)>0
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'DownArrow');
            else
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'UpArrow');
            end
        end
        if E{e}.(exp.stereoCue)(s)==0
            corKey(s)=1;
        end % <<<<<<<<<<<<
    end
    
    Dt{d}.ZAna{e}.Data = corKey;
    Dt{d}.ZAna{e}.Disp = mean(E{e}.(exp.stereoCue));
    Dt{d}.ZAna{e}.ZMean = mean(corKey);
    clear corKey
    
    

end
end

for iDt=1:numel(Dt)
    Far(iDt)=Dt{iDt}.ZAna{1}.ZMean;
    Near(iDt)=Dt{iDt}.ZAna{2}.ZMean;
end
avgFar=mean(Far)
avgNear=mean(Near)
stdFar=std(Far)
stdNear=std(Near)
semFar=stdFar/sqrt(numel(Dt));
semNear=stdNear/sqrt(numel(Dt));
    
    
barwitherr([semNear semFar],[-1 1],[avgNear avgFar],'b');
[h p]=ttest(Far,Near);

ylim([0 1]);
set(gca,'XTick',[-1 1],'XTickLabel',{'Near' 'Far'});
set(gca,'YTick',0:.1:1,'YTickLabel',0:10:100);

if strcmpi(input('calculate different from 50% point? Y/N','s'),'y')
        [hFar,pFar]=ttest(Far,0.5)
        [hNear,pNear]=ttest(Near,0.5)
end
        

% name=[data.exp_expName{1} ' ' data.exp_subjectId{1} ' proportion Z tested'];
% title(name);
nB=['P = ' num2str(p)];
text(0.5,0.9,nB)
ylabel('% coupling')
xlabel('Disparity defined side')
Ntxt=['N = ' num2str(numel(Dt))];
text(-1.5, 0.9, Ntxt);

if p<0.05 ;
    hold on
    intervalX=[-1 -1 1 1 ];
    intervalY=[max([avgFar avgNear])+0.1 max([avgFar avgNear])+0.15 max([avgFar avgNear])+0.15 max([avgFar avgNear])+0.1];
    plot(intervalX,intervalY,'k');
    text(0, max([avgFar avgNear])+0.17,'*','FontSize',22);
end
end

function exp=whichExp(data)
if strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylFeedback') || strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylLeftFeedback') || strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylRightFeedback');
    exp.Id='fullFb';
    exp.name=['subject ' data.exp_subjectId{1} ': one full cylinder w/ feedback'];
    exp.monoCueFog='fullCyl_fogFrac';
    exp.monoCueDiam='fullCyl_dotDiamScaleFrac';
    exp.stereoCue='fullCyl_disparityFrac';
    exp.lummCor='fullCyl_stereoLumCorr';
    exp.speed='fullCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='reported correct percept of front plane';
elseif strcmpi(data.exp_expName(1),'rdDpxExpRotHalfCylLeftFeedback')  || strcmpi(data.exp_expName(1),'rdDpxExpRotHalfCylRightFeedback');
    exp.Id='halfFb';
    exp.name=['subject ' data.exp_subjectId{1} ': half cylinder w/ feedback'];
    exp.monoCueFog='halfCyl_fogFrac';
    exp.monoCueDiam='halfCyl_dotDiamScaleFrac';
    exp.stereoCue='halfCyl_disparityFrac';
    exp.lummCor='halfCyl_stereoLumCorr';
    exp.speed='halfCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='reported convex';
elseif strcmpi(data.exp_expName(1),'rdDpxExpBaseLineCylLeft') || strcmpi(data.exp_expName(1),'rdDpxExpBaseLineCylRight');
    exp.Id='base';
    exp.name=['subject ' data.exp_subjectId{1} ': shape of half cylinder w/o feedback'];
    exp.monoCueFog='halfInducerCyl_fogFrac';
    exp.monoCueDiam='halfInducerCyl_dotDiamScaleFrac';
    exp.stereoCue='halfInducerCyl_disparityFrac';
    exp.lummCor='halfInducerCyl_stereoLumCorr';
    exp.speed='halfInducerCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='reported percept, % convex';
elseif strcmpi(data.exp_expName(1),'rdDpxExpBindingCylLeft')...
        || strcmpi(data.exp_expName(1),'rdDpxExpBindingCylRight')
    exp.Id='bind';
    exp.name=['subject ' data.exp_subjectId{1} ': percept of full cyl (context-driven)'];
    exp.monoCueFog='halfInducerCyl_fogFrac';
    exp.monoCueDiam='halfInducerCyl_dotDiamScaleFrac';
    exp.stereoCue='halfInducerCyl_disparityFrac';
    exp.lummCor='halfInducerCyl_stereoLumCorr';
    exp.speed='halfInducerCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='correct perception of target base on phys of inducer';
elseif strcmpi(data.exp_expName(1),'rdDpxExpCentreBindCyl')
    exp.Id='bind';
    exp.name=['subject ' data.exp_subjectId{1} ': percept of full cyl (context-driven)'];
    exp.monoCueFog='leftHalfInducerCyl_fogFrac';
    exp.monoCueDiam='leftHalfInducerCyl_dotDiamScaleFrac';
    exp.stereoCue='leftHalfInducerCyl_disparityFrac';
    exp.lummCor='leftHalfInducerCyl_stereoLumCorr';
    exp.speed='leftHalfInducerCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='correct perception of target base on phys of inducer';
end
end