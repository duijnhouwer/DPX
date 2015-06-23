function lkDpxStimDot
    E=dpxCoreExperiment;
    E.expName='lkDpxStimDot';
    E.scr.distMm=290;
    % 2014-10-28: Measured luminance BENQ screen Two-Photon room Brightness
    % 0; contrast 50; black eq 15; color temp [R G B] correction = [0 100
    % 100] blur reduction OFF; dynamic contrast 0 Resolution 1920x1080 60
    % Hz; Reset Color no; AMA high, Instant OFF, Sharpness 1; Dynamic
    % Contrast 0; Display mode Full; Color format RGB; Smartfocus OFF;
    % connected with a VGA cable (so that we can split to Beetronixs
    % Screen) With these settings. 
    
    
    % FullWhite=42 cd/m2; FullBlack=0.12;
    % and with gamma 1, medium gray (RGB .5 .5 .5) = 21 cd/m2
    %
    E.scr.gamma=1.0;
    E.scr.backRGBA=[.1 .1 .1 1];
    E.scr.verbosity0min5max=2;
    E.scr.winRectPx=[0 0 1920 1080] ;
    E.txtStart='asd DAQ-pulse'; 
    E.txtEnd='';
    E.txtPauseNrTrials=0;
    %
    % Settings
    %
%     dirDegs=0;
%     speedDps=10;
%     dotsPerSqrDeg=10;
%     dotDiamDeg=.1;
%    dotRBGAfrac1=[0 ];
%    dotRBGAfrac2=[1 ];
%     nSteps=2;
%     cohereFrac=1; % negative coherence flips directions
%     apert='circle';
    E.nRepeats=6;
    stimSec=4;
    isiSec=4;
    %
   % for x=[-12 12]
%         for direc=dirDegs(:)'
%             for speed=speedDps(:)'
%                 for dpsd=dotsPerSqrDeg(:)'
%                     for dddeg=dotDiamDeg(:)'
%                        for dotRBGAfrac1=[0 0 0 1]
%                            for dotRBGAfrac2=[1 1 1 1]
%                                 for nsteps=nSteps(:)'
%                                     for cohfrac=cohereFrac(:)'
%                                         for apert='circle'
                                            C=dpxCoreCondition;                                      
                                            S=dpxStimDot;
                                            S.wDeg=1;
                                            S.hDeg=1;
%                                             C.addStim(S);
%                                             C.addResp(dpxCoreResponse);
                                            C.durSec=stimSec+isiSec;
                                            S=dpxStimRdk;
                                            %set(S,'xDeg',x);
                                            S.wDeg=65;
                                            S.hDeg=65;
%                                             S.dirDeg=direc;
%                                             S.speedDps=speed;
%                                             S.dotsPerSqrDeg=dpsd;
%                                             S.dotDiamDeg=dddeg;
%                                             S.dotRBGAfrac1=[0 0 0 1];
%                                             S.dotRBGAfrac2=[1 1 1 1];
%                                             S.nSteps=nsteps;
%                                             S.cohereFrac=cohfrac; % negative coherence flips directions
%                                             S.apert='circle';
%                                             C.addStim(S);
                                            %      C.addResp(dpxCoreResponse);
                                            S.onSec=isiSec/2;
                                            S.durSec=stimSec;
                                            %
                                            M=dpxStimMaskCircle;
                                            M.name='mask';
                                            M.wDeg=S.wDeg*sqrt(2)+1;
                                            M.hDeg=S.wDeg*sqrt(2)+1;
                                            M.outerDiamDeg=S.wDeg;
                                            M.innerDiamDeg=S.wDeg-5;
                                            M.RGBAfrac=[.1 .1 .1 1];
                                            %
                                            V=dpxStimMccAnalogOut;
                                            V.name='mcc';
                                            V.onSec=0;
                                            V.durSec=C.durSec;
                                            V.initVolt=0;
                                            V.stepSec=[S.onSec S.onSec+S.durSec];
                                            V.stepVolt=[4 0];
                                            V.pinNr=13;
                                            %
                                            C.addStim(V);
                                            C.addStim(M);
                                            C.addStim(S);
                                            %
                                            MCC=dpxRespMccCounter;
                                            MCC.name='mcc';
                                            MCC.allowUntilSec=C.durSec;
                                            C.addResp(MCC);
                                            %lkDpxGratingExp
                                            E.addCondition(C);
%                                         end
%                                     end
%                                 end
%                             end
%                         end
%                     end n

%                 end
%             end
%         end
%     end
    nrTrials=numel(E.conditions) * E.nRepeats;
    dpxDispFancy(['Please set-up a ' num2str(ceil(nrTrials*(isiSec+stimSec)+10)) ' s recording pattern in LasAF (' num2str(nrTrials) ' trials of ' num2str(stimSec+isiSec) ' s + 120 s)']);
    E.run;
end
