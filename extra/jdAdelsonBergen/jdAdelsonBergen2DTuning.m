function jdAdelsonBergen2DTuning
    
    % make the stimuli
    theta=0:30:360;
    pxPerFr=4;
    for modus=0
        if modus==0
            style='b.-';
        else
            style='r.--';
        end
        resp=nans(size(theta));
        for i=1:numel(theta)
            dx=cosd(theta(i))*pxPerFr*4;
            dy=sind(theta(i))*pxPerFr*4;
            jdMovieRandomDots('filename','tmp.avi','pxHor',800,'pxVer',11*4,'fadePx',-1 ...
                ,'frN',50,'nDots',360,'RGB0',[.5 .5 .5],'RGB1',[0 0 0],'RGB2',[1 1 1] ...
                ,'revphi',modus==1, 'dx',dx,'dy',dy,'dotRadiusPx',2,'deltaDeg',0,'aaPx',2 ...
                ,'play_',false);
            A=jdMovieToArray('tmp.avi'); 
            %delete('tmp.avi');
            XT=jdMovieArrayToSpaceTime(A,[]);
            findfig(['XT - theta ' num2str(theta(i))]);
            imagesc(XT);
            tilefigs;
            M=jdAdelsonBergen(XT(:,:,1));
            resp(i)=M.dirNrg.rightTotal;
        end
        findfig('result');
        subplot(1,2,1);
        polar(theta/180*pi,resp,style);
        subplot(1,2,2);
        plot(theta,resp,style);
        jdPlotHori;
    end
end

