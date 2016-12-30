function jdDpxExpTmpRecruit2
    
    if strcmpi(getenv('COMPUTERNAME'),'PTB-P')
        scrSize=[0 0 1920 1080]
    else
        scrSize=[20 20 711 400];
          scrSize=[0 0 1920 1080]
    end
    
    E=dpxCoreExperiment;
    E.window.set('rectPx',scrSize,'widHeiMm',[508 318],'distMm',500);
    E.window.scrNr=0;
    E.window.gamma=1;
    E.window.backRGBA=[0.25 0.25 0.25 1];
    E.window.skipSyncTests=1;
    E.paradigm=mfilename;
    try
        E.outputFolder='U:\Project Temporal Recruitment\data';
    catch
        E.outputFolder=fullfile(tempdir,'DPX',mfilename);
    end
    
    dotdens=5;
    nSteps=3;%1:5;
    motTypes={'shuffle','straightMatch2Shuff'};
    motOn=.5;
    motDur=.5;
    
    for t=1:numel(motTypes)
        for nsi=1:numel(nSteps)
            for coherence=-1:1:1 %-1:.125:1
                C=dpxCoreCondition;
                C.durSec=Inf;
                %
                FIX=dpxStimCross;
                FIX.name='fixcross';
                FIX.onSec=-1;
                FIX.wDeg=0.5;
                FIX.hDeg=1;
                FIX.RGBAfrac=[0 0 0 1];
                C.addStimulus(FIX);
                %
                T=dpxStimTextSimple;
                T.name='treatment';
                T.str=[motTypes{t} ',' num2str(nSteps(nsi))];
                T.visible=1;
                C.addStimulus(T);
                %
                RDK=dpxStimRdkStore;% ;
                %RDK=dpxStimRdkShuffleStep;
                RDK.name='rdk';
                RDK.speedDps=15;
                RDK.dotsPerSqrDeg=5;
                RDK.dotRBGAfrac1=[1 1 1 1];
                RDK.dotRBGAfrac2=[1 1 1 1];
                RDK.wDeg=19;
                RDK.hDeg=10;
                RDK.motType=motTypes{t};
                RDK.nSteps=nSteps(nsi);
                RDK.cohereFrac=coherence;
                RDK.apert='rect';
                RDK.onSec=.5;
                RDK.durSec=.5;
                C.addStimulus(RDK);
                
                % Create and add a response object to record the keyboard presses.
                RSP=dpxRespKeyboard;
                RSP.name='kb';
                RSP.kbNames='LeftArrow,RightArrow';
                RSP.allowAfterSec=motOn+motDur; % allow the response no sooner than the end of the RDK motion pulse
                RSP.correctEndsTrialAfterSec=0;
                C.addResponse(RSP);
                %
                E.addCondition(C);
            end
        end
    end
    E.nRepeats=1;
    dpxDispFancy([ mfilename ' (' num2str(numel(E.conditions) * E.nRepeats) ' trials)']);
    E.run;
end





