classdef dpxPluginEyelink < hgsetget
    
    % If you're about to make additional plugins, I recommend creating
    % dpxAbstractPlugin to inherit from first, as in dpxAbstractStim and
    % dpxAbstractResp
    
    properties (Access=public)
        % all plugins have these (todo: move to abstract class)
        name;
        info;
        pauseMenuKeyStrCell;
        pauseMenuInfoStrCell;
        % specific for this plugin...
        backGrayFrac;
        foreGrayFrac;
    end
    properties (Access=protected)
        edfFile;
        el;
        hostFileName='dpx.edf';
    end
    methods (Access=public)
        function P=dpxPluginEyelink
            % Part of DPX framework
            % http://tinyurl.com/dpxlink
            % Jacob Duijnhouwer, 2014-10-27
            %
            % Plugin to use Eyelink for gaze tracking in DPX.
            %
            % See also: dpxDocsEyelinkHowTo
            P.name='eyelink';
            P.info='';
            P.pauseMenuKeyStrCell={'1!','2@'};
            P.pauseMenuInfoStrCell={'Eyelink setup','Eyelink driftcorrect'};
            P.backGrayFrac=[]; % empty means copy from experiment
            P.foreGrayFrac=1;
        end
        function ok=start(P,getExp)
            Eyelink('Shutdown');
            ok=true;
            disp('Starting dpxPluginEyelink');            
            %
            P.el=EyelinkInitDefaults(getExp.scr.windowPtr);
            if isempty(P.backGrayFrac)
                meanRGB=mean(getExp.scr.backRGBA(1:3));
                P.el.backgroundcolour=meanRGB*getExp.scr.whiteIdx;
            else
                P.el.backgroundcolour=P.backGrayFrac*getExp.scr.whiteIdx;
            end
            P.el.foregroundcolour=P.foreGrayFrac*getExp.scr.whiteIdx; % this doesn't seem to change the marker color, TODO 666
            if abs(P.el.backgroundcolour-P.el.foregroundcolour)<1
                warning('fore and back colors of eyelink very similar!!');
            end
            EyelinkUpdateDefaults(P.el);
            %
            dummymode=0;
            if ~EyelinkInit(dummymode, 1)
                disp('Eyelink Init aborted.');
                Eyelink('Shutdown');
                ok=false;
                return;
            end
            [~,P.info]=Eyelink('GetTrackerVersion');
            P.info=strtrim(P.info);
            % make sure that we get gaze data from the Eyelink
            Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
            % open file on host computer to record data to
            Eyelink('Openfile', P.hostFileName);
            % Calibrate the eye tracker
            EyelinkDoTrackerSetup(P.el);
            % do a final check of calibration using driftcorrection
            EyelinkDoDriftCorrection(P.el);
            Eyelink('StartRecording');
            % record a few samples before we actually start displaying
            WaitSecs(0.1);
            P.edfFile=fullfile(getExp.outputFolder,getExp.outputFileName);
            P.edfFile=dpxStrReplaceExtension(P.edfFile,'edf');
        end
        function stop(P)
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            % download data file
            try
                disp(['Receiving Eyelink data file ''' P.edfFile ''' ...']);
                Eyelink('ReceiveFile',P.hostFileName);
                movefile(P.hostFileName,P.edfFile);
                if exist(P.edfFile, 'file')
                    disp('Eyelink file transfer complete.');
                end
                Eyelink('Shutdown');
            catch me
                warning('There was a problem receiving the eyelink file!!');
                disp('You can copy and rename the file manually from the Eyelink host computer. The file is called dpx.edf.');
                Eyelink('Shutdown');
                %rethrow(me);
            end
        end
        function choiceIsMade=pauseMenuFunction(P)
            % This function is common to all plugins, it is called in a loop while the pause menu is displayed (key: pause) The trial will be interupted,
            % this function will be called, and after returning from this
            % fucntion the next trial will start and the interrupted trial
            % repeated at some later time.
            choiceIsMade=false;
            KbName('UnifyKeyNames');
            FlushEvents([],[],'keyDown');
            [keyIsDown,~,keyCode]=KbCheck(-1);
            if keyIsDown
                % The eyelink plugin has 2 control keys:
                if keyCode(KbName(P.pauseMenuKeyStrCell{1}))
                    EyelinkDoTrackerSetup(P.el);
                    choiceIsMade=true;
                elseif keyCode(KbName(P.pauseMenuKeyStrCell{2}))
                    EyelinkDoDriftCorrection(P.el);
                    choiceIsMade=true;
                else
                    % a key was registered that is either not handled
                    % during pause, or is for another plugin than eyelink
                end
            end
        end
    end
    
end