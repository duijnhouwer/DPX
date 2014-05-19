function [nflips,newdot,olddot]=jdPTBfeedback(correctKeyName,feedback,olddot)
    % [olddot,newdot,nflips]=jdPTBfeedback(olddot,correctKeyName,feedback)
    % Shared function to provide feedback to subject
    %
    % INPUT:
    %   CORRECTKEYNAME is the name of the desired response (e.g., 'LeftArrow')
    %
    %   OLDDOT is a struct that represent a dot (typically fixation marker)
    %       olddot.fix.xy
    %       olddot.fix.rgb
    %       olddot.fix.size 
    %
    %   FEEDBACK is a struct with fields (audio and visual are optional
    %   fields, they need no be both present)
    %       feedback.respCorrect: the desired response, e.g., 'LeftArrow', or a
    %           string representing a probablity of randomly counting correct
    %           (e.g. p='0.5' at coherence=0  in a two-alternative forced
    %           choice task or '1' when one just wants to acknowledge that
    %           user has pressed a response button.
    %       feedback.durCorrectFlips: the number of flips the correct-feedback will last
    %       feedback.durWrongFlips: the number of flips the wrong-feedback will last
    %       feedback.visual: [optional] structure, see below
    %       feedback.audio: [optional] struct, see below
    % 
    %   in which AUDIO is an optional stucture of the shape
    %       audio.enable: TRUE/FALSE
    %       audio.correct: audioplayer object
    %       audio.wrong: audioplayer object
    %
    %   in which VISUAL is an optional structure of the shape 
    %       visual.enable: TRUE/FALSE
    %       visual.dotCorrect.size: [optional]
    %       visual.dotCorrect.rgb: [optional]
    %       visual.dotWrong.size: [optional]
    %       visual.dotWrong.rgb: [optional]
    %
    %   The optional fields overwrite the corresponding fields in newdot when
    %   they are present and non-empty.
    %
    % OUTPUT:
    %       NFLIPS : the duration of the feedback in flips
    %       NEWDOT : olddot adjusted with the properties in feedback.visual 
    %       OLDDOT : the unadjusted olddot, useful to revert after nflips
    %
    % Jacob, 2014-05-17
    %
    % See jdPTBrdk for an example of usage.
    %
    % See also jdPTBmakeWave
    

    if ~isnan(str2double(feedback.respCorrect))
        correct=rand<=str2double(feedback.respCorrect);
    elseif ischar(feedback.respCorrect)
        correct=strcmpi(feedback.respCorrect,correctKeyName);
    elseif isempty(feedback.respCorrect)
        newdot=olddot;
        nflips=0;
        return;
    else
        error('feedback.respCorrect should be empty, a probability, or a keyname');
    end
    
    if isfield(feedback,'audio') && feedback.audio.enable
        % audioplayer has a significant delay at least on my Core i7 window
        % PC, with and without ASIO supporting soundcard with latency set
        % to minimum in its control panel. If timing is of the essence
        % we'll need a better solution.
        if correct
            feedback.audio.correct.play;
        else
            feedback.audio.wrong.play;
        end
    end
    if isfield(feedback,'visual') && feedback.visual.enable
        if correct
            newdot=changeDot(olddot,feedback.visual.dotCorrect);
            nflips=feedback.durCorrectFlips;
        else
            newdot=changeDot(olddot,feedback.visual.dotWrong);
            nflips=feedback.durWrongFlips;
        end
    end
end

function dot=changeDot(dot,newdot)
    fields=fieldnames(newdot);
    for i=1:numel(fields)
        if ~isempty(newdot.(fields{i}))
            % only overwrite defined or non-empty fields
            dot.(fields{i})=newdot.(fields{i});
        end
    end
end
    
