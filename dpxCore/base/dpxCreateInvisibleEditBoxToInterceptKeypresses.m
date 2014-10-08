function figHandle=dpxCreateInvisibleEditBoxToInterceptKeypresses
    % Create a(n invisible) figure window with an edit-box to keep
    % keypresses from also going into the command window or an open
    % file in the editor, which could potentially mess things up
    % badly.
    figHandle=dpxFindFig('DPX KeyCatcher','visible',false,'Position',[0 0 1 1]);
    h=uicontrol('Parent',figHandle,'Style','edit','Visible','off');
    uicontrol(h);
    set(figHandle,'visible','off');    
end