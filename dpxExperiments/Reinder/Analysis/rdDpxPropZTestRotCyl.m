function ZAna = rdDpxPropZTestRotCyl(disps,D)
% Z proportion test for 2 value's: near and far.
% makes a barplot with error bars (std) and a nice asterix if significant
% :)
% only for stereo

if nargin==1 || isempty(D)
    fnames=dpxUIgetfiles;
    for f=1:numel(fnames)
        load(fnames{f});
        D{f}=data;
    end
end
D=dpxTblMerge(D);
exp=whichExp(D);

mono=D.(exp.stereoCue)==0;
stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1;
EE=dpxTblSubset(D,stereo | mono&stereo);

EE=dpxTblSplit(D,exp.stereoCue);


i=1;
for ee=1:numel(EE) 
    if all(roundn(mean(EE{ee}.(exp.stereoCue)),-1)~=disps)
        %nothing
    else
        E{i}=EE{ee}; %#ok
        i=i+1;
    end
end
ZAna=cell(1,numel(E));
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
    
    ZAna{e}.Data = corKey;
    ZAna{e}.Disp = mean(E{e}.(exp.stereoCue));
    ZAna{e}.ZMean = mean(corKey);
    ZAna{e}.ZStd = std(corKey);
    ZAna{e}.Interval = [ZAna{e}.ZMean-ZAna{e}.ZStd ZAna{e}.ZMean+ZAna{e}.ZStd];
    
end
P  = (ZAna{1}.ZMean*numel(ZAna{1}.Data)+ZAna{2}.ZMean*numel(ZAna{2}.Data))/(numel(ZAna{2}.Data)+numel(ZAna{2}.Data));
SE = sqrt(P*(1-P)*(1/numel(ZAna{1}.Data)+1/numel(ZAna{2}.Data)));
Z  = (ZAna{1}.ZMean-ZAna{2}.ZMean)/SE;
Y=normcdf(Z,0,1);

figure;
bar([ZAna{1}.Disp ZAna{2}.Disp],[ZAna{1}.ZMean ZAna{2}.ZMean],'r');

% barwitherr([ZAna{1}.ZStd ZAna{2}.ZStd],[ZAna{1}.Disp ZAna{2}.Disp],[ZAna{1}.ZMean ZAna{2}.ZMean],'r');
iY=[ZAna{1}.ZMean ZAna{2}.ZMean];
ylim([0 1]);
name=[data.exp_expName{1} ' ' data.exp_subjectId{1} ' proportion Z tested'];
title(name);
nB=['P(Z < ' num2str(Z) ') = ' num2str(Y)];
text(ZAna{2}.Disp-0.5,0.9,nB)

if Y<0.05;
    hold on
    intervalX=[ZAna{1}.Disp ZAna{1}.Disp ZAna{2}.Disp ZAna{2}.Disp];
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