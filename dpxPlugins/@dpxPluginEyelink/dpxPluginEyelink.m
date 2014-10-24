classdef dpxPluginEyelink < hgsetget
    
    properties (Access=protected)
        el;
        edfFile;
    end
    methods (Access=public)
        function P=dpxPluginEyelink
        end
        function start(P,getExp)
            fprintf('dpxPluginEyelink\n\n\t');
            dummymode=0;
            P.el=EyelinkInitDefaults(getExp.scr.windowPtr);
            % Initialization of the connection with the Eyelink Gazetracker.
            % exit program if this fails.
            if ~EyelinkInit(dummymode, 1)
                fprintf('Eyelink Init aborted.\n');
                cleanup;  % cleanup function
                return;
            end
            [v,vs]=Eyelink('GetTrackerVersion');
            fprintf('Running experiment on a ''%s'' tracker.\n', vs );
            % make sure that we get gaze data from the Eyelink
            Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA'); 
            % open file to record data to
            P.edfFile='demo.edf';
            Eyelink('Openfile', P.edfFile);
            % Calibrate the eye tracker
            EyelinkDoTrackerSetup(P.el);
            % do a final check of calibration using driftcorrection
            EyelinkDoDriftCorrection(P.el);
            Eyelink('StartRecording');
            % record a few samples before we actually start displaying
            WaitSecs(0.1);
        end
        function stop(P)
             WaitSecs(0.1);
    
             % STEP 7
             % finish up: stop recording eye-movements,
             % close graphics window, close data file and shut down tracker
             Eyelink('StopRecording');
             Eyelink('CloseFile');
             % download data file
             try
                 fprintf('Receiving data file ''%s''\n', P.edfFile );
                 status=Eyelink('ReceiveFile');
                 if status > 0
                     fprintf('ReceiveFile status %d\n', status);
                 end
                 if 2==exist(edfFile, 'file')
                     fprintf('Data file ''%s'' can be found in ''%s''\n', P.edfFile, pwd );
                 end
             catch me
                 fprintf('Problem receiving data file ''%s''\n', P.edfFile );
                 me;
             end
             
             Eyelink('Shutdown');
        end
    end
    
end