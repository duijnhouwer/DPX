
function [condition,nRepeats]=revPhiBehavSettings
    nRepeats=2;
    condition(1).maxDps=30;
    condition(1).ndots=200;
    condition(1).dotradiusdeg=.5;
    condition(1).black=0;
    condition(1).white=1;
    condition(1).gray=0.5;
    condition(1).durS=3;
    condition(1).preS=5;
    condition(1).postS=5;
    condition(1).nsteps=1;
    condition(1).nFlipsPerStep=2; % update stim every n flips
    condition(1).dxFilt.sigmaSeconds=1;
    condition(1).dxFilt.widSigmas=6;
    condition(1).dxFilt.compression=.5;
    condition(1).dxFilt.noise='bin';
    condition(1).contrastFilt.sigmaSeconds=1;
    condition(1).contrastFilt.widSigmas=6;
    condition(1).contrastFilt.compression=0;
    condition(1).contrastFilt.noise='bin';
end


