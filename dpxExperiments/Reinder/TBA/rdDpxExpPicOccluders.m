function rdDpxExpPicOccluders()
if IsWin
    DisableKeysForKbCheck([233]);
end



E=dpxCoreExperiment;

E.txtStart='textstart';
E.expName='rdDpxExpPicOccluders';
E.nRepeats=10;
E.txtPauseNrTrials=5;
E.outputFolder='';
inputFolder = './FaceStimuli' ;

E.scr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000,'scrNr',1);
E.scr.set('interEyeMm',65,'gamma',0.49,'backRGBA',[0 0 0 1]);
E.scr.set('stereoMode','mirror','skipSyncTests',1);

stimList = loadFaceList(inputFolder);

stimLoc=[-1 1]; %locations of occluded picable stims
barConfigs={'even','uneven'};
for ePic=1:length(stimList)
    for B=1:numel(barConfigs)
        for dsp=[-1:1] % for or behind
            C=dpxCoreCondition;
            set(C,'durSec',3.6)
            
            %fix cross
            S=dpxStimCross;
            set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix');
            C.addStim(S);
            
            %feedback stim
            S=dpxStimDot;
            set(S,'wDeg',.3,'visible',false,'onSec',2.1,'durSec',1.5,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
            C.addStim(S);
            
            %first pictures, encoding
            S=dpxStimImage;
            set(S,'mode','Encode','durSec',1.5,'wDeg',1); %input=PicFolder
            set(S,'name','EncodingPic');
            set(S,'inputFolder',inputFolder);
            set(S,'stimList',stimList)
            set(S,'picNum',ePic);
            set(S,'stimLoc',0);
            set(S,'scale',1.5);
            set(S,'dots',40);
            C.addStim(S);
            
            %second pictues, recall
            d=[];
            while isempty(d)
                dPic=randi(length(stimList)); %distractor pic
                if dPic~=ePic
                    d=true;
                end
            end
                
            rPic=Shuffle([ePic dPic]);

            for t=[1 2]
                S=dpxStimImage;
                set(S,'mode','Occlude','durSec',5,'onSec',1.5,'wDeg',1);
                set(S,'NrBars',4,'HorDisp',dsp,'BarConfig',barConfigs{B});
                set(S,'inputFolder',inputFolder);
                set(S,'stimList',stimList);
                set(S,'picNum',rPic(t))
                set(S,'stimLoc',stimLoc(t));
                set(S,'name',['RecallPic' num2str(t)] );
                set(S,'scale',1.5);
                set(S,'dots',40);
                C.addStim(S);
            end
            
            % response objects
            R= dpxRespKeyboard;
            set(R,'kbNames','LeftArrow,RightArrow');
            set(R,'name','recall');
            set(R,'correctStimName','fbCorrect','correctEndsTrialAfterSec',10000);
            set(R,'wrongStimName','fbCorrect','wrongEndsTrialAfterSec',10000);
            set(R,'allowAfterSec',2.1);
            set(R,'allowUntilSec',3.6);
            C.addResp(R);
            
            E.addCondition(C);
        end
    end
end
E.run
end

function stimList = loadFaceList(inputFolder) 
% Loads and pseudorandomly shuffles all the stimuli in the FaceStimuli
% folder. Pseudorandomly in this case meaning: no trials of only 10 faces or
% only 10 objects.
% Objects name format:
% Fa#.jpg (Face #number#)
% Ob#.jpg (object #number#)

%FacesDir=uigetdir(pwd,'Please choose the folder with the faces');

d=mfilename('fullpath');
d(end-19:end)=[];
if ~strcmpi(d,'C:\Users\Reinder\Documents\School\Masterstage Stereoblind\DPX\dpxExperiments\Reinder\TBA');
    cd (d)
end

FacesDir=inputFolder;
Faces=dir(FacesDir);
FaceNames=(Faces(3:end));
NTotalPic=numel(FaceNames);

for iStim = 1:NTotalPic;
    

end

stimList=[];
while isempty(stimList)
    stimList=Shuffle(FaceNames);
end

stimList = struct2cell(stimList);
stimList = stimList(1,:);


function stimList=Shuffle(FaceNames)
NTotalFaces=numel(FaceNames);
NewOrder=randperm(NTotalFaces);
stimList=FaceNames(NewOrder);

%removes file format behind name. actually needed for reading the good
%files. just commented and saved to be sure.
% for i=1:NTotalFaces 
%     stimList{i}=stimList{i}(1:3);
% end

i=size(stimList);
tr=i(1)/10;


BlockStart=1;
for t=1:tr
    BlockSize=10*t;
    F=struct2cell(stimList(BlockStart:BlockSize));
    idx=regexp(F(1,:),'Fa');
    idx=sum(cell2mat(idx));
    if idx==10 || isempty(idx)
        warning('A trial was found with either only faces or objects: trial number %d. repeat randomization process',tr)
        stimList=[];
        break
    else
        
    end
    BlockStart=BlockStart+10;
end
fprintf('\nPseudo-randomization of stimuli categories confirmed. ');
pause(0.5)
fprintf('Proceeding\n')
end

end
