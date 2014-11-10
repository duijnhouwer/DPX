classdef dpxStimImage < dpxAbstractStim
    
    properties (Access=public)
        RGBA=[0 0 255 255];
        mode='Encode'
        NrBars=4;
        HorDisp=0;
        BarConfig='even'
        
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function S=dpxStimImage
        end
    end
    methods (Access=protected)
        function myInit(S)
        end
        function myDraw(S)
            testPic=255*ones(92,112,3);
            Texture=CalcTexture(S.NrBars,S.HorDisp,S.BarConfig,S.physScrVals,testPic);
            texIdx=Screen('MakeTexture',S.physScrVals.windowPtr,testPic);
            wCnt=S.winCntrXYpx;
            [X Z ~]=size(testPic);
            if strcmpi(S.mode,'Encode')
                rectOne = [wCnt+[(S.xPx-X/2)-2.2*X S.yPx-Z/2] wCnt+[(S.xPx+X/2)-2.2*X +S.yPx+Z/2]];
                rectTwo = [wCnt+[(S.xPx-X/2)-1.1*X S.yPx-Z/2] wCnt+[(S.xPx+X/2)-1.1*X +S.yPx+Z/2]];
                rectThree = [wCnt+[(S.xPx-X/2) S.yPx-Z/2] wCnt+[(S.xPx+X/2) +S.yPx+Z/2]];
                rectFour = [wCnt+[(S.xPx-X/2)+1.1*X S.yPx-Z/2] wCnt+[(S.xPx+X/2)+1.1*X +S.yPx+Z/2]];
                rectFive = [wCnt+[(S.xPx-X/2)+2.2*X S.yPx-Z/2] wCnt+[(S.xPx+X/2)+2.2*X +S.yPx+Z/2]];
                for w=[0 1];
                    Screen('SelectStereoDrawBuffer',S.physScrVals.windowPtr,w);
                    Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,[],rectOne);
                    Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,[],rectTwo);
                    Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,[],rectThree);
                    Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,[],rectFour);
                    Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,[],rectFive);
                end
            elseif strcmpi(S.mode,'Recall')
%                 rectMid = [wCnt+[(S.xPx-S.wPx/2) S.yPx-S.hPx/2] wCnt+[(S.xPx+S.wPx/2) +S.yPx+S.hPx/2]];
                for B=1:2:S.NrBars*2
                    hDispL=Texture.HorDisp.lX00(1,B);
                    hDispR=Texture.HorDisp.rX00(1,B);
                    
                    picRect=[Texture.PictureRect(1,B) Texture.PictureRect(3,B) Texture.PictureRect(1,B+1) Texture.PictureRect(3,B+1)];
                    BarsY=[picRect(2) picRect(4)];
                    DestRectL=round([ wCnt(1)-(X/2)+hDispL wCnt(2)-(Z/2)+BarsY(1) wCnt(1)+(X/2)+hDispL wCnt(2)-(Z/2)+BarsY(2)]);
                    DestRectR=round([ wCnt(1)-(X/2)+hDispR wCnt(2)-(Z/2)+BarsY(1) wCnt(1)+(X/2)+hDispR wCnt(2)-(Z/2)+BarsY(2)]);
        
                    for w=[0 1];
                        Screen('SelectStereoDrawBuffer',S.physScrVals.windowPtr,w);
                        if w==0;
                            Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,picRect,DestRectL);
                        elseif w==1;
                            Screen('DrawTexture',S.physScrVals.windowPtr,texIdx,picRect,DestRectR);
                        end
                    end
                end
                
            end
            % topleft of screen is 0,0
            xyTopLeft=S.winCntrXYpx+[S.xPx-S.wPx/2 S.yPx-S.hPx/2];
            xyBotRite=S.winCntrXYpx+[S.xPx+S.wPx/2 S.yPx+S.hPx/2];
            rect=[xyTopLeft xyBotRite];
            Screen('FillRect',S.scrGets.windowPtr,S.RGBA,rect);
        end
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

function Texture=CalcTexture(NrBars,HorDisp,BarConfig,PhysScr,Stim)
[X Z ~]=size(Stim);
barZ=Z/(NrBars*2);

Disp=HorDisp*PhysScr.deg2px;

for B=1:(NrBars*2)
    C=B+(B-1);
    Texture.BarRectXYZ(1,C)=1;
    Texture.BarRectXYZ(2,C)=Disp;
    Texture.BarRectXYZ(3,C)=barZ*(B-1)+1;
    Texture.BarRectXYZ(1,C+1)=X;
    Texture.BarRectXYZ(2,C+1)=Disp;
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