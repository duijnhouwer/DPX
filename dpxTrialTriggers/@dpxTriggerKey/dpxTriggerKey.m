classdef dpxTriggerKey < dpxAbstractTrigger
    properties (Access=public)
        kbName;
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
        end
    end
    methods (Access=protected)
        function bool=myGo(T)
            bool=any(dpxGetKey(T.kbName));
        end
    end
end
