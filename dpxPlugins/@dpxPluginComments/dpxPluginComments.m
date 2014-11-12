classdef dpxPluginComments < hgsetget 
    
    % If you're about to make additional plugins, I recommend creating
    % dpxAbstractPlugin to inherit from first, as in dpxAbstractStim and
    % dpxAbstractResp
    
    properties (Access=public)
        % all plugins have these (todo: move to abstract class)
        name;
        pauseMenuKeyStrCell;
        pauseMenuInfoStrCell;
        % specific for this plugin...
        inputs; % list of comments
        secs; % a corresponding list of timestamps
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function P=dpxPluginComments
            % Part of DPX framework
            % http://tinyurl.com/dpxlink
            % Jacob Duijnhouwer, 2014-11-12
            %
            % Plugin to add comments to experiment
            %
            % See also: dpxPluginEyelink
            P.name='comments';
            P.pauseMenuKeyStrCell={'1!'}; % Todo: asign numbers automatically so no conflict between plugins possible
            P.pauseMenuInfoStrCell={'Type a comment (ENTER when done)'};
            P.secs={};
            P.inputs={};
        end
        function ok=start(P,getExp)
            P; %#ok<*VUNUS>
            getExp;
            ok=true;
        end
        function stop(P)
            P;
        end
        function choiceIsMade=pauseMenuFunction(P)
            % This function is common to all plugins, it is called in a
            % loop while the pause menu is displayed (key: pause) The trial
            % will be interupted, this function will be called in a loop,
            % and after a choice has been made in this or the
            % pauseMenuFunction of other plugins the next trial will start
            % and the interrupted trial be repeated at some later time.
            choiceIsMade=false;
            KbName('UnifyKeyNames');
            FlushEvents([],[],'keyDown');
            [keyIsDown,~,keyCode]=KbCheck(-1);
            if keyIsDown
                % The comment plugin has 1 control keys:
                if keyCode(KbName(P.pauseMenuKeyStrCell{1}))
                    choiceIsMade=true;
                    ListenChar(0); % allow keyboard input to matlab
                    commandwindow; % focus on command window
                    P.inputs{end+1}=input('Type comment and press enter >>','s');
                    P.secs{end+1}=now;
                    ListenChar(2); % Return to 'ignore keys to matlab'. This is sloppy!!! Should be returned to state that the ListenChar was in before calling ListenChar(0). (Which was MOST LIKELY 2, but you never know...). I can't find a way to request what ListenChar is (should be in output argument, but there is none ...'); 
                else
                    % a key was registered that is either not handled
                    % during pause, or was for another plugin
                end
            end
        end
    end
    
end