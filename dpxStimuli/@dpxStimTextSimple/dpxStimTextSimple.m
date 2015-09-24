classdef dpxStimTextSimple < dpxAbstractVisualStim   
    properties (Access=public)    
        str; 
        RGBAfrac; 
        fontname;
        fontsize;
    end
    properties (Access=protected)
        RGBA;
        oldFontName;
        oldTextSize;
    end
    methods (Access=public)
        function S=dpxStimTextSimple
            % dpxStimTextSimple
            % Part of the DPX toolbox
            % Jacob Duijnhouwer 2015-03-25
            %
            % This stimulus displays a text during the condition simply at
            % the center of the screen.
            % 
            % For a dpxStim that has all the functionality of PTB's
            % DrawFormattedText function see dpxStimText.
            %     
            % See also: dpxStimText, dpxExampleExperimentWithText
            %
            % Todo: make winRect adapt to the standard xDeg and yDeg coordinates
            % that any stimulus has. Add more set function with error
            % checking.
            S.str='Welcome to DPX!\n^_^';
            S.RGBAfrac=[1 1 1 1];
            S.fontname='DefaultFontName';
            S.fontsize=25;
        end
    end
    methods (Access=protected)
        function myInit(S)
            % Called at the beginning of the trial, typically public values
            % get converted here to behind the scenes protected properties
            S.RGBA=S.RGBAfrac*S.scrGets.whiteIdx;
            S.oldFontName=Screen('Textfont',S.scrGets.windowPtr,S.fontname);
            S.oldTextSize=Screen('TextSize',S.scrGets.windowPtr,S.fontsize);
        end
        function myDraw(S)
            if S.visible
                DrawFormattedText(S.scrGets.windowPtr,S.str,'center','center',S.RGBA,[],0,0,1.5,0,[]);
            end
        end
        function myClear(S)
            % This doesn't really work when multiple text stimuli with
            % different fonts are used but can't be bothered right now (who
            % needs multiple fonts anyway?)
            Screen('Textfont',S.scrGets.windowPtr,S.oldFontName);
            Screen('TextSize',S.scrGets.windowPtr,S.oldTextSize);
        end
    end
    methods
        function set.RGBAfrac(S,value)
            if value=='?'
                disp('RGBAfrac (numeric): red-green-blue-opacity values [0..1] of the font.');
                return;
            end
            [ok,errstr]=dpxIsRGBAfrac(value);
            if ~ok
                error(['RBGAfrac should be a ' errstr]);
            else
                S.RGBAfrac=value;
            end
        end
        function set.str(S,value)
            if ~ischar(value)
                error('str should be a string');
            end
            S.str=value;
        end      
    end
end
