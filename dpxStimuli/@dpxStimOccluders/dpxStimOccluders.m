classdef dpxStimOccluders < dpxAbstractStim
    %DPXOCCLUDERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=public)
        NReps=10;
        PicsPerBlock=5;
        NrBars=4;
        barConfig='even';
        disparityFrac=1;
        NrEncoding=5;
        PicDir='C:\Users\Reinder\Documents\School\Masterstage Stereoblind\DPX\dpxExperiments\Reinder\rdDpxFaceStimuli';
    end
    properties(GetAccess=public, SetAccess=private)
        StimArray;
        Block;
    end
    methods (Access=protected)
        function myInit(S)
            %load pictures from picture folder
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
                S.Block(Bl).BlockNr=Bl;
                S.Block(Bl).StimEncode=S.StimArray(BlockStart:BlockSize);
                
                S.Block(Bl)=OccluShuffle(S.Block(Bl));
                
                for StimNr=1:BlockSize
                    S.Block(Bl).StimEncode(StimNr).Texture=CalcTexture(S,S.scrGets,S.Block(Bl).StimEncode(StimNr));
                end
            end
            
        end
        function myDraw(S)
            
            DisplayEncodePics(S.Block(Tr).StimEncode,StimWindow,E.Input,E.PhysScr); 

            
          
            
            
        end
    end
end



function StimList=Shuffle(PicNames,PicsPerBlock)
NTotalPic=numel(PicNames);
NewOrder=randperm(NTotalPic);
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

function Texture=CalcTexture(S,PhysScr,Stim)
[X Z ~]=size(Stim.ImMatrix);
barZ=Z/(S.NrBars*2);

Stim.Disp=S.disparityFrac*PhysScr.deg2px;
BarConfig=S.barConfig;

for B=1:(S.NrBars*2)
    C=B+(B-1);
    Texture.BarRectXYZ(1,C)=1;
    Texture.BarRectXYZ(2,C)=Stim.Disp;
    Texture.BarRectXYZ(3,C)=barZ*(B-1)+1;
    Texture.BarRectXYZ(1,C+1)=X;
    Texture.BarRectXYZ(2,C+1)=Stim.Disp;
    Texture.BarRectXYZ(3,C+1)=barZ*B;
end
Texture.HorDisp=GetHorizontalDisparity(PhysScr,Texture.BarRectXYZ);
switch BarConfig
    case 'even'
        OccluderIdx = true(1,size(Texture.BarRectXYZ,2));
        OccluderIdx(1:4:size(Texture.BarRectXYZ,2))=false;
        OccluderIdx(2:4:size(Texture.BarRectXYZ,2))=false;
        PictureIdx = false(1,size(Texture.BarRectXYZ,2));
        PictureIdx(1:4:size(Texture.BarRectXYZ,2))=true;
        PictureIdx(2:4:size(Texture.BarRectXYZ,2))=true;
    case 'uneven'
        OccluderIdx = false(1,size(Texture.BarRectXYZ,2));
        OccluderIdx(1:4:size(Texture.BarRectXYZ,2))=true;
        OccluderIdx(2:4:size(Texture.BarRectXYZ,2))=true;
        PictureIdx = true(1,size(Texture.BarRectXYZ,2));
        PictureIdx(1:4:size(Texture.BarRectXYZ,2))=false;
        PictureIdx(2:4:size(Texture.BarRectXYZ,2))=false;
end
Texture.OccluderRect=Texture.BarRectXYZ(:,OccluderIdx);
Texture.PictureRect=Texture.BarRectXYZ(:,PictureIdx);
Texture.BarConfig=BarConfig;

end

function DisplayEncodePics(Stim,StimWindow,Input,PhysScr)
for SNr=1:(size(Stim,2))
    T=Stim(SNr).Texture;     %shorthand for readability
    ImMatrix=RandomDotOnImage(Stim(SNr).ImMatrix,Input);
    TexIndex=Screen('MakeTexture',StimWindow,ImMatrix);
    for B=1:2:Input.NrBars*2
        [X Z ~]=size(ImMatrix);
        X=X*Input.Scaling;
        Z=Z*Input.Scaling;
        HorDispL=T.HorDisp.lX00(1,B);
        HorDispR=T.HorDisp.rX00(1,B);
        
        PicRect=[T.PictureRect(1,B) T.PictureRect(3,B) T.PictureRect(1,B+1) T.PictureRect(3,B+1)];
        BarsY=[PicRect(2)*Input.Scaling PicRect(4)*Input.Scaling];
        DestRectL=round([ PhysScr.ScrCenter(1)-(X/2)+HorDispL PhysScr.ScrCenter(2)-(Z/2)+BarsY(1) PhysScr.ScrCenter(1)+(X/2)+HorDispL PhysScr.ScrCenter(2)-(Z/2)+BarsY(2)]);
        DestRectR=round([ PhysScr.ScrCenter(1)-(X/2)+HorDispR PhysScr.ScrCenter(2)-(Z/2)+BarsY(1) PhysScr.ScrCenter(1)+(X/2)+HorDispR PhysScr.ScrCenter(2)-(Z/2)+BarsY(2)]);
        
        Screen('SelectStereoDrawBuffer',StimWindow,0) %Left buffer
        Screen('DrawTexture',StimWindow,TexIndex,PicRect,DestRectL)
        
        Screen('SelectStereoDrawBuffer',StimWindow,1) %right buffer
        Screen('DrawTexture',StimWindow,TexIndex,PicRect,DestRectR)
        
    end
    Screen('Flip',StimWindow)
    pause(2)
    
    Screen('SelectStereoDrawBuffer',StimWindow,0) %Left buffer
    Screen('DrawLines',StimWindow,[0 0 -15 15; -15 15 0 0],4,[255 255 255],PhysScr.ScrCenter)
    Screen('SelectStereoDrawBuffer',StimWindow,1) %Right buffer
    Screen('DrawLines',StimWindow,[0 0 -15 15; -15 15 0 0],4,[255 255 255],PhysScr.ScrCenter)
    
    Screen('Flip',StimWindow)
    pause(0.5)
end
end
function HorDisp=GetHorizontalDisparity(PhysScr,XYZ)
StimSize=size(XYZ,2);

leV=XYZ-PhysScr.leftEyeXYZpx*ones(1,StimSize);
reV=XYZ-PhysScr.rightEyeXYZpx*ones(1,StimSize);
ceV=XYZ-PhysScr.cyclopEyeXYZpx*ones(1,StimSize);
leC=-PhysScr.leftEyeXYZpx(2,:)*ones(1,StimSize)./leV(2,:);
reC=-PhysScr.rightEyeXYZpx(2,:)*ones(1,StimSize)./leV(2,:);
ceC=-PhysScr.cyclopEyeXYZpx(2,:)*ones(1,StimSize)./ceV(2,:);
lepXYZ=round(PhysScr.leftEyeXYZpx*ones(1,StimSize) + [leC; leC; leC].*leV );
repXYZ=round(PhysScr.rightEyeXYZpx*ones(1,StimSize) + [reC; reC; reC].*reV );
cepXYZ=round(PhysScr.cyclopEyeXYZpx*ones(1,StimSize) + [ceC; ceC; ceC].*ceV );
HorDisp.lX00=cepXYZ-lepXYZ;
HorDisp.rX00=cepXYZ-repXYZ;
%no perspective, only horizontal disparity component.
HorDisp.lX00(2:3,:)=0;
HorDisp.rX00(2:3,:)=0;
end


