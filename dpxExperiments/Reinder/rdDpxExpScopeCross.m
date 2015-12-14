function rdDpxExpScopeCross
%fails :D

E=dpxCoreExperiment;
E.window.set('rectPx',[1440 0 1600+1440 1200],'widHeiMm',[394 295],'distMm',1000,'scrNr',1);
E.window.set('stereoMode','mirror','skipSyncTests',1);
C=dpxCoreCondition;
set(C,'durSec',3600);
S=dpxStimCross;
set(S,'wDeg',5,'hDeg',5,'lineWidDeg',0.05,'name','giantfix');
C.addStimulus(S);
E.addCondition(C);
E.run

end
