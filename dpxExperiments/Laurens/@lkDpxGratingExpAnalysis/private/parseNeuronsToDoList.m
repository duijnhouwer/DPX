function list=parseNeuronsToDoList(code,maxN)
    
    if all(code==0)
        list=1:maxN;
    elseif all(code>0)
        list=code;
    elseif all(code<0)
        list=1:maxN;
        % now remove the numbers in code
        for i=1:numel(code)
            list(abs(code(i)))=[];
        end
    else
        error('The list of numbers should be either a single zero, or all negative numbers, or all positive');
    end
end
   