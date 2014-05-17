% Part of Duijnhouwer-Psychtoolbox-Experiments
% Jacob, 2014-05-16

function [physScr,stimwin]=jdPTBopenStimWindow(setup) 
    physScr.oldVerbosityLevel = Screen('Preference', 'Verbosity', 3);
    Screen('Preference','VisualDebuglevel', 0);
    Screen('Preference','SkipSyncTests',0);
    AssertOpenGL;
    %HideCursor;
    scr=Screen('screens');
    physScr.scrNr=max(scr);
    [physScr.widPx, physScr.heiPx]=Screen('WindowSize',physScr.scrNr);
    if isempty(setup.screenWidHeiMm)
        [physScr.widMm, physScr.heiMm]=Screen('DisplaySize',physScr.scrNr);
    else
        physScr.widMm = setup.screenWidHeiMm(1); %406;
        physScr.heiMm = setup.screenWidHeiMm(2); %305;
    end
    physScr.whiteIdx=WhiteIndex(physScr.scrNr);
    physScr.blackIdx=BlackIndex(physScr.scrNr);
    physScr.distMm=setup.screenDistMm;
    physScr.mm2px=physScr.widPx/physScr.widMm;
    physScr.distPx=round(physScr.distMm*physScr.mm2px);
    physScr.scrWidDeg=atan2d(physScr.widMm/2,physScr.distMm)*2;
    physScr.deg2px=physScr.widPx/physScr.scrWidDeg;
    [stimwin, physScr.winRect]=Screen('OpenWindow',physScr.scrNr,0); %[0 0 physScr.widPx physScr.heiPx],[],2);
    physScr.frameDurS=Screen('GetFlipInterval',stimwin);
    Screen('BlendFunction',stimwin,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    Screen('Textfont',stimwin,'Arial');
    Screen('TextSize',stimwin,22);
    physScr.oldGammaTab=Screen('ReadNormalizedGammaTable',physScr.scrNr);%#ok<*NASGU>
    physScr.gammaTab=repmat((0:1/WhiteIndex(physScr.scrNr):1)',1,3).^setup.gammaCorrection;
    physScr.gamma=setup.gammaCorrection;
    Screen('LoadNormalizedGammaTable',physScr.scrNr,physScr.gammaTab);
end