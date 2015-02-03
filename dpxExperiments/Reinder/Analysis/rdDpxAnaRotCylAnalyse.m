function D=rdDpxAnaRotCylAnalyse(fignum,D)
if nargin==0
    fignum=1;
    D=[];
end
if nargin==1 || isempty(D)
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


% for f=1:numel(D.halfInducerCyl_dotRGBA1frac)
%     if D.halfInducerCyl_dotRGBA2frac{f}==D.halfInducerCyl_dotRGBA1frac{f}
%         if D.halfInducerCyl_stereoLumCorr(1)==-1
%         warning(['this trial has a full white stimulus, but with a antistereo tag at trial ' num2str(f)])
% %         D=rdDpxCorCheckFix(D);
% %         break
%         end
%     end
% end
[M S B AS MDS lbl]=Divide(D,exp);
clear B

if fignum==2
    expId=[exp.Id ' two'];
    dpxFindFig(expId);
else
    dpxFindFig(exp.Id);
end
clf;

if isfield(exp,'Shift')
    labels={'mono','stereo',lbl.varLbl,lbl.varLblshift};
else
    labels={'mono','stereo',lbl.varLbl};
end
    subplot(1,2,1);


h(1)=plotPsychoCurves(M,exp.monoCueFog,exp.resp,exp.Id,exp.speed,'*r:','LineWidth',3);
h(2)=plotPsychoCurves(S,exp.stereoCue,exp.resp,exp.Id,exp.speed,'or-','LineWidth',2);
if exist('B','var');
    h(3)=plotPsychoCurves(B,exp.monoCueFog,exp.resp,exp.Id,exp.speed,'ob-','LineWidth',2);
elseif exist('AS','var');
    h(3)=plotPsychoCurves(AS,exp.stereoCue,exp.resp,exp.Id,exp.speed,'ob-','LineWidth',2);
end
if isfield(exp,'Shift')
    h(4)=plotPsychoCurves(MDS,exp.stereoCue,exp.resp,exp.Id,exp.speed,'sb--','LineWidth',1);
end
title(exp.name)
ylabel(exp.corPerc)
legend(h,labels);
subplot(1,2,2);
h(1)=plotPsychoCurves(M,exp.speed,'DownArrow',[],[],'r:','LineWidth',3);
h(2)=plotPsychoCurves(S,exp.speed,'DownArrow',[],[],'Color',[0 .5 0],'LineWidth',2);
if exist('B','var');
    h(3)=plotPsychoCurves(B,exp.speed,'DownArrow',[],[],'b','LineWidth',1);
elseif exist('AS','var');
    h(3)=plotPsychoCurves(AS,exp.speed,'DownArrow',[],[],'b','LineWidth',1);
else
    %nothing
end
legend(h,labels);

if strcmpi(input('calc freezing? Y/N','s'),'y')
    perc=FreezePerc(D.resp_rightHand_keyName);
    D.freeze=perc;
end
end

function  h=plotPsychoCurves(D,fieldstr,keyname,Id,speed,varargin)
E=dpxdSplit(D,fieldstr);
if strcmp(Id,'bind')
    for ee=1:numel(E) %remove the zero disp in bind because onredelijk
        if E{ee}.(fieldstr)==0
            E(ee)=[];
            break
        end
    end
end
if strcmp(Id,'bind')
    for e=1:numel(E)
        if E{e}.(fieldstr)==0
            continue
        else
        x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
        for s=1:numel(E{e}.(speed))
            if E{e}.(fieldstr)(s)>0
                if E{e}.(speed)(s)>0
                    corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'UpArrow');
                else
                    corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'DownArrow');
                end
            end
            if E{e}.(fieldstr)(s)<0
                if E{e}.(speed)(s)>0
                    corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'DownArrow');
                else
                    corKey(s)=strcmp(E{e}.resp_rightHand_keyName(s),'UpArrow');
                end
            end
            if E{e}.(fieldstr)(s)==0
                corKey(s)=1;
            end
        end
        y(e)=mean(corKey);
        clear corKey
        end
    end
elseif strcmp(Id,'fullFb');
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
axis([-1 1 0 100]);
dpxPlotHori(50,'k--');
dpxPlotVert(0,'k--');
xlabel(fieldstr(fieldstr~='_'));
hold on;

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
    if isfield(data,'halfInducerCyl_monoDispShift')
        if sum(data.halfInducerCyl_monoDispShift)==0
        else
        exp.Shift='halfInducerCyl_monoDispShift';
        end
    end
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
    if isfield(data,'halfInducerCyl_monoDispShift')
        if sum(data.halfInducerCyl_monoDispShift)==0
        else
        exp.Shift='halfInducerCyl_monoDispShift';
        end
    end
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

function perc=FreezePerc(resp)
for r=1:numel(resp)-1
    if strcmpi(resp{r},resp{r+1})
        freeze(r)=1;
    else
        freeze(r)=0;
    end
end
perc.freeze=freeze;
perc.freezetotal=sum(freeze)/numel(freeze);

i=1;
q=1;
tmp=[];
for r=1:numel(resp)-1
    if strcmpi(resp{r},resp{r+1})
        tmp(q)=1;
        q=q+1;
    else
        perc.freezelength(i)=numel(tmp);
        tmp=[];
        i=i+1;
        q=1;
    end
end
perc.mean.length=mean(perc.freezelength);
perc.mean.sem=std(perc.freezelength)/sqrt(length(perc.freezelength));
end


% function D=rdDpxCorCheckFix(D)
% for f=1:numel(D.halfInducerCyl_stereoLumCorr)
%     if D.halfInducerCyl_dotRGBA2frac{f}==D.halfInducerCyl_dotRGBA1frac{f}
%         D.halfInducerCyl_stereoLumCorr(f)=1
%     end
% end
% end

function     [M S B AS MDS lbl]=Divide(D,exp)
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
if isfield(exp,'Shift')
    MDS=dpxdSubset(D,dispShifted);
    lbl.varLblshift='Mono Disp Shift';
else
    MDS=0;
end

        
        
        
end
