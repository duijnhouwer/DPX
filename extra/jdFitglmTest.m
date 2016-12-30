function jdFitglmTest
    
    N=10^6;
    R=poissrnd(2,N,1);
    S=randn(N,2);
    
 %   S(:,1)=S(:,1).*R;
    
    mdl=fitglm(S,R,'linear','distri','poisson')
    
    
    keyboard
end