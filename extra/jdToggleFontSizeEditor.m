function jdToggleFontSizeEditor(fontsize,style)
    
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
    %   jdToggleFontSizeEditor(_,style) change size to numerical fontsize.
    %
    % Jacob Duijnhouwer, 2014-10-13
    
    if isunix || ismac
        warning('only tested for windows');
    end
    
    if nargin==0
        k=com.mathworks.services.FontPrefs.getCodeFont;
        if get(k,'Size')~=16
            fontsize=16;
        else
            fontsize=13; % default matlab editor font size
        end
    end
    if nargin==1
        style='PLAIN';
    end
    if ~isnumeric(fontsize)
        error('fontsize must be numeric');
    end
    if ~ischar(style) || ~any(strcmpi(style,{'plain','bold','italic'}))
        error('style myst be PLAIN BOLD or ITALIC');
    end
    F=java.awt.Font('Courier New',java.awt.Font.(upper(style)),fontsize);
    com.mathworks.services.FontPrefs.setCodeFont(F);
end
