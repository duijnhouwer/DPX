function plotDirectionTuningCurve(TC)
	plot(TC.dirDeg,TC.meanDFoF,'o-');
    xlabel('Direction (deg)');
    ylabel('mean dFoF');
end