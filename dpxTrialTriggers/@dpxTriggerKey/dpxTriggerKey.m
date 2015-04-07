classdef dpxTriggerKey < hgsetget
    properties (Access=public)
        name;
        kbName; 
    end
    properties (Access=private)
        triggered;
    end
    methods (Access=public)
        function T=dpxTriggerKey
            % dpxTriggerKey
            % Part of DPX: An experiment preparation system
            % http://duijnhouwer.github.io/DPX/
            % Jacob Duijnhouwer 2015-03-25
            %
            % To find the name for key that you wish to use type the
            % following into the Matlab Command Window:
            %   KbName('UnifyKeyNames') % [ENTER]
            %   KbName % [ENTER]
            %   ... [Key you wish to use] 
            T.kbName='g'; % g for go is the default
            T.triggered=false;
        end
        function T=init(T)
            T.triggered=false;
        end
        function bool=go(T)
            % Does this trigger allow the start of the trial?
            if ~T.triggered
                T.triggered=any(dpxGetKey(T.kbName));
            end
            bool=T.triggered;
        end
    end
end
         