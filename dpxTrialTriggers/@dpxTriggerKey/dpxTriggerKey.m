classdef dpxTriggerKey < hgsetget
    properties (Access=public)
        name;
        kbName='g';
    end
    methods (Access=public)
        function bool=go(G)
            % Does this trigger allow the start of the trial?
            bool=any(dpxGetKey(G.kbName));
        end
    end
end
         