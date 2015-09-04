function jdAdelsonBergen2DTuning
    
    % make the stimuli
    theta=0:45:360;
    pxPerFr=1;
    for modus=1
        if modus==1
            style='b.-';
             flipFr=0;
        else
            style='r.--';
            flipFr=2;
        end
        resp=nans(size(theta));
        for i=1:numel(theta)
            dx=cosd(theta(i))*pxPerFr;
            dy=sind(theta(i))*pxPerFr;
            jdMovieRandomDots('filename','tmp.avi','pxHor',800,'pxVer',11*4,'fadePx',-1 ...
                ,'frN',50,'nDots',-720,'RGB0',[.5 .5 .5],'RGB1',[0 0 0],'RGB2',[1 1 1] ...
                ,'rgbFlipFr',flipFr, 'dx',dx,'dy',dy,'dotRadiusPx',4,'deltaDeg',0,'aaPx',2 ...
                ,'play_',false,'stepFr',max(Inf,flipFr*2+1));
            A=jdMovieToArray('tmp.avi'); 
            %delete('tmp.avi');
            XT=jdMovieArrayToSpaceTime(A,[]);
            XT=XT(:,:,1); % make grayscale
            if false
                figure(123)
                subplot(1,2,1)
                imagesc(XT(20:50,20:140))
                load('\\vision\dfs\home\jacob\My Documents\MATLAB\DPX\extra\jdAdelsonBergen\@jdAdelsonBergen\private\AB16.mat')
                subplot(1,2,2)
                imagesc(stim(20:50,20:140))
                
                keyboard
                
            end
            
            dpxFindFig(['XT - theta ' num2str(theta(i))]);
            imagesc(XT);
            colormap gray
            tilefigs;
            M=jdAdelsonBergen(XT(:,:,1));
            
              R1=mean(M.filterMatch.right1(:));
    R2=mean(M.filterMatch.right2(:));
       L1=mean(M.filterMatch.left1(:));
    L2=mean(M.filterMatch.left2(:));
    
            resp(i)=L1+L2;%M.dirNrg.rightTotal;
        end
        dpxFindFig(mfilename);
        polar(theta/180*pi,resp,style);
        hold on
        dpxPlotHori;
    end
end

