classdef dpxPluginArduino < hgsetget
    
    % If you're about to make additional plugins, I recommend creating
    % dpxAbstractPlugin to inherit from first, as in dpxAbstractStim and
    % dpxAbstractResp
    
    properties (Access=public)
        % all plugins have these (todo: move to abstract class)
        name;
        pauseMenuKeyStrCell;
        pauseMenuInfoStrCell;
        % info;
        % specific for this plugin...
        tag;
        comPortStr;
    end
    properties (SetAccess=public,GetAccess=protected)
    end
    properties (Access=protected)
        ser; % serial port connection
    end
    methods (Access=public)
        function P=dpxPluginArduino
            % Part of DPX framework
            % http://tinyurl.com/dpxlink
            % Jacob Duijnhouwer, 2015-03-22
            %
            % Plugin to use Eyelink for gaze tracking in DPX.
            %
            % See also: dpxDocsArduinoHowTo
            P.name='arduino';
            P.pauseMenuKeyStrCell={'4$@'}; % TOdo: asign numbers automatically so no conflict between plugins possible
            P.pauseMenuInfoStrCell={'List Arduino Sketch code'};
            P.tag='dpxArduinoTag';
            P.comPortStr='';
        end
        function ok=start(P,getExp)
            if isempty(P.comPortStr)
                error('a:b','[dpxPluginArduino] A comPortStr must be defined.\n\tTIP: Use the Arduino IDE to look up the comport under ''Tools>Port''');
            end
            try
                getExp; %#ok<VUNUS>
                delete(instrfind('Tag',P.tag))
                P.ser=serial(P.comPortStr,'Tag',P.tag);
                set(P.ser,'DataBits',8);
                set(P.ser,'StopBits',1);
                set(P.ser,'BaudRate',9600);
                set(P.ser,'Parity','none');
                fopen(P.ser);
                fromarduino='b';
                while fromarduino~='a'
                    fromarduino=fread(P.ser,1,'uchar');
                end
                fprintf(P.ser,'%c','m');
                disp(['Serial link ''' P.tag ''' established on port ' P.comPortStr ]);
            catch me
                ok=false; %#ok<NASGU>
                disp(['Serial link ''' P.tag ''' could not be established port ' P.comPortStr '!!!']);
                error(me.message);
            end
            ok=true;
        end
        function stop(P)
            fclose(P.ser);
            delete(instrfind('Tag',P.tag))
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
                % The eyelink plugin has 2 control keys:
                if keyCode(KbName(P.pauseMenuKeyStrCell{1}))
                    disp('Arduino Sketch code listing not implemented yet.');
                    choiceIsMade=true;
                else
                    % a key was registered that is either not handled
                    % during pause, or is for another plugin than eyelink
                end
            end
        end
    end
    
end