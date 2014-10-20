function D=rdDpxExpRotCylAnalyseSplitSpeeds(D)

if nargin==0 || isempty(D)
    fnames=dpxUIgetfiles;
    for f=1:numel(fnames)
        load(fnames{f});
        D{f}=data;
    end
end
split=input('split rotspeeds? Y/N','s');
if isempty(split)
    split='n';
end

D=dpxdMerge(D);
oldN=D.N;
exp=whichExp(D);
% Remove all trials in which no response was given
D=dpxdSubset(D,D.resp_rightHand_keyNr>0);
disp(['Discarded ' num2str(oldN-D.N) ' out of ' num2str(oldN) ' trials for lack of response.']);
%


if strcmpi(split,'y')
    sUp=D.(exp.speed)>0;
    sDown=D.(exp.speed)<0;
    
    speed{1}=dpxdSubset(D,sUp);
    speed{2}=dpxdSubset(D,sDown);
end
for spd=1:numel(speed)
    
    mono=speed{spd}.(exp.stereoCue)==0;
    stereo=speed{spd}.(exp.monoCueFog)==0 & speed{spd}.(exp.monoCueDiam)==0 & speed{spd}.(exp.lummCor)==1;
    antistereo=speed{spd}.(exp.monoCueFog)==0 & speed{spd}.(exp.monoCueDiam)==0 & speed{spd}.(exp.lummCor)==-1;
    
    M=dpxdSubset(speed{spd},mono | mono&stereo);
    S=dpxdSubset(speed{spd},stereo | mono&stereo);
    if strcmp(exp.Id,'fullFb') || strcmp(exp.Id,'halfFb');
        B=dpxdSubset(speed{spd},~mono&~stereo | mono&stereo);
        varLbl='both';
    else
        AS=dpxdSubset(speed{spd},antistereo | mono&antistereo);
        varLbl='anti-stereo';
    end
    
    if spd==1
    expId=[exp.Id ' speed up'];
    elseif spd==2
        expId=[exp.Id ' speed Down'];
    end
    dpxFindFig(expId);
    clf;
    
    
    labels={'mono','stereo',varLbl};
    subplot(1,2,1);
    h(1)=plotPsychoCurves(M,exp.monoCueFog,exp.resp,exp.Id,exp.speed,'*r-','LineWidth',3);
    h(2)=plotPsychoCurves(S,exp.stereoCue,exp.resp,exp.Id,exp.speed,'ok:','Color',[0 .5 0],'LineWidth',2);
    if exist('B','var');
        h(3)=plotPsychoCurves(B,exp.monoCueFog,exp.resp,exp.Id,exp.speed,'+b--','LineWidth',1);
    elseif exist('AS','var');
        h(3)=plotPsychoCurves(AS,exp.stereoCue,exp.resp,exp.Id,exp.speed,'+b--','LineWidth',1);
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
    else
        %nothing
    end
    legend(h,labels);
    
    
end
end

function  h=plotPsychoCurves(D,fieldstr,keyname,Id,speed,varargin)
E=dpxdSplit(D,fieldstr);
if strcmp(Id,'bind')
    for e=1:numel(E)
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

