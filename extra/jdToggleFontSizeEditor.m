function jdToggleFontSizeEditor(fontsize)
    
    % jdToggleFontSizeEditor(fontsize)
    %
    % Change the font size in the Matlab editor window.
    %
    % USAGE:
    %   jdToggleFontSizeEditor [Without argument] switches between Matlab
    %   default editor font and larger ones that puts less strain on my
    %   eyes when I use my ASUS N550jv laptop.
    %
    %   jdToggleFontSizeEditor(fontsize) change size to numerical fontsize.
    %
    % Jacob Duijnhouwer, 2014-10-13
    
    if isunix || ismac
        disp('only tested for windows');
        return;
    end
    
    if nargin==0
        k=com.mathworks.services.FontPrefs.getCodeFont;
        if get(k,'Size')==13
            fontsize=16;
        else
            fontsize=13; % default matlab editor font size
        end
    end
    F=java.awt.Font('Courier New',java.awt.Font.PLAIN,fontsize);
    com.mathworks.services.FontPrefs.setCodeFont(F);
end
