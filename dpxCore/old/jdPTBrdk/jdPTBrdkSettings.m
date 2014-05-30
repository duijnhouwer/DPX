

function [cond,nRepeats,instruction,outputfolder,hardware]=jdPTBrdkSettings
    %
    hardware=jdPTBdefaultSettings('hardware');
    hardware.screen.window=[];
    %
    outputfolder=fullfile(pwd,'data'); 
    %
    instruction=jdPTBdefaultSettings('instruction');
    instruction.start='Indicate motion direction\nwith left and right arrow keys.\n\nPress a key, release to start.';
    instruction.pause.nTrials=12;
    %
    nRepeats=2;
    %
    default=jdPTBdefaultSetting('common');
    default.rdk=jdPTBdefaultSetting('stimbasics');
    default.rdk.dirDeg=0;
    default.rdk.speedDps=3;
    default.rdk.dotsPerSqrDeg=10;
    default.rdk.dotDiamDeg=.2;
    default.rdk.dotRBGAfrac1=[0 0 0 1];
    default.rdk.dotRBGAfrac2=[1 1 1 1];
    default.rdk.nSteps=2;
    default.rdk.cohereFrac=1; % negative coherence flips directions
    %
    nConds=0;
    coh=-1:1:1;
    for c=1:numel(coh)
        nConds=nConds+1;
        cond(nConds)=default; %#ok<*AGROW>
        cond(nConds).rdk.cohereFrac=coh(c);
        if coh(c)<0
            cond(nConds).resp.feedback.correctResp='LeftArrow';
        elseif coh(c)>0
            cond(nConds).resp.feedback.correctResp='RightArrow';
        elseif coh(c)==0
            cond(nConds).resp.feedback.correctResp='.75';
        end
    end
end


