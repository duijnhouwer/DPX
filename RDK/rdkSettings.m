
function [cond,nBlocks,instruction,outputfolder,hardware]=rdkSettings
    %
    hardware.screenDistMm=1000;
    hardware.gammaCorrection=1.49;
    hardware.screenWidHeiMm=[]; % [] triggers autodetection (may fail silently)
    %
    outputfolder=fullfile(pwd,'data'); 
    %
    instruction.start='Indicate motion direction\nwith left and right arrow keys.\n\nPress a key, release to start.';
    instruction.pause.txt='I N T E R M I S S I O N\n\nPress a key, release to continue.';
    instruction.pause.nTrials=5;
    %
    nBlocks=1;
    %
    default.dirdeg=0;
    default.speedDps=3;
    default.apertShape='circle';
    default.apertWdeg=10;
    default.apertHdeg=10;
    default.apertXdeg=0;
    default.apertYdeg=0;
    default.dotsPerSqrDeg=10;
    default.dotRadiusDeg=.1;
    default.colA=0;
    default.colB=1;
    default.colBack=0.5;
    default.stimOnSecs=.75;
    default.stimOnDelaySecs=.25;
    default.maxReactionTimeSecs=3;
    default.nSteps=3;
    default.cohereFrac=1; % negative coherence flips directions
    default.contrast=1;
    default.fixXYdeg=[0 0];
    default.fixRadiusDeg=.25;
    default.fixRGBfrac=[1 0 0];
    default.respKeys='LeftArrow,RightArrow';
    default.respEndsTrial=true; % end the trial when response is given
    default.feedbackCorrectResp='LeftArrow'; % a key or a probablity randomly correct (e.g., when coherence is 0)
    default.feedbackCorrectSecs=.025;
    default.feedbackWrongSecs=.1;
    default.feedbackVisual=true;
    default.feedbackRadiusDeg=.5;
    default.feedbackCorrectRGBfrac=[0 1 0];
    default.feedbackWrongRGBfrac=[0 0 0];
    %
    nConds=0;
    coh=-1:.5:1;
    for c=1:numel(coh)
        nConds=nConds+1;
        cond(nConds)=default; %#ok<*AGROW>
        cond(nConds).cohereFrac=coh(c);
        if coh(c)<0
            cond(nConds).feedbackCorrectResp='LeftArrow';
        elseif coh(c)>0
            cond(nConds).feedbackCorrectResp='RightArrow';
        elseif coh(c)==0
            cond(nConds).feedbackCorrectResp=0.5;
        end
    end
end


