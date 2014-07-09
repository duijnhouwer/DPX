function rdDpxExpScopeCross
%fails :D

E=dpxCoreExperiment;
E.physScr.set('winRectPx',[],'widHeiMm',[394 295],'distMm',1000);
E.physScr.set('stereoMode','mirror','SkipSyncTests',1);
E.windowed(true);
C=dpxCoreCondition;
set(C,'durSec',3600);
S=dpxStimCross;
set(S,'wDeg',5,'hDeg',5,'lineWidDeg',0.05,'name','giantfix');
C.addStim(S);
R=dpxCoreResponse;
C.addResp(R);
E.addCondition(C);
E.run

end
