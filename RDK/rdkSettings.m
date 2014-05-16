
function [cond,nRepeats,setup]=rdkSettings
    %
    setup.screenDistMm=1000;
    setup.gammaCorrection=1.49;
    %
    nRepeats=3;
    %
    default.dirdeg=0;
    default.degps=3;
    default.apert.type='circle';
    default.apert.widdeg=10;
    default.apert.heideg=10;
    default.apert.xDeg=0;
    default.apert.yDeg=0;
    default.ndots=1000;
    default.dotradiusdeg=.1;
    default.black=0;
    default.white=1;
    default.gray=0.5;
    default.durS=3;
    default.preS=.5;
    default.postS=.5;
    default.nsteps=5;
    default.coherefrac=.5; % [0 .. 1]
    default.contrast=1;
    default.fix.xy=[0 0];
    default.fix.radiusdeg=.1;
    default.fix.rgb=[255 0 0];
    %
    nConds=0;
    dirs=[0 180];
    coh=0:.1:1;
    for d=1:numel(dirs)
        for c=1:numel(coh)
            nConds=nConds+1;
            cond(nConds)=default;
            cond(nConds).dirdeg=dirs(d);
            cond(nConds).coherefrac=coh(c);
        end
    end
    %
end


