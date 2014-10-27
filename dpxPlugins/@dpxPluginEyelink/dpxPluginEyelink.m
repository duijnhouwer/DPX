classdef dpxPluginEyelink < hgsetget
    
    properties (Access=public)
        name='eyelink';
        info;
    end
    properties (Access=protected)
        edfFile;
        el;
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
            name=mfilename;
        end
        function ok=start(P,getExp)
            Eyelink('Shutdown');
            ok=true;
            disp('Starting dpxPluginEyelink');
            dummymode=0;
            P.el=EyelinkInitDefaults(getExp.scr.windowPtr);
            % Initialization of the connection with the Eyelink Gazetracker.
            % exit program if this fails.
            if ~EyelinkInit(dummymode, 1)
                fprintf('Eyelink Init aborted.\n');
                Eyelink('Shutdown');
                ok=false;
                return;
            end
            [~,P.info]=Eyelink('GetTrackerVersion');
            P.info=strtrim(P.info);
            % make sure that we get gaze data from the Eyelink
            Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
            % open file on host computer to record data to
            Eyelink('Openfile', 'dpx.edf');
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
                Eyelink('ReceiveFile','dpx.edf');
                movefile('dpx.edf',P.edfFile);
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
    end
    
end