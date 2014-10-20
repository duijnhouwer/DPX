function BootAna = rdDpxBootstrapRotCyl(nboot,disps,D)
% bootstrapping the data for rotcyl exps
% only for stereo

if nargin==2 || isempty(D)
    fnames=dpxUIgetfiles;
    for f=1:numel(fnames)
        load(fnames{f});
        D{f}=data;
    end
end
D=dpxdMerge(D);
exp=whichExp(D);

mono=D.(exp.stereoCue)==0;
stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1;
EE=dpxdSubset(D,stereo | mono&stereo);

EE=dpxdSplit(EE,exp.stereoCue);
i=1;
for ee=1:numel(EE) 
    if all(roundn(mean(EE{ee}.(exp.stereoCue)),-1)~=disps)
        %nothing
    else
        E{i}=EE{ee}; %#ok
        i=i+1;
    end
end
BootAna=cell(1,numel(E));
for e=1:numel(E)
    corKey=zeros(1,numel(E{e}.(exp.speed)));
    for s=1:numel(E{e}.(exp.speed))
        if E{e}.(exp.stereoCue)(s)>0
            if E{e}.(exp.speed)(s)>0
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'UpArrow');
            else
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'DownArrow');
            end
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
        end
    end
    
    BootAna{e}.Disp = mean(E{e}.(exp.stereoCue));
    BootAna{e}.bootData = bootstrp(nboot,@mean,corKey);
    BootAna{e}.bootMean = mean(BootAna{e}.bootData);
    BootAna{e}.bootSign = std(BootAna{e}.bootData);
    BootAna{e}.Interval = [BootAna{e}.bootMean-BootAna{e}.bootSign BootAna{e}.bootMean+BootAna{e}.bootSign];
    
end
figure;
barwitherr([BootAna{1}.bootSign BootAna{2}.bootSign],[BootAna{1}.Disp BootAna{2}.Disp],[BootAna{1}.bootMean BootAna{2}.bootMean],'r');
iY=[BootAna{1}.bootMean BootAna{2}.bootMean];
ylim([0 1]);
name=[data.exp_expName{1} ' ' data.exp_subjectId{1} ' with stdev'];
title(name);
nB=['nBoot = ' num2str(nboot)];
text(BootAna{2}.Disp,BootAna{1}.bootMean,nB)

if isempty(intersect(BootAna{1}.Interval,BootAna{2}.Interval));
    hold on
    intervalX=[BootAna{1}.Disp BootAna{1}.Disp BootAna{2}.Disp BootAna{2}.Disp];
    intervalY=[max(iY)+0.1 max(iY)+0.15 max(iY)+0.15 max(iY)+0.1];
    plot(intervalX,intervalY,'k');
    text(0, max(iY)+0.17,'*','FontSize',22);
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