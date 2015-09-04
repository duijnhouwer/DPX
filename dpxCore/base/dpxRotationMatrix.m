function R = dpxRotationMatrix(angles,unit)
    
    % R = dpxRotationMatrix(angles,unit)
    %
    % EXAMPLE
    %   dpxRotationMatrix(180)
    %   ans =
    %       -1     0
    %        0    -1
    %   dpxRotationMatrix(pi/2,'rad')
    %   ans =
    %       0.0000    -1.0000
    %       1.0000     0.0000
    
    if numel(angles)==1
        a=angles(1);
        if ~exist('unit','var') || strcmpi(unit,'deg')
            R=[cosd(a) -sind(a) ; sind(a) cosd(a)];
        elseif strcmpi(unit,'rad')
            R=[cos(a) -sin(a) ; sin(a) cos(a)];
        end
    else
        error('Only 2D rotation implemented');
    end
end

