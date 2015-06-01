classdef (Abstract) dpxAbstractPlugin < hgsetget 
    
    properties (Access=public)
        % all plugins have these (todo: move to abstract class)
        name;
        pauseMenuKeyStrCell;
        pauseMenuInfoStrCell;
    end
    properties (Access=protected)
    end
    methods (Access=public)
        function P=dpxPluginComments
            % Part of DPX: An experiment preparation system
            % http://duijnhouwer.github.io/DPX/
            % Jacob Duijnhouwer, 2014-11-12
            P.name='';
            P.pauseMenuInfoStrCell={'Type a comment (ENTER when done)'};
            P.secs={};
            P.inputs={};
        end
        function ok=start(P,getExp)
			% Figure out the key that should go with this plugin on the Pause menu by looking up which index this plugin has in the list of plugins of the experiment
            P.pauseMenuKeyStrCell={'1!'}; % Todo: asign numbers automatically so no conflict between plugins possible
            ok=P.myStart(getExp);
        end
        function stop(P)
            P.myStop();
        end
        function choiceIsMade=pauseMenuFunction(P)
            % This function is common to all plug-ins, it is called in a
            % loop while the pause menu is displayed (key: pause) The trial
            % will be interrupted, this function will be called in a loop,
            % and after a choice has been made in this or the
            % pauseMenuFunction of other plug-ins the next trial will start
            % and the interrupted trial be repeated at some later time.
            choiceIsMade=false;
            KbName('UnifyKeyNames');
            FlushEvents([],[],'keyDown');
            [keyIsDown,~,keyCode]=KbCheck(-1);
            if keyIsDown
                % The comment plugin has 1 control keys:
                if keyCode(KbName(P.pauseMenuKeyStrCell{1}))
                    choiceIsMade=true;
					myPauseMenuFunction(P);
                else
                    % a key was registered that is either not handled
                    % during pause, or was for another plugin
                end
            end
        end
    end
	methods (Access=protected)
		function bool=myStart(P,getExp); end
		function myStop(P); end
		function myPauseMenuFunction(P); end
	end
end