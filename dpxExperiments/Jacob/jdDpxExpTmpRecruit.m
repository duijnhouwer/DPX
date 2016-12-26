function jdDpxExpTmpRecruit
    
    if strcmpi(getenv('COMPUTERNAME'),'PTB-P')
        scrSize=[0 0 1920 1080]
    else
        scrSize=[20 20 800 600];
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
    nSteps=1:5;
    treatments='rm'; % regular, mixed dot motion
    motOn=0%.5;
    motDur=.5;
    
    maxNumelStepLen=size(nchoosek(1:max(nSteps)+1,2),1);
    for nsi=1:numel(nSteps)
        stepLen=diff(nchoosek(1:nSteps(nsi)+1,2),[],2);
        for t=1:numel(treatments)
            if treatments(t)=='m' && nSteps(nsi)==1
                % single step stimuli look the same for m and s motion, so
                % define only for one of the two.
                continue;
            end
            for coherence=-1:1:1 %-1:.125:1
                C=dpxCoreCondition;
                C.durSec=.5;%Inf;
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
                T.str=[treatments(t) ',' num2str(nSteps(nsi))];
                T.visible=1;
                C.addStimulus(T);
                
                for s=1:maxNumelStepLen
                    RDK=dpxStimRdkStore;
                    RDK.name=['component' num2str(s,'%.2d')];
                    if s>numel(stepLen)
                        RDK.visible=false;
                        RDK.cohereFrac=coherence;
                        RDK.nSteps=nan;
                    else
                        RDK.speedDps=15;
                        RDK.dotRBGAfrac1=[1 1 1 1];
                        RDK.dotRBGAfrac2=[1 1 1 1];
                        RDK.wDeg=30;
                        RDK.hDeg=10;
                        RDK.cohereFrac=coherence;
                        RDK.apert='rect';
                        RDK.onSec=0%.5;
                        RDK.durSec=.5%;
                        %
                        if treatments(t)=='m'
                            RDK.nSteps=-stepLen(s);
                            RDK.dotsPerSqrDeg=dotdens/numel(stepLen);
                        elseif treatments(t)=='r'
                            if stepLen(s)==nSteps(nsi)
                                RDK.nSteps=nSteps(nsi);
                                RDK.dotsPerSqrDeg=dotdens;
                            else
                                RDK.visible=false;
                                RDK.cohereFrac=coherence;
                                RDK.nSteps=nan;
                            end
                        else
                            error('huh?');
                        end
                        
                    end
                    C.addStimulus(RDK);
                end
                % Create and add a response object to record the keyboard presses.
                RSP=dpxRespKeyboard;
                RSP.name='kb';
                RSP.kbNames='LeftArrow,RightArrow';
                RSP.allowAfterSec=motOn+motDur; % allow the response no sooner than the end of the RDK motion pulse
                RSP.correctEndsTrialAfterSec=0;
              %  C.addResponse(RSP);
                %
                E.addCondition(C);
            end
        end
    end
    E.nRepeats=1;
    dpxDispFancy([ mfilename ' (' num2str(numel(E.conditions) * E.nRepeats) ' trials)']);
    E.run;
end





