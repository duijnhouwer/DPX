function list=parseNeuronsToDoList(code,completeNeuronNrList)
    
    if all(code==0)
        list=completeNeuronNrList;
    elseif all(code>0)
        list=code;
    elseif all(code<0)
        list=completeNeuronNrList;
        % now remove the numbers in code
        for i=1:numel(code)
            list(abs(code(i)))=[];
        end
    else
        error('The list of numbers should be either a single zero, or all negative numbers, or all be positive');
    end
end
   