function y=jdSmoothBottom(x)
    
    
    % Clip value below zero to zero, but do so in a smooth fashion so that it
    % can be used in fitting procedures that would otherwise get stuck in the
    % discontinuity.
    
    x=x-1/pi;
    neg=x<0;
    y=x;
    y(neg)=(atan(5.*x(neg))-atan(-5.*x(neg)))/(pi^2);
    y=y+1/pi;
end