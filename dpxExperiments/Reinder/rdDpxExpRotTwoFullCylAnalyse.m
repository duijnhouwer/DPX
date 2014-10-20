function D=rdDpxExpRotTwoFullCylAnalyse(D)
%%analayse and plot the two full cylinders experiment.

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

D=dpxdSubset(D,D.resp_rightHand_keyNr>0);
D=dpxdSubset(D,D.resp_leftHand_keyNr>0);
disp(['Discarded ' num2str(oldN-D.N) ' out of ' num2str(oldN) ' trials for lack of response']);



dpxFindFig(exp.name);
clf;
labels={'mono','stereo','antistereo'};

%loop for right and left seperate (numerical way to determine sides, easier to use)
sideNum={-1,1};%-1 = left, 1 = right
for side=1:numel(sideNum) 
    %get current side
    xDeg=abs(D.fullInducerCyl_xDeg(1));
    Cur=dpxdSubset(D,D.fullInducerCyl_xDeg==xDeg*sideNum{side});
    mono=Cur.(exp.stereoCue)==0 & Cur.(exp.lummCor)==1;
    stereo=Cur.(exp.monoCueFog)==0 & Cur.(exp.monoCueDiam)==0 & Cur.(exp.lummCor)==1;
    antistereo=Cur.(exp.monoCueFog)==0 & Cur.(exp.monoCueDiam)==0 & Cur.(exp.lummCor)==-1;
    
    %divide mono/stereo/antistereo
    M=dpxdSubset(Cur,mono | mono&stereo);
    S=dpxdSubset(Cur,stereo | mono&stereo);
    AS=dpxdSubset(Cur,antistereo | antistereo&mono);
    
    %inducer percept plot
    subplot(3,2,side);
    h(1)=plotPsychoCurves(M,exp.monoCueFog,exp,sideNum{side},'+r-','LineWidth',3);
    h(2)=plotPsychoCurves(S,exp.stereoCue,exp,sideNum{side},'og--','LineWidth',2);
    h(3)=plotPsychoCurves(AS,exp.stereoCue,exp,sideNum{side},'*b:','LineWidth',1);
    title('correct inducer');
    ylabel(exp.corPercOne);
    legend(h,labels);
    
    %target percept bound by phys properties of inducer (viridical binding to inducer)
    subplot(3,2,2+side);
    h(1)=plotPsychoCurves(M,exp.monoCueFog,exp,sideNum{side}*-1,'+r-','LineWidth',3);
    h(2)=plotPsychoCurves(S,exp.stereoCue,exp,sideNum{side}*-1,'og--','LineWidth',2);
    h(3)=plotPsychoCurves(AS,exp.stereoCue,exp,sideNum{side}*-1,'*b:','LineWidth',1);
    title('target percept viridical bound');
    ylabel(exp.percTwo);
    legend(h,labels);
end
%target percept bound by percept of inducer
subplot(3,2,[5 6]);
h(1)=plotPerceptBoundCurves(M,exp.monoCueFog,'+r-','LineWidth',3);
h(2)=plotPerceptBoundCurves(S,exp.stereoCue,'og--','LineWidth',2);
h(3)=plotPerceptBoundCurves(AS,exp.stereoCue,'*b:','LineWidth',1);
title('target percept perceptually bound');
ylabel(exp.percThree);
legend(h,labels);
end

function exp=whichExp(data)
if strcmpi(data.exp_expName(1),'rdDpxExpRotCylShuffled');
    exp.Id='twoFull';
    exp.name=['subject ' data.exp_subjectId{1} ': Direction of full cyl (context-driven)'];
    exp.monoCueFog='fullInducerCyl_fogFrac';
    exp.monoCueDiam='fullInducerCyl_dotDiamScaleFrac';
    exp.stereoCue='fullInducerCyl_disparityFrac';
    exp.lummCor='fullInducerCyl_stereoLumCorr';
    exp.speed='fullInducerCyl_rotSpeedDeg';
    exp.respUp={'a' 'UpArrow'};
    exp.respDown={'z' 'DownArrow'};
    exp.corPercOne='% Inducer correct';
    exp.percTwo='% Target viridical bound';
    exp.percThree='% Target perceptual bound';
else
    error('this one is for TwoFullCyl only!');
end
end

function  h=plotPsychoCurves(D,fieldstr,exp,side,varargin)
E=dpxdSplit(D,fieldstr);
for e=1:numel(E)
    x(e)=mean(E{e}.(fieldstr)); %#ok<*AGROW>
    Sp=dpxdSplit(E{e},exp.speed);
    for iSp=1:numel(Sp);
        if sign(Sp{iSp}.(exp.speed)(1))==-1
            if side>0
                iy(iSp)=mean(strcmpi(Sp{iSp}.resp_rightHand_keyName,exp.respDown{2}));
            elseif side<0
                iy(iSp)=mean(strcmpi(Sp{iSp}.resp_leftHand_keyName,exp.respDown{1}));
            end
        elseif sign(Sp{iSp}.(exp.speed)(1))==1
            if side>0
                iy(iSp)=mean(strcmpi(Sp{iSp}.resp_rightHand_keyName,exp.respUp{2}));
            elseif side<0
                iy(iSp)=mean(strcmpi(Sp{iSp}.resp_leftHand_keyName,exp.respUp{1}));
            end
        end
        y(e)=mean(iy);
    end
end
h=plot(x,y*100,varargin{:});
axis([min(x) max(x) 0 100]);
dpxPlotHori(50,'k--');
dpxPlotVert(0.5,'k--');
xlabel(fieldstr)
hold on
end

function  h=plotPerceptBoundCurves(D,fieldstr,varargin)
E=dpxdSplit(D,fieldstr);
for e=1:numel(E);
    x(e)=mean(E{e}.(fieldstr));
    y(e)=mean(E{e}.resp_rightHand_keyNr==E{e}.resp_leftHand_keyNr);
end
h=plot(x,y*100,varargin{:});
axis([min(x) max(x) 0 100]);
dpxPlotHori(50,'k--');
dpxPlotVert(0,'k--');
xlabel(fieldstr)
hold on
end


