classdef dpxStimTactileMIDI < dpxBasicStim
    
    properties (Access=public)
        tapNote;
        tapOnSec;
        tapDurSec;
    end
    properties (Access=protected)
        midiSender=[];
        tapOnFlip;
        tapOffFlip;
    end
    methods (Access=public)
        function S=dpxStimTactileMIDI
            % dpxStimTactileMIDI
            % Part of DPX toolkit
            % Type: get(dpxStimTactileMIDI) for more info
            % Type: edit dpxStimTactileMIDI for full info
            %
            % Jacob Duijnhouwer, 2014-09-10
            S.tapNote=8;
            S.tapOnSec=-1;
            S.tapDurSec=-1;
            
        end
    end
    methods (Access=protected)
        function myInit(S)
            % 'BrainMidi.jar' should be in the dpxStimTactileMIDI class folder
            S.midiSender=MidiSender('Port A');
            S.tapOnFlip=round(S.tapOnSec*S.scrGets.measuredFrameRate+S.onFlip);
            S.tapOffFlip=S.tapOnFlip+round(S.tapDurSec*S.scrGets.measuredFrameRate);
        end
        function myDraw(S)
            onNotes=find(S.flipCounter==S.tapOnFlip);
            offNotes=find(S.flipCounter==S.tapOffFlip);
            for i=onNotes(:)'
                S.midiSender.sendJavaMidi([144 S.tapNote(i) 127]);
            end
            for i=offNotes(:)'
                S.midiSender.sendJavaMidi([144 S.tapNote(i) 0]);
            end
        end
        function myClear(S) 
            if ~isempty(S.midiSender)
           %     for v=1:13
           %         S.midiSender.sendJavaMidi([144 v 0]);
           %     end
               % S.midiSender.close();
                S.midiSender=[];
            end
        end
        
    end
end


