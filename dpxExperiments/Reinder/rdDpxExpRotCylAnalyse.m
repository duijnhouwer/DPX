function D=rdDpxExpRotCylAnalyse(D)
if nargin==0 || isempty(D)
    fnames=dpxUIgetfiles;
    for f=1:numel(fnames)
        load(fnames{f});
        D{f}=data;
    end
end
D=dpxdMerge(D);
oldN=D.N;
exp=whichExp(D);
% Remove all trials in which no response was given
D=dpxdSubset(D,D.resp_rightHand_keyNr>0);
disp(['Discarded ' num2str(oldN-D.N) ' out of ' num2str(oldN) ' trials for lack of response.']);
%
mono=D.(exp.stereoCue)==0;
stereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==1;
antistereo=D.(exp.monoCueFog)==0 & D.(exp.monoCueDiam)==0 & D.(exp.lummCor)==-1;
M=dpxdSubset(D,mono | mono&stereo);
S=dpxdSubset(D,stereo | mono&stereo);
if strcmp(exp.Id,'fullFb') || strcmp(exp.Id,'halfFb');
    B=dpxdSubset(D,~mono&~stereo | mono&stereo);
    varLbl='both';
else
    AS=dpxdSubset(D,antistereo | mono&antistereo);
    varLbl='anti-stereo';
end
dpxFindFig('rdDpxExpRotCylAnalyse');
clf;

labels={'mono','stereo',varLbl};
subplot(1,2,1);
h(1)=plotPsychoCurves(M,exp.monoCueFog,exp.resp,exp.Id,exp.speed,'r-','LineWidth',3);
h(2)=plotPsychoCurves(S,exp.stereoCue,exp.resp,exp.Id,exp.speed,'Color',[0 .5 0],'LineWidth',2);
if exist('B','var');
    h(3)=plotPsychoCurves(B,exp.monoCueFog,exp.resp,exp.Id,exp.speed,'b','LineWidth',1);
elseif exist('AS','var');
    h(3)=plotPsychoCurves(AS,exp.stereoCue,exp.resp,exp.Id,exp.speed,'b','LineWidth',1);
end
title(exp.name)
ylabel(exp.corPerc)
legend(h,labels);
subplot(1,2,2);
h(1)=plotPsychoCurves(M,exp.speed,'DownArrow',[],[],'r-','LineWidth',3);
h(2)=plotPsychoCurves(S,exp.speed,'DownArrow',[],[],'Color',[0 .5 0],'LineWidth',2);
if exist('B','var');
    h(3)=plotPsychoCurves(B,exp.speed,'DownArrow',[],[],'b','LineWidth',1);
elseif exist('AS','var');
    h(3)=plotPsychoCurves(AS,exp.speed,'DownArrow',[],[],'b','LineWidth',1);
end
legend(h,labels);

end

function  h=plotPsychoCurves(D,fieldstr,keyname,bind,speed,varargin)
E=dpxdSplit(D,fieldstr);
if strcmp(bind,'bind')
    for e=1:numel(E)
        x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
        for s=1:numel(E{e}.(speed))
            if E{e}.(speed)(s)>0
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'UpArrow');
            else
                corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'DownArrow');
            end
        end
        y(e)=mean(corKey);
        clear corKey
    end
else
    for e=1:numel(E)
        x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
        y(e)=mean(strcmpi(E{e}.resp_rightHand_keyName,keyname));
    end
end
h=plot(x,y*100,varargin{:});
axis([min(x) max(x) 0 100]);
dpxPlotHori(50,'k--');
dpxPlotVert(0,'k--');
xlabel(fieldstr(fieldstr~='_'));
hold on;
end

function exp=whichExp(data)
if strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylFeedback') || strcmpi(data.exp_expName(1),'rdDpxExpRotFullCylLeftFeedback');
    exp.Id='fullFb';
    exp.name=['subject ' data.exp_subjectId{1} ': one full cylinder w/ feedback'];
    exp.monoCueFog='fullCyl_fogFrac';
    exp.monoCueDiam='fullCyl_dotDiamScaleFrac';
    exp.stereoCue='fullCyl_disparityFrac';
    exp.lummCor='fullCyl_stereoLumCorr';
    exp.speed='fullCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='reported front plane down';
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
elseif strcmpi(data.exp_expName(1),'rdDpxExpBindingCylLeft') || strcmpi(data.exp_expName(1),'rdDpxExpBindingCylRight')
    exp.Id='bind';
    exp.name=['subject ' data.exp_subjectId{1} ': percept of full cyl (context-driven)'];
    exp.monoCueFog='halfInducerCyl_fogFrac';
    exp.monoCueDiam='halfInducerCyl_dotDiamScaleFrac';
    exp.stereoCue='halfInducerCyl_disparityFrac';
    exp.lummCor='halfInducerCyl_stereoLumCorr';
    exp.speed='halfInducerCyl_rotSpeedDeg';
    exp.resp='DownArrow';
    exp.corPerc='correct perception of target base on phys of inducer';
end
end

