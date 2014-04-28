function [gamma]=jdPTBfindGamma(gammaest)
    if nargin==1
        gamma=gammaest;
    else
        gamma=.5;
    end
    Screen('Preference', 'SkipSyncTests', 1); 
    physscr.scrNr=max(Screen('screens'));
    [physscr.wpx,physscr.hpx,physscr.wmm,physscr.hmm]=jdPTBgetScreenSize(physscr.scrNr);
    %open double buffered window for stereo
    %[stimwin,physscr.windowRect]=Screen('OpenWindow',physscr.scrNr,0,[0 0 physscr.wpx physscr.hpx],[],2,0);
    [stimwin,physscr.windowRect]=Screen('OpenWindow',physscr.scrNr);
    % Get luninance index values
    stim.lumidx(1)=WhiteIndex(physscr.scrNr);
    stim.lumidx(2)=BlackIndex(physscr.scrNr);
    stim.lumidx(3)=(stim.lumidx(1)+stim.lumidx(2))/2;
    %
    stop=false;
    cdpm2=zeros(1,3);
    ListenChar(1);
    while ~stop
        physscr.gammatab=repmat((0:1/WhiteIndex(physscr.scrNr):1)',1,3).^gamma;
        try
            Screen('LoadNormalizedGammaTable',physscr.scrNr,physscr.gammatab);
            loadtableok=true;
        catch
            disp('Error LoadingNormalizedGammaTable, gamma value probably too low or too high!');
            disp('Reopening the stimulus window ...');
            [stimwin,physscr.windowRect]=Screen('OpenWindow',physscr.scrNr);
            loadtableok=false;
        end
        if loadtableok
            for i=1:numel(stim.lumidx) % assumes 3 now!
                Screen('FillRect',stimwin,stim.lumidx(i));
                Screen('Flip',stimwin);
                r=input([num2str(i) '. Enter cd/m2 or leave blank to use ' num2str(cdpm2(i)) ' > '],'s');
                if ~isempty(r)
                    cdpm2(i)=str2double(r);
                end
            end
            %
            targetGrayCdpm2=mean(cdpm2(1:2));
            disp(['Measured White = ' num2str(cdpm2(1))]);
            disp(['Measured Black = ' num2str(cdpm2(2))]);
            disp(['Measured Gray = ' num2str(cdpm2(3))]);
            disp(['Target Gray = ' num2str(targetGrayCdpm2)]);
        end
        disp(['Current gamma value = ' num2str(gamma)]);

        newgamma=str2num(input('Enter new gamma or leave blank if satisfied > ','s'));
        stop=isempty(newgamma);
        if ~stop
            gamma=newgamma;
        end
    end
    Screen('CloseAll');
end

