function [wpx,hpx,wmm,hmm]=jdPTBgetScreenSize(scrNr)
    [wpx,hpx]=Screen('WindowSize',scrNr);
    [wmm,hmm]=Screen('DisplaySize',scrNr);
    while true
        disp(['The screen is ' num2str(wmm) ' mm wide and ' num2str(hmm) ' mm high.']);
        s=input('Is this correct? [Y]/N > ','s');
        if strcmpi(strtrim(s),'N')
            wmm=num2str(input('Enter width in mm > ','s'));
            hmm=num2str(input('Enter width in mm > ','s'));
        else
            break;
        end
    end
end