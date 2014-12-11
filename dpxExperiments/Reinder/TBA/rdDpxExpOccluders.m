function rdDpxExpOccluders()
if IsWin
    DisableKeysForKbCheck([233]);
end

E=dpxCoreExperiment;

E.txtStart='textstart';
E.expName='rdDpxExpOccluders';
E.nRepeats=10;
E.txtPauseNrTrials=5;
E.nRepeats=1;
E.outputFolder='';

E.scr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000,'scrNr',1);
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0 0 0 1]);
E.scr.set('stereoMode','mirror','skipSyncTests',1);

nRecallPics=5;
barConfigs={'even','uneven'};
for B=1:numel(barConfigs)
    for dsp=[-1:1]
        C=dpxCoreCondition;
        set(C,'durSec',16.5)
        
        %fix cross
        for c=1:nRecallPics
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name',['fix' num2str(c)]);
            set(S,'durSec',1.5,'onSec',6.6+2.1*(c-1))
            C.addStim(S);
        end
        
        %feedback stim
        S=dpxStimDot;
        set(S,'wDeg',.3,'visible',false,'durSec',0.20,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
        C.addStim(S);
        
        %first pictures, encoding
        S=dpxStimImage;
        set(S,'mode','Encode','durSec',5,'wDeg',1); %input=PicFolder
        set(S,'name','EncodingPics');
        set(S,'stimsE',Block
        C.addStim(S);
        
        %second pictues, recall
        T=(0.6+1.5); %stim duration plus its pause until next
        for t=1:nRecallPics
            onSet=6+T*(t-1);
            S=dpxStimImage;
            set(S,'mode','Occlude','durSec',0.6,'onSec',onSet,'wDeg',1); %input=PicFolder
            set(S,'NrBars',4,'HorDisp',1,'BarConfig',barConfigs{B})
            set(S,'name',['RecallPic' num2str(t)] );
            C.addStim(S);
        end
        
        % response objects
        for t=1:nRecallPics
            respOnSet=6.6+T*(t-1);
            respOffSet=8.1+T*(t-1);
            R= dpxRespKeyboard;
            set(R,'kbNames','LeftShift,RightShift');
            set(R,'name',['recall' num2str(t)]);
            set(R,'correctStimName','fbCorrect','correctEndsTrialAfterSec',10000);
            set(R,'wrongStimName','fbCorrect','wrongEndsTrialAfterSec',10000);
            set(R,'allowAfterSec',respOnSet);
            set(R,'allowUntilSec',respOffSet);
            C.addResp(R);
        end
        
        E.addCondition(C);
    end
end
E.run
end

function StimList=Shuffle(PicNames,PicsPerBlock)
NTotalPic=numel(PicNames);
NewOrder=S.RND.randperm(NTotalPic);
StimList=PicNames(NewOrder);

%removes file format behind name. actually needed for reading the good
%files. just commented and saved to be sure.
% for i=1:NTotalFaces
%     StimList{i}=StimList{i}(1:3);
% end

i=size(StimList);
tr=i(1)/10;


BlockStart=1;
for tr=1:tr
    BlockSize=PicsPerBlock*tr;
    F=StimList(BlockStart:BlockSize);
    idx=regexp(F,'Fa');
    idx=sum(cell2mat(idx));
    if idx==10 || isempty(idx)
        warning('A trial was found with either only faces or objects: trial number %d. repeat randomization process',tr)
        StimList=[];
        break
    else
        
    end
    BlockStart=BlockStart+10;
end
fprintf('\nPseudo-randomization of stimuli categories confirmed. ');
pause(0.5)
fprintf('Proceeding\n')
end

function Block=OccluShuffle(Block)
%gives a occlusion value. 1=back occlusion, 2=front occlusion
%make sure atleast 2 of each type of occlusion are present in the inducing
%10 images.
X=[];
while isempty(X)
    P=size(Block.StimEncode);
    P=P(2);
    for i=1:P
        Block.StimEncode(i).DispIdx=randi(2,1);
    end
    idx=sum(cat(1,Block.StimEncode.DispIdx));
    if idx==10 || idx==11 || idx==19 || idx==20
        warning('A trial was found with bad occlusion randomization. Trial number %d. Repeating randomization process',Block.BlockNr)
        break
    else
        X=1;
    end
    prnt=['\nPseudo-randomization of stimuli occlusions confirmed for blocknr ' num2str(Block.BlockNr) '.'];
    fprintf(prnt);
    pause(0.5)
    fprintf('Proceeding\n')
end
end

function determinePics()
Pics=dir(S.PicDir);
Pics=(Pics(3:end));
PicNames=repmat({Pics.name},S.NReps,1);
NTotalPics=numel(PicNames);

StimList=[];
while isempty(StimList)
    StimList=Shuffle(PicNames,S.PicsPerBlock);
end

for iStim = 1:NTotalPics;
    S.StimArray(iStim).name=StimList{iStim};
    PicFile=fullfile(S.PicDir,StimList{iStim});
    S.StimArray(iStim).ImMatrix=imread(PicFile);
end
BlockStart=1;
for Bl=1:(NTotalPics/S.PicsPerBlock);
    BlockSize=(Bl*S.PicsPerBlock);
    Block(Bl).BlockNr=Bl;
    Block(Bl).StimEncode=StimArray(BlockStart:BlockSize);
    
    Block(Bl)=OccluShuffle(Block(Bl));
    
 
end

end