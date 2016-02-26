function jdDpxSeminarCam(rect)
    
    % jdDpxSeminarCam
    if nargin==0
        rect=[];
    end
    evalin('base','clear classes webcam');
    E=dpxCoreExperiment;
    E.clearPlugins();
    E.paradigm='';
    E.window.set('rectPx',rect,'widHeiMm',[2 2],'distMm',1, ...
        'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'skipSyncTests',1, ...
        'verbosity0min5max',0);
    C=dpxCoreCondition;
    C.durSec=Inf;
    CAM=dpxStimWebCam;
    CAM.wDeg=70;
    CAM.hDeg=50;
    CAM.flipLr=true;
    CAM.flipUd=false;
    CAM.resolution='';
    C.addStimulus(CAM);
    E.addCondition(C);
    E.run;
end
