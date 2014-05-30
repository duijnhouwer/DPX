function [w,t]=jdPTBmakeWave(Hz,durs,warppower,SF)
    
    % [w,SF]=jdPTBmakeWave(Hz,durs,[warppower],[SF])
    % 
    % Create a sinewave with Hz and duration durs in seconds. Optional
    % argument SF is the sampling frequency, which is 10000 Hz by default.
    % Optional argument warppower is applied a power to absolute wave
    % values, very small values approximate a square wave, zero values
    % make square wave.
    % Jacob, 2014-05-17
    %
    % Example:
    %   w=jdPTBmakeWave(440,.5,.5,1/1000);
    %   p=audioplayer(w,10000);
    %   p.play;
    %
    % See also audioplayer
    
    if nargin==2 || isempty(warppower)
        warppower=1;
    end
    if nargin==3
        SF=10000;
    end
    t=0:1/SF:durs;
    w=sin(t*2*pi*Hz);
    if warppower<=0
        w(w>0)=1;
        w(w<0)=-1;
    elseif warppower<1
        w(w>0)=w(w>0).^warppower;
        w(w<0)=-(-w(w<0)).^warppower;
    end
    