function eaDpxExpTest
    E=dpxCoreExperiment;
    E.expName='eaDpxExpTest';
    E.scr.set('winRectPx',[10 10 800 600],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...% 0.49
        'stereoMode','mono','skipSyncTests',0,'scrNr',0);
    
    stereoOffsetDeg=5;
    deg=[.11 .08];
    for c=1:2
        C=dpxCoreCondition;
        C.durSec=2;
        
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[.5 .5 1 1];
        LeftCheck.xDeg=-stereoOffsetDeg;
        LeftCheck.wDeg=5;
        LeftCheck.hDeg=5;
        LeftCheck.rndSeed=round(rand*100000);
        C.addStim(LeftCheck);
        %    S=dpxStimRect;
        
        S=dpxStimRotCylinder;
        set(S,'dotsPerSqrDeg',12,'xDeg',0,'wDeg',3,'hDeg',3,'dotDiamDeg',deg(c) ...
            ,'rotSpeedDeg',120,'disparityFrac',1,'sideToDraw','both' ...
            ,'onSec',0,'durSec',5,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
            ,'name','fullTargetCyl');
        S.axis='horisphere';
        set(S,'dotRGBA1frac',[1 1 1 1],'dotRGBA2frac',[1 1 1 1]);
        C.addStim(S);
        
        RiteCheck=dpxStimCheckerboard;
        RiteCheck.name='checksRight';
        RiteCheck.RGBAfrac=[.5 1 1 1];
        RiteCheck.xDeg=stereoOffsetDeg;
        RiteCheck.wDeg=5;
        RiteCheck.hDeg=5;
        RiteCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RiteCheck);
        
        E.addCondition(C);
        
    end
    E.nRepeats=2;
    E.run;
    
end
