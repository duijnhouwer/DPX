

function [cond,nBlocks,instruction,outputfolder,hardware]=jdPTBrdkSettings
    %
    hardware.screenDistMm=1000;
    hardware.gammaCorrection=1.49;
    hardware.screenWidHeiMm=[]; % [] triggers autodetection (may fail silently)
    %
    outputfolder=fullfile(pwd,'data'); 
    %
    instruction.start='Indicate motion direction\nwith left and right arrow keys.\n\nPress a key, release to start.';
    instruction.pause.txt='I N T E R M I S S I O N\n\nPress a key, release to continue.';
    instruction.pause.nTrials=12;
    %
    nBlocks=2;
    %
    default.dirDeg=0;
    default.speedDps=3;
    default.apertShape='circle';
    default.apertWdeg=10;
    default.apertHdeg=10;
    default.apertXdeg=0;
    default.apertYdeg=0;
    default.dotsPerSqrDeg=10;
    default.dotRadiusDeg=.1;
    default.dotRBGAfrac1=[0 0 0 1];
    default.dotRBGAfrac2=[1 1 1 1];
    default.backgroundRGBAfrac=[0.5 0.5 0.5 1];
    default.stimOnSecs=.75;
    default.stimOnDelaySecs=.25;
    default.maxReactionTimeSecs=3;
    default.nSteps=2;
    default.cohereFrac=1; % negative coherence flips directions
    default.contrast=1;
    default.fixXdeg=0;
    default.fixYdeg=0;
    default.fixRadiusDeg=.25;
    default.fixRGBAfrac=[1 0 0 1];
    default.respKeys='LeftArrow,RightArrow';
    default.respEndsTrial=true; % end the trial when response is given
    default.feedbackCorrectResp='LeftArrow'; % a key or a num2str(probablity) randomly correct (e.g., '0.5' when coherence is 0 in 2AFC task)
    default.feedbackCorrectSecs=.025;
    default.feedbackWrongSecs=.1;
    default.feedbackVisual=true;
    default.feedbackRadiusDeg=.5;
    default.feedbackCorrectRGBAfrac=[0 1 0 .5];
    default.feedbackWrongRGBAfrac=[0 0 0 .5];
    %
    nConds=0;
    coh=-1:.2:1;
    for c=1:numel(coh)
        nConds=nConds+1;
        cond(nConds)=default; %#ok<*AGROW>
        cond(nConds).cohereFrac=coh(c);
        if coh(c)<0
            cond(nConds).feedbackCorrectResp='LeftArrow';
        elseif coh(c)>0
            cond(nConds).feedbackCorrectResp='RightArrow';
        elseif coh(c)==0
            cond(nConds).feedbackCorrectResp='0.999';
        end
    end
end


