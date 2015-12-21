function [angleVals,Hz,alignDeg]=dpxTuningCurveAlign(dirDeg,Hz,alignDeg,precissionDeg,interp1method)
    
    % [ANGLEVALS,HZ,ALIGNDEG]=dpxTuningCurveAlign(DIRDEG,HZ,ALIGNDEG,PRECISSIONDEG,INTERP1METHOD)
    %
    % Align a periodic curves defined by DIRDEG and HZ with ALIGNDEG. In
    % case ALIGNDEG is not provided (or empty), the vector average is
    % calculated an used to align the curve. If optional argument
    % PRECISSIONDEG is not empty, specifies if the curve should be
    % interpolated using interp1 and with what precission. This curve can
    % be used for plotting or for pooling of multiple aligned tuning
    % curves. The default method of interpolation is linear but any method
    % that interp1 accepts can be provided in optional argument
    % INTERP1METHOD (e.g., 'spline').
    %
    % EXAMPLE
    %   % Make some fake tuning curve with prefdir 76
    %   dirs=0:30:330
    %   rho=jdAsymCos(dirs-76,.5,'deg')/2+.5;
    %   % Align and plot it nicely (markers and lines)
    %   [aMarkers,hzMarkers,prefdir]=jdTuningCurveAlign(dirs,rho);
    %   [aLine,hzLine,prefdir]=jdTuningCurveAlign(dirs,rho,prefdir,1,'spline');
    %   plot(aLine,hzLine,'-');
    %   hold on
    %   plot(aMarkers,hzMarkers,'o');
    %   %If you want prefdir to be in the middle but not called be zero:
    %   jdXaxis(-180,180);
    %   tix=[-180:45:180];
    %   set(gca,'XTick',[-180:45:180]);
    %   tix=tix+prefDirPhi;
    %   tix(tix>180)=tix(tix>180)-360;
    %   set(gca,'XTickLabel',round(tix));
    %
    % See also: jdSimplifyCurve
     
    if nargin<2 || isempty(Hz)
        Hz=ones(size(dirDeg));
    end
    if nargin<3 || isempty(alignDeg)
        % align with the vector average direction if no alignDeg is given
        alignDeg=mstd(circular(dirDeg,Hz,'deg'));
    end
    if nargin<4 || isempty(precissionDeg)
        % useful for plotting and pooling purposes
        precissionDeg='dontinterpolate';
    end
    xy=[cosd(dirDeg(:)) sind(dirDeg(:))];
    xy=xy*jdRotationMatrix(alignDeg,'deg');
    angleVals=atan2d(xy(:,2),xy(:,1)); % -180 ... 180
    [angleVals,idx]=sort(angleVals);
    Hz=Hz(idx);
    if isnumeric(precissionDeg)
        Xi=-180:precissionDeg:(180-precissionDeg);
        X=[angleVals-360 angleVals angleVals+360];
        Y=[Hz Hz Hz];
        Yi=interp1(X,Y,Xi,interp1method);
        angleVals=Xi;
        Hz=Yi;
    end    
end
